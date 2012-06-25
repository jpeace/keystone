describe 'View', ->
  beforeEach ->
  afterEach ->

  this.in_spec = ->
    34

  it 'does something', =>
    expect(this.in_spec()).toBe(34)

  it 'can spy', =>
    spyOn(this, 'in_spec').andReturn(35)
    expect(this.in_spec()).toBe(35)

  describe 'with a simple template', ->
    subject = null 
    jq = null
    html = 
      '<div data-view="Test">
        <div id="name" data-property="name">Bob Golly</div>
        <input id="age" data-property="age" value="25" />
      </div>'
      
    beforeEach ->
      jq = $(html)
      subject = new titan.classes.View(jq)

    it 'binds to a model', ->
      subject.bind({name:'Jarrod',age:30})
      
      expect(jq.find('#name').html()).toBe 'Jarrod'
      expect(jq.find('#age').val()).toBe '30'

    it 'reads from the dom', ->
      model = subject.read()

      expect(model.name).toBe 'Bob Golly'
      expect(model.age).toBe '25'

    it 'only reads from inputs', ->
      jq.find('#name').html('Changed')
      jq.find('#age').val('35')
      model = subject.read()

      expect(model.name).toBe 'Bob Golly'
      expect(model.age).toBe '35'