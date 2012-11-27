describe "classes mixing in the AssetTool module" do
  include TestObjects::AssetTools
  include TestObjects::Assets

  it "return an asset when run" do
    replace_qs.run([asset1]).first.should be_is_a(Keystone::Asset)
  end

  it "preserves the path" do
    replace_qs.run([asset1]).first.path.should eq 'path/to/file'
  end

  it "preserves the location on disk" do
    replace_qs.run([asset1]).first.location_on_disk.should eq '/home/test/path/to/file'
  end
    
  context "when defining should_run?" do
    it "can return false to be skipped" do
      double_string.run([asset1]).first.content.should eq 'How Quick is Shaq?'
    end
  end

  context "when defining transform" do
    it "can return a string to transform contents" do
      replace_qs.run([asset1]).first.content.should eq 'How *uick is Sha*?'
    end

    it "can return an array to transform type and contents" do
      asset = double_string.run([asset2]).first
      asset.type.should eq :doubled
      asset.content.should eq 'QQuuiittee  ddoouubblleedd'
    end
  end
end