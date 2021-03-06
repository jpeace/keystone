describe Keystone::AssetCompiler do
  include TestObjects::Assets

  context "with a single element toolchain" do
    subject do
      toolchain = [TestObjects::AssetTools::ReplaceQs]
      described_class.new(toolchain, [asset1, asset2])
    end

    it "compiles assets" do
      subject.compile!
      subject.asset('path/to/file/asset1').content.should eq 'How *uick is Sha*?'
      subject.asset('asset2').content.should eq 'Quite doubled'
    end
  end

  context "with a multiple element toolchain" do
    subject do
      toolchain = [TestObjects::AssetTools::ReplaceCaps, TestObjects::AssetTools::ReplaceQs]
      described_class.new(toolchain, [asset1, asset2])
    end

    it "compiles assets" do
      subject.compile!
      subject.asset('path/to/file/asset1').content.should eq '-ow -uick is -ha*?'
      subject.asset('asset2').content.should eq '-uite doubled'
    end
  end

  it "runs the toolchain using the order given" do
    c1 = described_class.new([TestObjects::AssetTools::ReplaceQs, TestObjects::AssetTools::ReplaceCaps], [asset1])
    c2 = described_class.new([TestObjects::AssetTools::ReplaceCaps, TestObjects::AssetTools::ReplaceQs], [asset1])
    
    c1.compile! && c2.compile!
    
    c1.asset('path/to/file/asset1').content.should eq '-ow *uick is -ha*?'
    c2.asset('path/to/file/asset1').content.should eq '-ow -uick is -ha*?'
  end

  it "only compiles once" do
    c = described_class.new([TestObjects::AssetTools::ShortenString], [asset2])
    c.compile!
    c.compile!
    c.asset('asset2').content.should eq 'uite doubled'
  end

  it "can be reset after being compiled" do
    class File
      class << self
        alias old_read read
        def read(filename)
          if filename == '/home/test/file2'
            'Quite doubled'
          else
            old_read(filename)
          end
        end
      end
    end
    
    c = described_class.new([TestObjects::AssetTools::ShortenString], [asset2])
    c.compile!
    c.asset('asset2').content.should eq 'uite doubled'
    c.asset('asset2').type.should eq :shortened
    c.reset!
    c.asset('asset2').content.should eq 'Quite doubled'
    c.asset('asset2').type.should eq :too_short
    
    class File
      class << self
        alias read old_read
      end
    end
  end

  it "removes assets with no disk location when resetting" do
    c = described_class.new([TestObjects::AssetTools::ShortenString], [asset3])
    c.compile!
    c.assets.should have_exactly(1).items
    c.reset!
    c.assets.should be_empty
  end

  context "when building a package" do
    it "chooses the type of the first asset when determining package type" do
      c = described_class.new([], [asset1, asset3])
      c.package_type.should eq :boring

      c = described_class.new([], [asset2, asset3])
      c.package_type.should eq :too_short
    end

    it "chooses the type of the first external asset when determining package type if main assets are empty" do
      c = described_class.new([],[], :external_assets => [asset1])
      c.package_type.should eq :boring
    end

    it "returns unknown when determining package type if main assets and external assets are empty" do
      c = described_class.new([],[])
      c.package_type.should eq Keystone::Types::Unknown
    end

    it "uses the package name given" do
      c = described_class.new([],[],:package_name => 'new_package')
      c.package_name.should eq 'new_package'
    end

    it "uses the package type for package name if no name given" do
      c = described_class.new([],[asset1])
      c.package_name.should eq 'boring'
    end

    it "builds an asset package" do
      c = described_class.new([TestObjects::AssetTools::ReplaceCaps, TestObjects::AssetTools::ShortenString], [asset1, asset2])
      package = c.build!

      package.name.should eq 'shortened'
      package.type.should eq :shortened
      package.content.should eq "ow -uick is -haq?\nuite doubled\n"
    end

    it "will not include a duplicated asset more than once" do
      c = described_class.new([], [asset1, asset2], :external_assets => [ asset1 ])
      package = c.build!
      package.content.should eq "How Quick is Shaq?\nQuite doubled\n"
    end

    it "includes external assets" do
      c = described_class.new([TestObjects::AssetTools::ReplaceCaps, TestObjects::AssetTools::ShortenString], [asset1, asset2], :external_assets => [asset3])
      package = c.build!
      package.content.should eq "ow -uick is -haq?\nuite doubled\nNot quick enough\n"
    end

    it "uses post-build steps if specified" do
      c = described_class.new([TestObjects::AssetTools::ReplaceCaps], [asset1, asset3], :post_build => [TestObjects::AssetTools::ReplaceQs])
      package = c.build!

      package.type.should eq :boring
      package.content.should eq "-ow -uick is -ha*?\n-ot *uick enough\n"
    end

    it "can skip post-build steps for certain assets" do
      c = described_class.new([TestObjects::AssetTools::ReplaceCaps], [asset1, asset3], :post_build => [TestObjects::AssetTools::ReplaceQs], :post_build_ignore_patterns => [/^asset1$/])
      package = c.build!

      package.content.should eq "-ot *uick enough\n-ow -uick is -haq?"
    end
  end
end