class Script
  attr_accessor :name, :body
  def initialize
    yield self if block_given?
  end
end

class ScriptCompiler
  attr_accessor :scripts

  def initialize(transforms, scripts=[])
    @transforms = transforms.map {|t| t.new}
    @scripts = scripts
  end

  def compile
    each_script do |script|
      @transforms.each {|t| t.transform!(script)}
    end
  end

  def each_script
  end
end

module ScriptTransform
  def transform!(script)
    @script = script
    can_handle? ? execute : script
  end

  private

  def can_handle?
    true
  end

  def execute
    @script
  end
end

class CoffeeScript
  include ScriptTransform

  private

  def can_handle?
  end

  def execute
  end
end