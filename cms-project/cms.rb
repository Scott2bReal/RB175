require 'sinatra'
require 'sinatra/reloader' if development?
require 'redcarpet'
require 'tilt/erubis'

def data_path
  if ENV["RACK_ENV"] == 'test'
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def load_file_content(path)
  content = File.read(path)

  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    erb render_markdown(content)
  end
end

def render_markdown(text)
  Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text)
end

def create_document(name, content = '')
  File.open(File.join(data_path, name), 'w') do |file|
    file.write(content)
  end
end

def error_for_file_request(filename)
  @files.include?(filename) ? nil : "#{filename} does not exist"
end

def error_for_new_file_name(filename)
  if filename == ''
    "A name is required."
  elsif @files.include?(filename)
    "That file name is already in use."
  elsif !filename.match?(/\S(\.md$|\.txt$)/)
    "Files must have a valid extension (.md or .txt)"
  end
end

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

before do
  @root = File.expand_path("..", __FILE__)
  @files = Dir.glob("#{data_path}/*").map { |path| File.basename(path) }.sort
end

# View index
get '/' do
  erb :index
end

# View create new file page
get '/new' do
  erb :new
end

# Create new file
post '/create' do
  error = error_for_new_file_name(params[:filename])

  if error
    session[:error] = error
    status 422
    erb :new
  else
    create_document(params[:filename])
    session[:success] = "#{params[:filename]} was created."
    redirect '/'
  end
end

# Delete file
post '/:filename/delete' do
  File.delete(data_path + '/' + params[:filename])
  session[:success] = "#{params[:filename]} was successfully deleted."
  status 204
  redirect '/'
end

# View file
get '/:filename' do
  error = error_for_file_request(params[:filename])
  path = @root + "/data/#{params[:filename]}"

  if error
    session[:error] = error
    redirect '/'
  else
    load_file_content(path)
  end
end

# View edit page
get '/:filename/edit' do
  redirect '/new' if params[:filename] == 'new'
  path = @root + "/data/#{params[:filename]}"
  @file_content = File.read(path)
  erb :edit
end

# Edit file contents
post '/:filename' do
  path = @root + "/data/#{params[:filename]}"
  File.write(path, params[:edit])
  session[:success] = "#{params[:filename]} has been edited."
  redirect '/'
end
