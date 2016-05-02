path = require 'path'

module.exports =  
  activate: ->
    atom.commands.add 'atom-text-editor',
      'natural-autoflow:reflow-selection': (event) =>
        @reflowSelection(event.currentTarget.getModel())

  reflowSelection: (editor) ->
    range = editor.getSelectedBufferRange()
    range = editor.getCurrentParagraphBufferRange() if range.isEmpty()
    return unless range?

    reflowOptions = wrapColumn: @getPreferredLineLength(editor)
    reflowedText = @reflow(editor.getTextInRange(range), reflowOptions)
    editor.getBuffer().setTextInRange(range, reflowedText)

  reflow: (text, {wrapColumn}) ->
    paragraphs = []
    paragraphBlocks = text.split(/\n\s*\n/g)

    for block in paragraphBlocks
      linePrefix = block.match(/^\s*[\/#*-]*\s*/g)[0]
      blockLines = block.split('\n')

      blockLines = blockLines.map (blockLine) ->
        blockLine.replace(/^\s+/, '')

      lines = []
      currentLine = []
      currentLineLength = linePrefix.length

      foundPeriod = false
      wrapNext = false
      insideComment = false
      insideEnvironment = false
      lineCount = blockLines.length
      lineNumber = 0
      for line in blockLines
          if lineNumber == lineCount - 1 or /^\s*$/.test(line)
            suffix = ''
          else
            suffix = ' '
          for segment in @segmentText(line + suffix)
            if @wrapSegment(segment, currentLineLength, wrapColumn) or /^\[/.test(segment) or wrapNext
              lines.push(linePrefix + currentLine.join(''))
              currentLine = []
              currentLineLength = linePrefix.length
              wrapNext = false
              foundPeriod = false
            if foundPeriod
              wrapNext = true
            # wrap next segment if this contains a strong delimiter
            if /(\.|\?|\!|\:|\;|\])$/.test(segment) and not insideComment
              foundPeriod = true
            # wrap next segment if this contains a weak delimiter and is past half
            # the length of the line
            if /(,)$/.test(segment) and @wrapSegment(segment, currentLineLength * 2.0, wrapColumn)
              foundPeriod = true
            currentLine.push(segment)
            currentLineLength += segment.length
          lineNumber += 1
      if currentLineLength > 0
        lines.push(linePrefix + currentLine.join(''))

      paragraphs.push(lines.join('\n').replace(/\s+\n/g, '\n'))

    paragraphs.join('\n\n')

  getPreferredLineLength: (editor) ->
    atom.config.get('editor.preferredLineLength', scope: editor.getRootScopeDescriptor())

  wrapSegment: (segment, currentLineLength, wrapColumn) ->
    /\w/.test(segment) and
      (currentLineLength + segment.length > wrapColumn) and
      (currentLineLength > 0 or segment.length < wrapColumn)

  segmentText: (text) ->
    segments = []
    re = /[\s]+|[^\s]+/g
    segments.push(match[0]) while match = re.exec(text)
    segments
