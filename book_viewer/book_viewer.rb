require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    paragraph_number = 0
    text.split("\n\n").map do |paragraph|
      paragraph_number += 1
      "<p id='paragraph#{paragraph_number}'>#{paragraph}</p>"
    end
  end

  def each_chapter
    @contents.each_with_index do |_, idx|
      chapter_number = idx + 1
      text = File.read("./data/chp#{chapter_number}.txt").downcase
      yield chapter_number, text
    end
  end

  def chapters_matching(query)
    results = []

    return results if !query || query.empty?

    each_chapter do |chapter_number, text|
      results << chapter_number if text.match?(/#{query}/)
    end

    results
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get '/chapters/:number' do
  @chapter_number = params[:number].to_i
  chapter_name = @contents[@chapter_number.to_i - 1]
  redirect "/" unless (1..@contents.size).cover?(@chapter_number)

  @title = "Chapter #{@chapter_number}: #{chapter_name}"
  @chapter = File.read("data/chp#{@chapter_number}.txt")
  erb :chapter
end

# Example of how route parameters work
# get "/show/:name" do
#   @title = "The Adventures of Sherlock Holmes"
#   @name = params[:name]
#   erb :show_name
# end

get "/search" do
  @matching_chapters = chapters_matching(params[:query])

  erb :search
end
