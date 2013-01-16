describe "classes mixing in the AssetContainer module" do
  class TestContainer
    include Keystone::AssetContainer
    def initialize
      @assets = [
        Keystone::Asset.new do |a|
          a.name = 'asset1'
          a.path = 'path'
          a.type = :javascript
        end,
        Keystone::Asset.new do |a|
          a.name = 'asset2'
          a.path = 'path/to'
          a.type = :javascript
        end,
        Keystone::Asset.new do |a|
          a.name = 'asset1'
          a.path = 'path'
          a.type = :css
        end
      ]
    end
  end

  _cut = nil
  before(:each) do
    _cut = TestContainer.new
  end

  context "when finding multiple assets" do
    it "can search by name by passing a string" do
      _cut.assets('asset1').should have_exactly(2).items
    end

    it "can search by type by passing a symbol" do
      _cut.assets(:javascript).should have_exactly(2).items
    end

    it "returns an empty array with no matches" do
      _cut.assets('not-here').should be_empty
    end
  end

  context "when finding a single asset" do
    it "finds an asset by name and path" do
      a = _cut.asset('path/to/asset2')
      a.should be_a(Keystone::Asset)
      a.name.should eq 'asset2'
    end

    it "distinguishes by type when an extension is given" do
      a = _cut.asset('path/asset1.css')
      a.should be_a(Keystone::Asset)
      a.type.should eq :css
    end

    it "returns null when no asset can be found" do
      _cut.asset('does/not/exist').should be_nil
    end
  end
end