describe Keystone::Dsl::AssetExpression do
  subject { described_class.new(Keystone::AssetConfiguration.new, :tool_modules => [TestObjects::AssetTools]) }

  context "when setting scan paths" do
    it "correctly sets the paths" do
      subject.scan "#{asset_path}/css", "#{asset_path}/js"
      
      subject.config.scan_paths.should include("#{asset_path}/css")
      subject.config.scan_paths.should include("#{asset_path}/js")
    end

    it "throws an exception if any of the paths do not exist" do
      expect { subject.scan '/does/not/exist' }.to raise_error(Keystone::ConfigurationError)
    end
  end

  context "when configuring the toolchain" do
    it "correctly builds the toolchain" do
      subject.toolchain :replace_qs, :replace_caps

      subject.config.tools.should include(TestObjects::AssetTools::ReplaceQs)
      subject.config.tools.should include(TestObjects::AssetTools::ReplaceCaps)
    end

    it "throws an exception if a tool cannot be found" do
      expect { subject.toolchain :not_here }.to raise_error(Keystone::ConfigurationError)
    end
  end

  context "when adding post-build steps" do
    it "correctly adds the steps" do
      subject.post_build :double_string, :replace_caps

      subject.config.post_build_steps.should include(TestObjects::AssetTools::DoubleString)
      subject.config.post_build_steps.should include(TestObjects::AssetTools::ReplaceCaps)
    end

    it "throws an exception if a tool cannot be found" do
      expect { subject.post_build :not_here }.to raise_error(Keystone::ConfigurationError)
    end
  end
end