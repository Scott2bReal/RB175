require 'sinatra'
require 'sinatra/reloader' if development?
require 'redcarpet'
require 'tilt/erubis'

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

before do
  @root = File.expand_path("..", __FILE__)
  @files = Dir.glob(@root + "/data/*").map { |path| File.basename(path) }.sort
end

get '/' do
  erb :index
end

def error_for_file_request(file_name)
  @files.include?(file_name) ? nil : "#{file_name} does not exist"
end

def load_file_content(path)
  p path
  content = File.read(path)

  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    render_markdown(content)
  end
end

def render_markdown(text)
  Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text)
end

get '/:file_name' do
  error = error_for_file_request(params[:file_name])
  path = @root + "/data/#{params[:file_name]}"

  if error
    session[:error] = error
    redirect '/'
  else
    load_file_content(path)
  end
end

get '/:filename/edit' do
  path = @root + "/data/#{params[:filename]}"
  @file_content = File.read(path)
  erb :edit
end

post '/:filename/edit' do
end
