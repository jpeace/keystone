describe Keystone::PipelineConfiguration do
  it "can be initialized through a configuration script" do
    config = described_class.from_file("#{File.dirname(__FILE__)}/../environment/assets.rb")

    config.asset_path.should eq ENV['ASSET_PATH']
    config.tool_modules.should include TestObjects::AssetTools
    config.assets.should have_exactly(2).items

    js_asset = config.assets.find {|a| a.name == 'titan.js'}
    js_asset.scan_paths.should include 'js'
    js_asset.scan_paths.should include 'coffee'
    js_asset.tools.should include Keystone::AssetTools::Coffeescript
    js_asset.tools.should include Keystone::AssetTools::Require
    js_asset.post_build_steps.should include Keystone::AssetTools::Closure
    js_asset.post_build_ignore_patterns.should include /^support$/
    js_asset.post_build_ignore_patterns.should include /\.coffee$/

    css_asset = config.assets.find {|a| a.name == 'titan.css'}
    css_asset.scan_paths.should include 'css'
    css_asset.scan_paths.should include 'scss'
    css_asset.tools.should include Keystone::AssetTools::Sassy
    css_asset.post_build_ignore_patterns.should be_empty
  end

  it "can be used to build a pipeline" do
    config = described_class.from_file("#{File.dirname(__FILE__)}/../environment/assets.rb")
    pipeline = Keystone.build_pipeline(config)

    pipeline.compilers.should have_exactly(2).items

    js_compiler = pipeline.compiler('titan.js')
    js_compiler.assets.should have_exactly(5).items
    js_compiler.toolchain.should have_exactly(2).items
    js_compiler.post_build.should have_exactly(1).items
    js_compiler.post_build_ignore_patterns.should have_exactly(2).items

    css_compiler = pipeline.compiler('titan.css')
    css_compiler.assets.should have_exactly(4).items
    css_compiler.toolchain.should have_exactly(1).items
    css_compiler.post_build_ignore_patterns.should be_empty
  end
end