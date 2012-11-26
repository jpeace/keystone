describe Keystone::Dsl::AssetExpression do
  subject { 
    described_class.new(Keystone::AssetConfiguration.new('asset'), 
      :tool_modules => [TestObjects::AssetTools],
      :asset_path => asset_path) 
  }

  context "when setting scan paths" do
    it "correctly sets the paths" do
      subject.scan "css", "js"
      
      subject.config.scan_paths.should include "css"
      subject.config.scan_paths.should include "js"
    end

    it "throws an exception if any of the paths do not exist" do
      expect { subject.scan '/does/not/exist' }.to raise_error Keystone::ConfigurationError
    end
  end

  context "when configuring the toolchain" do
    it "correctly builds the toolchain" do
      subject.toolchain :replace_qs, :replace_caps

      subject.config.tools.should include TestObjects::AssetTools::ReplaceQs
      subject.config.tools.should include TestObjects::AssetTools::ReplaceCaps
    end

    it "throws an exception if a tool cannot be found" do
      expect { subject.toolchain :not_here }.to raise_error Keystone::ConfigurationError
    end
  end

  context "when adding post-build steps" do
    it "correctly adds the steps" do
      subject.post_build :double_string, :replace_caps

      subject.config.post_build_steps.should include TestObjects::AssetTools::DoubleString
      subject.config.post_build_steps.should include TestObjects::AssetTools::ReplaceCaps
    end

    it "throws an exception if a tool cannot be found" do
      expect { subject.post_build :not_here }.to raise_error Keystone::ConfigurationError
    end
  end

  context "when adding post-build ignore patterns" do
    it "correctly adds a single pattern" do
      subject.skip_post_build_for /pattern/
      subject.config.post_build_ignore_patterns.should have_exactly(1).items
      subject.config.post_build_ignore_patterns.first.should eq /pattern/
    end

    it "works with strings" do
      subject.skip_post_build_for 'pattern'
      subject.config.post_build_ignore_patterns.first.should eq /^pattern$/
    end

    it "works with multiple patterns" do
      subject.skip_post_build_for /regex/, 'string'
      subject.config.post_build_ignore_patterns.should have_exactly(2).items
      subject.config.post_build_ignore_patterns.should include /regex/
      subject.config.post_build_ignore_patterns.should include /^string$/
    end
  end
end