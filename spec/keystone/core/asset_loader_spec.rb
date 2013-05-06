describe Keystone::AssetLoader do
  
  _cut = described_class
  subject { described_class.new("#{File.dirname(__FILE__)}/../../environment/assets") }

  context "when determining content types from files" do
    it "recognizes coffeescript files" do
      _cut.type_from_filename('script.coffee').should eq Keystone::Types::Coffeescript
    end
    it "recognizes javascript files" do
      _cut.type_from_filename('script.js').should eq Keystone::Types::Javascript
    end
    it "recognizes sassy css files" do
      _cut.type_from_filename('styles.scss').should eq Keystone::Types::Sassy
    end
    it "recognizes css files" do
      _cut.type_from_filename('styles.css').should eq Keystone::Types::Css
    end
    it "defaults to unknown" do
      _cut.type_from_filename('settings.cfg').should eq Keystone::Types::Unknown
    end
    it "works with no extension" do
      _cut.type_from_filename('license').should eq Keystone::Types::Unknown
    end
    it "works with dots in the filename" do
      _cut.type_from_filename('lib.min.js').should eq Keystone::Types::Javascript
    end
  end

  context "when determining extension from content type" do
    it "handles coffeescript files" do
      _cut.extension_from_type(Keystone::Types::Coffeescript).should eq '.coffee'
    end

    it "handles javascript files" do
      _cut.extension_from_type(Keystone::Types::Javascript).should eq '.js'
    end

    it "handles sassy css files" do
      _cut.extension_from_type(Keystone::Types::Sassy).should eq '.scss'
    end

    it "handles css files" do
      _cut.extension_from_type(Keystone::Types::Css).should eq '.css'
    end

    it "defaults to nothing" do
      _cut.extension_from_type(Keystone::Types::Unknown).should eq ''
    end
  end

  context "when determining names from files" do
    it "ignores the extension" do
      _cut.name_from_filename('script.js').should eq 'script'
    end

    it "ignores version and extra info" do
      _cut.name_from_filename('lib-1.3.4.min.js').should eq 'lib'
    end
  end

  context "when scanning folders" do
    css_scan_path = Keystone::ScanPath.new('css')
    js_scan_path = Keystone::ScanPath.new('js')

    it "finds all assets" do
      subject.scan!(css_scan_path)
      subject.assets.should have_exactly(3).items
    end

    it "can pull assets by type" do
      subject.scan!(css_scan_path)
      subject.assets(:css).should have_exactly(2).items
      subject.assets(:unknown).should have_exactly(1).items
    end

    it "can pull assets by name" do
      subject.scan!(css_scan_path)
      subject.assets('style1').first.should be_instance_of Keystone::Asset
    end

    it "can pull a single asset by name and path" do
      subject.scan!(js_scan_path)
      subject.asset('lib1/js2').should be_instance_of Keystone::Asset
    end

    it "correctly reads assets" do
      subject.scan!(css_scan_path)

      readme_file = subject.asset('readme')
      readme_file.should be_instance_of Keystone::Asset
      readme_file.name.should eq 'readme'
      readme_file.path.should eq ''
      readme_file.content.should eq 'Read Me!!!'
      readme_file.location_on_disk.should eq File.expand_path("#{File.dirname(__FILE__)}/../../environment/assets/css/readme.txt")
    end

    it "scans subfolders" do
      subject.scan!(js_scan_path)

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

    it "scans multiple folders" do
      subject.scan!(css_scan_path)
      subject.scan!(js_scan_path)

      subject.assets.should have_exactly(7).items
    end

    it "correctly builds paths with a subfolder as root" do
      subject.scan!(Keystone::ScanPath.new('js/lib1'))

      subject.assets.should have_exactly(3).items
      
      js2 = subject.asset('js2')
      js2.path.should eq ''

      support = subject.asset('support/support')
      support.path.should eq 'support'
    end

    it "ignores dot files" do
      subject.scan!(Keystone::ScanPath.new('dotfiles'))
      subject.assets.should have_exactly(1).items
    end

    it "sets the namespace of assets appropriately" do
      subject.scan!(Keystone::ScanPath.new('js', 'topnamespace'))

      subject.assets.should have_exactly(4).items
      
      js1 = subject.asset('js1')
      js1.namespace.should eq 'topnamespace'

      js2 = subject.asset('lib1/js2')
      js2.namespace.should eq 'topnamespace/lib1'

      support = subject.asset('lib1/support/support')
      support.namespace.should eq 'topnamespace/lib1/support'
    end

    it "will append subfolders to the namespace" do
      subject.scan!(Keystone::ScanPath.new('js', 'topnamespace'))

      js2 = subject.asset('lib1/js2')
      js2.namespace.should eq 'topnamespace/lib1'

      support = subject.asset('lib1/support/support')
      support.namespace.should eq 'topnamespace/lib1/support'
    end
  end
end