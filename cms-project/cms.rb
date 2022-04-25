require 'bcrypt'
require 'fileutils'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'redcarpet'
require 'tilt/erubis'
require 'yaml'

def signed_in?
  return true if session[:username]
  false
end

def redirect_to_index_with_error_message
  session[:error] = "You must be signed in to do that"
  redirect '/'
end

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

def credentials_path
  if ENV["RACK_ENV"] == 'test'
    File.expand_path("../test/", __FILE__)
  else
    File.expand_path("../", __FILE__)
  end
end

def load_user_credentials
  path = if ENV["RACK_ENV"] == 'test'
           File.expand_path('../test/users.yml', __FILE__)
         else
           File.expand_path('../users.yml', __FILE__)
         end

  YAML.load_file(path)
end

def valid_login?(username, password)
  valid_logins = load_user_credentials

  if valid_logins.key?(username)
    bcrypt_password = BCrypt::Password.new(valid_logins[username])
    bcrypt_password == password
  else
    false
  end
end

def error_for_new_user_form(username, password, verify_password)
  if !valid_new_username_length?(username)
    "Username is too long"
  elsif username_already_exists?(username)
    "The username #{username} already exists."
  elsif !new_passwords_match?(password, verify_password)
    "Passwords must match"
  end
end

def valid_new_username_length?(username)
  (4..12).cover? username.size
end

def username_already_exists?(username)
  load_user_credentials.key?(username)
end

def new_passwords_match?(password, verify_password)
  password == verify_password
end

def create_bcrypt_password(password)
  BCrypt::Password.create(password)
end

def create_new_user(username, password)
  credentials = load_user_credentials
  credentials[username] = create_bcrypt_password(password).to_str
  update_credentials_file(credentials)
end

def delete_existing_user(username)
  credentials = load_user_credentials
  credentials.delete(username)
  update_credentials_file(credentials)
end

def update_credentials_file(new_credentials)
  File.write(File.join(credentials_path, 'users.yml'), new_credentials.to_yaml)
end

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

before do
  @root = File.expand_path("..", __FILE__)
  @files = Dir.glob("#{data_path}/*").map { |path| File.basename(path) }.sort
end

# View create user account page
get '/users/signup' do
  erb :signup
end

# Submit create new user form
post '/users/signup/create' do
  username = params[:new_username]
  password = params[:new_password]
  verify_password = params[:verify_password]

  error = error_for_new_user_form(username, password, verify_password)

  if error
    session[:error] = error
    status 422
    erb :signup
  else
    create_new_user(username, password)
    session[:success] = "Account '#{username}' created"
    redirect '/users/signin'
  end
end

get '/users/:username/delete' do
  erb :delete_account
end

# Delete user account
post '/users/:current_user/delete' do
  username = session[:username]

  if valid_login?(username, params[:password])
    delete_existing_user(username)
    session[:username] = nil
    session[:success] = "The user '#{username}' was deleted"
    redirect '/'
  else
    session[:error] = "The password you entered was incorrect."
    status 422
    erb :delete_account
  end
end

# View index
get '/' do
  # session[:signed_in?] = true if session[:username]
  erb :index
end

# If not logged in, display sign in page
get '/users/signin' do
  session[:username] ? (redirect '/') : (erb :sign_in)
end

# Submit login form
post '/users/signin' do
  username = params[:username]
  password = params[:password]

  if valid_login?(username, password)
    session[:username] = username
    session[:success] = "Welcome!"
    redirect '/'
  else
    session[:error] = "Invalid Credentials"
    status 422
    erb :sign_in
  end
end

# Sign Out
post '/users/signout' do
  session[:username] = nil
  session[:success] = "You have been signed out."
  redirect '/'
end

# View create new file page
get '/new' do
  redirect_to_index_with_error_message unless signed_in?

  erb :new
end

def increment_filename_for_duplication(filename)
  if filename.match?(/\d+.txt|\d+.md/)
  end
end

# TODO Duplicate existing file
post '/:filename/duplicate' do
  new_filename = increment_filename_for_duplication(params[:filename])
  session[:success] = "#{params[:filename]} was copied to #{new_filename}"
  redirect '/'
end

# Create new file
post '/create' do
  redirect_to_index_with_error_message unless signed_in?

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
  redirect_to_index_with_error_message unless signed_in?

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
  redirect_to_index_with_error_message unless signed_in?

  path = @root + "/data/#{params[:filename]}"
  @file_content = File.read(path)
  erb :edit
end

# Edit file contents
post '/:filename' do
  redirect_to_index_with_error_message unless signed_in?

  path = @root + "/data/#{params[:filename]}"
  File.write(path, params[:edit])
  session[:success] = "#{params[:filename]} has been edited."
  redirect '/'
end
