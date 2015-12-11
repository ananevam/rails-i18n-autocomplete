

module.exports =
  # This will work on JavaScript and CoffeeScript files, but not in js comments.
  selector: '.source.ruby .string'
  #selector: '.string'
  disableForSelector: '* .comment'

  # This will take priority over the default provider, which has a priority of 0.
  # `excludeLowerPriority` will suppress any providers with a lower priority
  # i.e. The default provider will be suppressed
  inclusionPriority: 1
  excludeLowerPriority: true
  suggestions: []

  # Required: Return a promise, an array of suggestions, or null.
  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    left_cursor_text = editor.getTextInBufferRange([
      [bufferPosition["row"], 0],
      bufferPosition
    ])
    if (left_cursor_text.search(/[^a-z](t|[I18n\.t])[\'\"\s\(]+[a-zA-Z0-9]+/) >= 0)
      keys = []
      new Promise (resolve) =>
        for [key, value] in @suggestions
          if "#{key}".indexOf(prefix) >= 0
            keys.push {text: key, value: value, displayText: "#{key} - #{value}"}
        resolve(keys)

  # (optional): called _after_ the suggestion `replacementPrefix` is replaced
  # by the suggestion `text` in the buffer
  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  # (optional): called when your provider needs to be cleaned up. Unsubscribe
  # from things, kill any processes, etc.
  dispose: ->
