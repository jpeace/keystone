describe "classes mixing in the AssetTool module" do
  include TestObjects::AssetTools
  include TestObjects::Assets

  it "return an asset when run" do
    replace_qs.run(asset1).should be_is_a(Keystone::Asset)
  end
    
  context "when defining should_run?" do
    it "can return false to be skipped" do
      double_string.run(asset1).content.should eq 'How Quick is Shaq?'
    end
  end

  context "when defining transform" do
    it "can return a string to transform contents" do
      replace_qs.run(asset1).content.should eq 'How *uick is Sha*?'
    end

    it "can return an array to transform type and contents" do
      asset = double_string.run(asset2)
      asset.type.should eq :doubled
      asset.content.should eq 'QQuuiittee  ddoouubblleedd'
    end
  end
end