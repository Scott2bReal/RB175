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
      { number: paragraph_number, text: paragraph }
    end
  end

  def each_chapter
    @contents.each_with_index do |name, idx|
      chapter_number = idx + 1
      text = File.read("./data/chp#{chapter_number}.txt")
      yield name, chapter_number, text
    end
  end

  def chapters_matching(query)
    results = []

    return results if !query || query.empty?

    each_chapter do |name, number, text|
      if text.match?(/#{query.downcase}/i)
        results << {name: name, number: number, text: in_paragraphs(text)}
      end
    end

    results
  end

  def highlight(query, text)
    text.gsub(/#{query}/i, "<b>#{query}</b>")
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

get "/search" do
  @matching_chapters = chapters_matching(params[:query])

  erb :search
end
