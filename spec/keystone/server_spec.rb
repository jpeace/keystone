require 'rack/test'

describe "Keystone::Server" do
  include Rack::Test::Methods

  def app
    Keystone::Server
  end

  context "when loading assets in development mode" do

    it "will return a previously compiled asset" do
    	
    end

  end

end