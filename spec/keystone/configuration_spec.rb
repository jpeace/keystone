describe Keystone::PipelineConfiguration do
  it "can be initialized through a configuration script" do
    config = described_class.from_file("#{File.dirname(__FILE__)}/../environment/assets.rb")

    config.asset_path.should eq ENV['ASSET_PATH']
    config.tool_modules.should include(TestObjects::AssetTools)
    config.assets.should have_exactly(2).items

    js_asset = config.assets.find {|a| a.name == 'titan.js'}
    js_asset.scan_paths.should include('js')
    js_asset.scan_paths.should include('coffee')
    js_asset.tools.should include(Keystone::AssetTools::Coffeescript)
    js_asset.tools.should include(Keystone::AssetTools::Require)
    js_asset.post_build_steps.should include(Keystone::AssetTools::Closure)

    css_asset = config.assets.find {|a| a.name == 'titan.css'}
    css_asset.scan_paths.should include('css')
    css_asset.scan_paths.should include('scss')
    css_asset.tools.should include(Keystone::AssetTools::Sassy)
  end
end