# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "keystone"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Music One Live"]
  s.date = "2012-11-27"
  s.description = "Asset pipeline"
  s.email = "admin@musiconelive.com"
  s.extra_rdoc_files = ["lib/keystone.rb", "lib/keystone/asset_tools.rb", "lib/keystone/asset_tools/closure.rb", "lib/keystone/asset_tools/coffeescript.rb", "lib/keystone/asset_tools/require.rb", "lib/keystone/asset_tools/sassy.rb", "lib/keystone/core.rb", "lib/keystone/core/asset.rb", "lib/keystone/core/asset_compiler.rb", "lib/keystone/core/asset_container.rb", "lib/keystone/core/asset_loader.rb", "lib/keystone/core/asset_pipeline.rb", "lib/keystone/core/asset_tool.rb", "lib/keystone/core/configuration.rb", "lib/keystone/core/types.rb", "lib/keystone/dsl.rb", "lib/keystone/dsl/asset_expression.rb", "lib/keystone/dsl/pipeline_expression.rb", "lib/keystone/rake_task.rb", "lib/keystone/sass/in_memory_importer.rb", "lib/keystone/server.rb", "lib/keystone/version.rb"]
  s.files = ["Gemfile", "Gemfile.lock", "Manifest", "Rakefile", "keystone.gemspec", "lib/keystone.rb", "lib/keystone/asset_tools.rb", "lib/keystone/asset_tools/closure.rb", "lib/keystone/asset_tools/coffeescript.rb", "lib/keystone/asset_tools/require.rb", "lib/keystone/asset_tools/sassy.rb", "lib/keystone/core.rb", "lib/keystone/core/asset.rb", "lib/keystone/core/asset_compiler.rb", "lib/keystone/core/asset_container.rb", "lib/keystone/core/asset_loader.rb", "lib/keystone/core/asset_pipeline.rb", "lib/keystone/core/asset_tool.rb", "lib/keystone/core/configuration.rb", "lib/keystone/core/types.rb", "lib/keystone/dsl.rb", "lib/keystone/dsl/asset_expression.rb", "lib/keystone/dsl/pipeline_expression.rb", "lib/keystone/rake_task.rb", "lib/keystone/sass/in_memory_importer.rb", "lib/keystone/server.rb", "lib/keystone/version.rb", "spec/environment/assets.rb", "spec/environment/assets/coffee/coffee1.coffee", "spec/environment/assets/css/readme.txt", "spec/environment/assets/css/style1.css", "spec/environment/assets/css/style2.css", "spec/environment/assets/js/js1.js", "spec/environment/assets/js/lib1/js2.js", "spec/environment/assets/js/lib1/js3.js", "spec/environment/assets/js/lib1/support/support.js", "spec/environment/assets/scss/main.scss", "spec/keystone/asset_compiler_spec.rb", "spec/keystone/asset_loader_spec.rb", "spec/keystone/asset_tool_spec.rb", "spec/keystone/asset_tools/closure_spec.rb", "spec/keystone/asset_tools/coffeescript_spec.rb", "spec/keystone/asset_tools/require_spec.rb", "spec/keystone/asset_tools/sassy_spec.rb", "spec/keystone/configuration_spec.rb", "spec/keystone/dsl/asset_expression_spec.rb", "spec/keystone/dsl/pipeline_expression_spec.rb", "spec/objects.rb", "spec/spec_helper.rb"]
  s.homepage = "http://musiconelive.com"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Keystone"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "keystone"
  s.rubygems_version = "1.8.10"
  s.summary = "Asset pipeline"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coffee-script>, [">= 0"])
      s.add_runtime_dependency(%q<closure-compiler>, [">= 0"])
      s.add_runtime_dependency(%q<sass>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
    else
      s.add_dependency(%q<coffee-script>, [">= 0"])
      s.add_dependency(%q<closure-compiler>, [">= 0"])
      s.add_dependency(%q<sass>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
    end
  else
    s.add_dependency(%q<coffee-script>, [">= 0"])
    s.add_dependency(%q<closure-compiler>, [">= 0"])
    s.add_dependency(%q<sass>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
  end
end
