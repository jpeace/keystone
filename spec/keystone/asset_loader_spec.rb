describe Keystone::AssetLoader do
  
  _cut = described_class
  subject { described_class.new("#{File.dirname(__FILE__)}/../environment/assets") }

  context "when determining content types from files" do
    it "recognizes coffeescript files" do
      _cut.type_from_filename('script.coffee').should eq :coffee
    end
    it "recognizes javascript files" do
      _cut.type_from_filename('script.js').should eq :javascript
    end
    it "recognizes sassy css files" do
      _cut.type_from_filename('styles.scss').should eq :sassy
    end
    it "recognizes css files" do
      _cut.type_from_filename('styles.css').should eq :css
    end
    it "defaults to unknown" do
      _cut.type_from_filename('settings.cfg').should eq :unknown
    end
    it "works with no extension" do
      _cut.type_from_filename('license').should eq :unknown
    end
    it "works with dots in the filename" do
      _cut.type_from_filename('lib.min.js').should eq :javascript
    end
  end

  context "when determining names from files" do
    it "ignores the extension" do
      _cut.name_from_filename('script.js').should eq 'script'
    end

    it "ignores version and extra info" do
      _cut.name_from_filename('lib.1.3.4.min.js').should eq 'lib'
    end
  end

  context "when scanning folders" do
    it "finds all assets" do
      subject.scan!('css')
      subject.assets.should have_exactly(3).items
    end

    it "can pull assets by type" do
      subject.scan!('css')
      subject.assets(:css).should have_exactly(2).items
      subject.assets(:unknown).should have_exactly(1).items
    end

    it "can pull assets by name" do
      subject.scan!('css')
      subject.assets('style1').first.should be_is_a(Keystone::Asset)
    end

    it "can pull a single asset by name and path" do
      subject.scan!('js')
      subject.asset('lib1/js2').should be_is_a(Keystone::Asset)
    end

    it "correctly reads assets" do
      subject.scan!('css')

      readme_file = subject.asset('readme')
      readme_file.should be_is_a(Keystone::Asset)
      readme_file.name.should eq 'readme'
      readme_file.path.should eq ''
      readme_file.content.should eq 'Read Me!!!'
    end

    it "scans subfolders" do
      subject.scan!('js')

      subject.assets.should have_exactly(4).items
      
      js1 = subject.asset('js1')
      js1.type.should eq :javascript
      js1.content.should eq 'var js1;'
      js1.path.should eq ''

      js2 = subject.asset('lib1/js2')
      js2.type.should eq :javascript
      js2.content.should eq 'var js2;'
      js2.path.should eq 'lib1'

      support = subject.asset('lib1/support/support')
      support.type.should eq :javascript
      support.content.should eq 'var support;'
      support.path.should eq 'lib1/support'
    end
  end
end