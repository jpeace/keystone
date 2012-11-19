require 'rake'

module Keystone
  class RakeTask
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :config_file, :output_path

    def initialize(*args)
      name = args.shift || :keystone
      yield self if block_given?

      task name do
        pipeline = Keystone.bootstrap(@config_file)
        pipeline.compilers.each do |c|
          package = c.build!
          File.open("#{@output_path}/#{package.name}", 'w') do |f|
            f.puts(package.content)
          end
        end
      end
    end
  end
end