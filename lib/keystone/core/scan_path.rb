module Keystone
	
	class ScanPath
		
		attr_accessor :path, :namespace

		def initialize(path, namespace=nil)
			@path = path
			@namespace = namespace
		end

	end

end