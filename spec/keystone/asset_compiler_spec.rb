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
      subject.asset('asset2').content.should eq '*uite doubled'
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

  context "when building a package" do
    it "chooses the type of the first asset when determining package type" do
      c = described_class.new([], [asset1, asset3])
      c.package_type.should eq :boring

      c = described_class.new([], [asset2, asset3])
      c.package_type.should eq :too_short
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

      package.name.should eq 'boring'
      package.type.should eq :boring
      package.content.should eq "ow -uick is -haq?\nuite doubled\n"
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