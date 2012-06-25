require 'sinatra'
require 'json'

class App < Sinatra::Base

  get '/js/?*?/:name.js' do
    content_type 'text/javascript', :charset => 'utf-8'
    coffee(:"coffee/#{params[:splat].join('/')}/#{params[:name]}")
  end

  get '/' do
    erb :main
  end

  get '/load/:id' do
    if params[:id].to_i <= 0
      return {
        :success => false,
        :message => 'Fucked up dummy'
      }.to_json
    end

    name = if params[:id].to_i > 10
              'Jarrod'
            else
              'Peace'
            end
    {
      :success => true,
      :data => {
        :name => name,
        :age => params[:id].to_i
      }
    }.to_json
  end
end