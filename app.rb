require 'sinatra'
require 'json'

class App < Sinatra::Base

  helpers do
    def js_includes
      @scripts = {
        :js => [
          'jquery', 'amplify', 'underscore'
        ],
        :coffee => [
          :titan, {:core => [
            :amplify, :bootstrap, :presenter, :view
          ]}
        ]
      }
      script_tags = ''
      each_script @scripts[:js] do |path|
        script_tags += %{<script type="text/javascript" src="js/#{path}.js"></script>}
      end
      each_script @scripts[:coffee] do |path|
        script_tags += %{<script type="text/javascript" src="js/#{path}.js"></script>}
      end

      return script_tags
    end

    def each_script(scripts, path = '', &block)
      scripts.each do |s|
        if s.is_a? Hash
          s.each do |folder, files|
            each_script(files, "#{path}#{folder}/", &block)
          end
        else
          block.call("#{path}#{s}")
        end
      end
    end
  end

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