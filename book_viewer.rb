require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index { |par, index| "<p id=#{index}>#{par}</p>" }.join
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  redirect "/" unless (1..@contents.size).cover? number

  text = File.read("data/chp#{number}.txt")

  @title = "Chapter #{number}"
  @chapter = in_paragraphs(text)
  @chapter_title = "Chapter #{number}: #{@contents[number.to_i - 1]}"

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get "/search" do
  @results = []
  
  search_chapters unless params[:query].nil?

  erb :search
end

def search_chapters
  each_chapter do |title, number, text|
    chapter_results = {title: title, chapter_num: number, text: [], ids: []}
      
    text.split("\n\n").each_with_index do |paragraph, index|
       matches = paragraph.match(params[:query])

      if matches
        chapter_results[:text] << paragraph.gsub(params[:query], "<strong>#{params[:query]}</strong>")
        chapter_results[:ids] << index
      end
    end

    @results << chapter_results if chapter_results[:text].any?
  end
end

def each_chapter
  @contents.each_with_index do |title, index|
    number = index + 1
    text = File.read("data/chp#{number}.txt")
    yield(title, number, text)
  end
end

not_found do
  redirect "/"
end
