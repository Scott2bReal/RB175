require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

# Define Poll class
class Poll
  def initialize(id, name, options=[])
    @id = id
    @name = name
    @options = options
  end

  attr_reader :id, :name
  attr_accessor :options
end

class PollOptions
  def initialize(name)
  end
end

# Define User class
# Won't be used until polling is fleshed out a bit
class User
  def initialize(name, permission_level, password_hash)
    @name = name
    @level = permission_level
    @password = password_hash
  end
end

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  @polls = [Poll.new(1, 'New Poll')]
end

# Display homepage
get '/' do
  redirect '/polls'
end

# Display list of polls
get '/polls' do
  # @polls << Poll.new(1, 'New Poll')
  erb :polls
end

# Display specific poll
get '/polls/:pollid' do
  @poll = @polls.find { |poll| poll.id == params[:pollid].to_i }

  erb :poll
end
