class LineMap
  constructor: ->
    @value = 1

export class SourceMap
  constructor: ->
    @lines = []

  add: (x) ->
    @lines.push x
