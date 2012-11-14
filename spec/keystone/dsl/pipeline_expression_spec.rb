describe Keystone::Dsl::PipelineExpression do
  context "when setting the asset path" do
    it "correctly sets the path" do
      subject.assets_are_in asset_path
      subject.config.asset_path.should eq asset_path
    end

    it "throws an exception if the path does not exist" do
      expect { subject.assets_are_in '/does/not/exist' }.to raise_error(Keystone::ConfigurationError)
    end
  end

  context "when configuring asset tool modules" do
    it "automatically includes default tool modules" do
      subject.config.tool_modules.should include(Keystone::AssetTools)
    end

    it "allows for additional modules to be included" do
      subject.add_tools TestObjects::AssetTools
      subject.config.tool_modules.should include(TestObjects::AssetTools)
    end
  end

  it "allows for asset configuration" do
    subject.asset do |a|
      a.should be_a(Keystone::Dsl::AssetExpression)
    end
  end
end