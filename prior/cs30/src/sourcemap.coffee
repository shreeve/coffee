# Source Maps
# ============

# Source maps allow JavaScript runtimes to match running JavaScript back to
# the original source code that corresponds to it. This can be minified
# JavaScript, but in our case, we're concerned with mapping pretty-printed
# JavaScript back to CoffeeScript.

# LineMap
# -------
# A **LineMap** object keeps track of information about original line and column
# positions for a single line of output JavaScript code.
# **SourceMaps** are implemented in terms of **LineMaps**.
class LineMap
  constructor: (@line) ->
    @columns = []

  add: (column, [sourceLine, sourceColumn], options={}) ->
    return if @columns[column] and options.noReplace
    @columns[column] = {line: @line, column, sourceLine, sourceColumn}

  sourceLocation: (column) ->
    column-- until (mapping = @columns[column]) or (column <= 0)
    mapping and [mapping.sourceLine, mapping.sourceColumn]

# SourceMap
# ---------
# Maps locations in a single generated JavaScript file back to locations in
# the original CoffeeScript source file.
export class SourceMap
  constructor: ->
    @lines = []

  # Adds a mapping to this SourceMap. `sourceLocation` and `generatedLocation`
  # are both `[line, column]` arrays. If `options.noReplace` is true, then if there
  # is already a mapping for the specified `generatedLocation`, this will have no effect.
  add: (sourceLocation, generatedLocation, options = {}) ->
    [line, column] = generatedLocation
    lineMap = (@lines[line] or= new LineMap(line))
    lineMap.add column, sourceLocation, options

  # Look up the original position of a given `line` and `column` in the generated code.
  sourceLocation: ([line, column]) ->
    line-- until (lineMap = @lines[line]) or (line <= 0)
    lineMap and lineMap.sourceLocation column

  # V3 SourceMap Generation
  # ------------------------
  generate: (options = {}, code = null) ->
    writingline       = 0
    lastColumn        = 0
    lastSourceLine    = 0
    lastSourceColumn  = 0
    needComma         = no
    buffer            = ""

    for lineMap, lineNumber in @lines when lineMap
      for mapping in lineMap.columns when mapping
        while writingline < mapping.line
          lastColumn = 0
          needComma = no
          buffer += ";"
          writingline++

        # Write a comma if we've already written a segment on this line.
        if needComma
          buffer += ","
          needComma = no

        # Write the next segment. Segments can be 1, 4, or 5 values.
        # If just one, then it is a generated column which doesn't match anything
        # in the source code.
        #
        # The starting column in the generated source, relative to any previous
        # recorded column for the current line:
        buffer += @encodeVlq mapping.column - lastColumn
        lastColumn = mapping.column
        # The index into the list of sources:
        buffer += @encodeVlq 0
        # The starting line in the original source, relative to the previous
        # source line.
        buffer += @encodeVlq mapping.sourceLine - lastSourceLine
        lastSourceLine = mapping.sourceLine
        # The starting column in the original source, relative to the previous
        # column.
        buffer += @encodeVlq mapping.sourceColumn - lastSourceColumn
        lastSourceColumn = mapping.sourceColumn
        needComma = yes

    # Produce the canonical JSON object format for a "v3" source map.
    v3 =
      version:    3
      file:       options.generatedFile or ''
      sourceRoot: options.sourceRoot or ''
      sources:    options.sourceFiles or ['']
      names:      []
      mappings:   buffer

    v3.sourcesContent = [code] if options.inlineMap
    v3

  # Base64 VLQ Encoding
  # --------------------
  # Encode a variable-length quantity as Base64 VLQ.
  encodeVlq: (value) ->
    VLQ_SHIFT            = 5
    VLQ_CONTINUATION_BIT = 1 << VLQ_SHIFT             # 0010 0000
    VLQ_VALUE_MASK       = VLQ_CONTINUATION_BIT - 1   # 0001 1111

    # Least significant bit represents the sign.
    signBit = if value < 0 then 1 else 0
    value = (Math.abs(value) << 1) + signBit
    # Make sure we encode at least one character, even if `value` is 0.
    answer = ''
    while value or not answer
      nextChunk = value & VLQ_VALUE_MASK
      value >>= VLQ_SHIFT
      if value
        nextChunk |= VLQ_CONTINUATION_BIT
      answer += @encodeBase64 nextChunk
    answer

  encodeBase64: (value) ->
    BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    BASE64_CHARS[value] or throw new Error "Cannot Base64 encode value: #{value}"

# Static source maps cache and methods
SourceMap.sourceMaps = Object.create null

SourceMap.registerCompiled = (filename, source, sourcemap) ->
  if sourcemap?
    SourceMap.sourceMaps[filename] = sourcemap

SourceMap.getSourceMap = (filename) ->
  SourceMap.sourceMaps[filename]

# Export static methods for use in coffeescript.coffee
export registerCompiled = SourceMap.registerCompiled
export getSourceMap = SourceMap.getSourceMap
