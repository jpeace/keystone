titan.define class View
  constructor: (@element) ->
    this.read()

  bind: (model) ->
    @model = model
    for own prop, val of @model
      $(@element).find("[data-property=#{prop}]").each ->
        if this.tagName.toLowerCase() == 'div'
          this.innerHTML = val
        else
          this.value = val

  read: ->
    @model ?= {}
    $(@element).find('input, div').each (i, el) =>
      prop_name = $(el).attr('data-property')
      return unless prop_name?
      
      if el.tagName.toLowerCase() == 'div'
        @model[prop_name] = el.innerHTML unless @model[prop_name]?
      else
        @model[prop_name] = el.value
    return @model