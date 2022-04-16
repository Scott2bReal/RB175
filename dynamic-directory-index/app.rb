require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/*" do
  files = Dir.glob("./public/*").map { |path| File.basename(path) }.sort
  p params
  @files = params['reverse'] ? files.reverse : files
  erb :home
end
