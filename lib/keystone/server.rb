require 'sinatra'

module Keystone
  class Server < ::Sinatra::Base
    class << self
      def pipeline=(pipeline)
        @@pipeline = pipeline
      end
    end

    get '*' do
      params[:splat].inspect
    end
  end
end