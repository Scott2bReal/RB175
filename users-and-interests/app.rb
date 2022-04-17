require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @users = YAML.load(File.read('users.yaml'))
  @total_users = @users.keys.size
end

helpers do
  def count_interests
    total_interests = 0

    @users.each do |name, info|
      total_interests += info[:interests].size
    end

    total_interests
  end
end

get '/' do
  redirect '/users'
end

get '/users' do
  @user_names = @users.keys.map(&:capitalize)
  erb :users
end

get '/users/:name' do
  @name = params[:name].downcase.to_sym
  @info = @users[@name]
  erb :user_page
end
