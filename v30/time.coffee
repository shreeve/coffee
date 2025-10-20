p = -> console.log arg for arg in arguments
type = (obj) -> if obj? then (obj.constructor?.name or Object::toString.call(obj)[8...-1]).toLowerCase() else String(obj)
exit = require('process').exit

# silly string formatter
format = (str, args...) ->
  pos = -1
  str.replace /%(0)?(\d+)?([ds])/g, (fmt, pad, num, chr) ->
    arg = args[++pos]
    if num
      pad = if pad then '0' else ' '
      arg = "#{arg}"
      now = arg.length
      len = parseInt(num, 10)
      if len > now
        pad = (new Array(len - now + 1)).join(pad)
        switch chr
          when 's' then arg = arg + pad # pad right
          when 'd' then arg = pad + arg # pad left
    arg

class Time extends Date

  @month_num = (str) -> {
    jan: 1, feb: 2, mar: 3, apr:  4, may:  5, jun:  6,
    jul: 7, aug: 8, sep: 9, oct: 10, nov: 11, dec: 12,
  }[str[0...3].toLowerCase()] or throw "bad month: #{str}"

  @offset_val: (str) ->
    if rgx = /^([-+])?(\d\d):?(\d\d)$/.exec(str) then "#{rgx[1] or '+'}#{rgx[2]}:#{rgx[3]}" else "+00:00"

  @parse_str = (str, ignore_offset) ->
    if rgx = /^((?:19|20)\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)?\.?(\d+)?([-+]\d\d:?\d\d)?/.exec(str)
      ymd = [+rgx[1], +rgx[2], +rgx[3]]
      hms = [+rgx[4], +rgx[5], +"#{rgx[6]}.#{rgx[7]}"]
      ofs = rgx[8].replace(/(\d)(\d\d)$/, (a,b,c) -> "#{b}:#{c}") if rgx[8] and not ignore_offset
    else if rgx = ///^
      (?:(0[1-9]|[12]\d|3[01]|[1-9])[-/\ ]?       #  1: day
         ((?:[a-z]{3}))[-/\ ]?                    #  2: month (abc)
         ((?:19|20)\d\d)                          #  3: year
      | # or...
         ((?:19|20)\d\d)[-/]                      #  4: year
         (0[1-9]|1[012]|[1-9](?=[-/]))[-/]?       #  5: month
         (0[1-9]|[12]\d|3[01]|[1-9][\sT])         #  6: day
      | # or...
         (0[1-9]|1[012]|[1-9](?=[-/]))[-/]?       #  7: month
         (0[1-9]|[12]\d|3[01]|[1-9](?=[-/]))[-/]? #  8: day
         ((?:19|20)\d\d)                          #  9: year
      )\s?T?\s?
      (\d\d?)?                                    # 10: hour
      :?(\d\d)?                                   # 11: min
      :?(\d\d)?                                   # 12: sec
      \.?(\d+)?                                   # 13: dec
      \s?(?:(A|P)?M)?                             # 14: AM/PM
      \s?([-+]\d\d:?\d\d|UTC|GMT)?                # 15: offset
    ///i.exec(str)
      ymd =  if rgx[ 1] then [+rgx[3], @month_num(rgx[2]), +rgx[1]] else if rgx[4] then [+rgx[4], +rgx[5], +rgx[6]] else [+rgx[9], +rgx[7], +rgx[8]]
      hms = [(if rgx[14] then +rgx[10] % 12 + (if rgx[14] in ["P","p"] then 12 else 0) else +rgx[10]), +rgx[11], +"#{rgx[12]}.#{rgx[13] or 0}"]
      ofs = @offset_val(rgx[15]) if rgx[15] and not ignore_offset
    else
      throw "can't parse: #{str}"
    if ofs then [ymd, hms, ofs] else [ymd, hms]

  @to_iso_date: (str, ignore_offset=false) ->
    [ymd] = @parse_str(str, ignore_offset)
    format "%04d-%02d-%02d", ymd...

  @to_tz: (str, to_tz=nil, ignore_offset=false) ->
    [ymd, hms, ofs] = @parse_str(str, ignore_offset)
    out = new Date(ymd..., hms..., ofs)
    if to_tz
      if ofs
        out = out.to_tz(to_tz)
      else
        utc = out.utc
        ofs = TZInfo::Timezone.get(to_tz).utc_to_local(utc) - utc
        out = new Date(ymd..., hms..., ofs)
    else
      out

p Time.to_iso_date "2 apr 1971 4:15:30PM +03:45"
# p Time.parse_str "2012-08-28 2:15:30PM +03:45"
# p Time.parse_str "04/13/1971 2:15:30PM +03:45"
# p Time.parse_str "13 dec 1971 4:15:30PM +03:45"
# Time.parse_str "2012-08-28 13:15:30.67am +03:45"

  # constructor: ->

  # p parse_str "2012-08-28 13:15:30"

  # p Time.to_tz( "2012-08-28 13:15:30"                         ) # 2012-08-28 13:15:30 -0400 -> ok!
  # p Time.to_tz( "2012-08-28 13:15:30 +0000"                   ) # 2012-08-28 13:15:30 +0000 -> ok!
  # p Time.to_tz( "2012-08-28 13:15:30 -0400"                   ) # 2012-08-28 13:15:30 -0400 -> ok!
  # puts "=" * 80

###

  def self.to_tz!(str, to_tz=nil)
    to_tz(str, to_tz, true)
  end

  # Convert time and offset
  def to_tz(to_tz)
    utc = utc? ? self : getutc
    raw = TZInfo::Timezone.get(to_tz).utc_to_local(utc)
    all = raw.to_a[1,5].reverse.push(strftime('%S.%6N').to_f) # retain fractional seconds
    out = Time.new(*all, raw - utc)
  end

  # Preserve time but change offset
  def to_tz!(to_tz)
    all = to_a[1,5].reverse.push(strftime('%S.%6N').to_f) # retain fractional seconds
    raw = Time.utc(*all)
    utc = TZInfo::Timezone.get(to_tz).local_to_utc(raw)
    out = Time.new(*all, raw - utc)
  end
end

p Time.to_tz( "2012-08-28 13:15:30"                         ) # 2012-08-28 13:15:30 -0400 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 +0000"                   ) # 2012-08-28 13:15:30 +0000 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 -0400"                   ) # 2012-08-28 13:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz( "2012-01-28 13:15:30"                         ) # 2012-01-28 13:15:30 -0500 -> ok!
p Time.to_tz( "2012-01-28 13:15:30 +0000"                   ) # 2012-01-28 13:15:30 +0000 -> ok!
p Time.to_tz( "2012-01-28 13:15:30 -0400"                   ) # 2012-01-28 13:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz( "2012-08-28 13:15:30"      , "America/Caracas") # 2012-08-28 13:15:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 +0000", "America/Caracas") # 2012-08-28 08:45:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 -0400", "America/Caracas") # 2012-08-28 12:45:30 -0430 -> ok!
puts "=" * 80

p Time.to_tz( "2012-01-28 13:15:30"      , "America/Caracas") # 2012-01-28 13:15:30 -0430 -> ok!
p Time.to_tz( "2012-01-28 13:15:30 +0000", "America/Caracas") # 2012-01-28 08:45:30 -0430 -> ok!
p Time.to_tz( "2012-01-28 13:15:30 -0400", "America/Caracas") # 2012-01-28 12:45:30 -0430 -> ok!
puts "~" * 80

p Time.to_tz!("2012-08-28 13:15:30"                         ) # 2012-08-28 13:15:30 -0400 -> ok!
p Time.to_tz!("2012-08-28 13:15:30 +0000"                   ) # 2012-08-28 13:15:30 -0400 -> ok!
p Time.to_tz!("2012-08-28 13:15:30 -0400"                   ) # 2012-08-28 13:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz!("2012-01-28 13:15:30"                         ) # 2012-01-28 13:15:30 -0500 -> ok!
p Time.to_tz!("2012-01-28 13:15:30 +0000"                   ) # 2012-01-28 13:15:30 -0500 -> ok!
p Time.to_tz!("2012-01-28 13:15:30 -0400"                   ) # 2012-01-28 13:15:30 -0500 -> ok!
puts "=" * 80

p Time.to_tz!("2012-08-28 13:15:30"      , "America/Caracas") # 2012-08-28 13:15:30 -0430-> ok!
p Time.to_tz!("2012-08-28 13:15:30 +0000", "America/Caracas") # 2012-08-28 13:15:30 -0430-> ok!
p Time.to_tz!("2012-08-28 13:15:30 -0400", "America/Caracas") # 2012-08-28 13:15:30 -0430-> ok!
puts "=" * 80

p Time.to_tz!("2012-01-28 13:15:30"      , "America/Caracas") # 2012-01-28 13:15:30 -0430 -> ok!
p Time.to_tz!("2012-01-28 13:15:30 +0000", "America/Caracas") # 2012-01-28 13:15:30 -0430 -> ok!
p Time.to_tz!("2012-01-28 13:15:30 -0400", "America/Caracas") # 2012-01-28 13:15:30 -0430 -> ok!
puts "+" * 80

p Time.to_tz( "2012-08-28 13:15:30").to_tz("America/Caracas"       ) # 2012-08-28 12:45:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30").to_tz("US/Pacific"            ) # 2012-08-28 10:15:30 -0700 -> ok!
p Time.to_tz( "2012-08-28 13:15:30").to_tz("US/Eastern"            ) # 2012-08-28 13:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz( "2012-08-28 13:15:30 UTC").to_tz("America/Caracas"   ) # 2012-08-28 08:45:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 UTC").to_tz("US/Pacific"        ) # 2012-08-28 06:15:30 -0700 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 UTC").to_tz("US/Eastern"        ) # 2012-08-28 09:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz( "2012-08-28 13:15:30 -0700").to_tz("America/Caracas" ) # 2012-08-28 15:45:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 -0700").to_tz("US/Pacific"      ) # 2012-08-28 13:15:30 -0700 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 -0700").to_tz("US/Eastern"      ) # 2012-08-28 16:15:30 -0400 -> ok!
puts "-" * 80

p Time.to_tz( "2012-08-28 13:15:30").to_tz!("America/Caracas"      ) # 2012-08-28 13:15:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30").to_tz!("US/Pacific"           ) # 2012-08-28 13:15:30 -0700 -> ok!
p Time.to_tz( "2012-08-28 13:15:30").to_tz!("US/Eastern"           ) # 2012-08-28 13:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz( "2012-08-28 13:15:30 UTC").to_tz!("America/Caracas"  ) # 2012-08-28 13:15:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 UTC").to_tz!("US/Pacific"       ) # 2012-08-28 13:15:30 -0700 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 UTC").to_tz!("US/Eastern"       ) # 2012-08-28 13:15:30 -0400 -> ok!
puts "=" * 80

p Time.to_tz( "2012-08-28 13:15:30 -0700").to_tz!("America/Caracas") # 2012-08-28 13:15:30 -0430 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 -0700").to_tz!("US/Pacific"     ) # 2012-08-28 13:15:30 -0700 -> ok!
p Time.to_tz( "2012-08-28 13:15:30 -0700").to_tz!("US/Eastern"     ) # 2012-08-28 13:15:30 -0400 -> ok!
###