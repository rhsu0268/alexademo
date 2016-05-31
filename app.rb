require 'sinatra'
require 'json'
require 'net/http'
require 'httparty'
require 'digest/md5'
require 'rack/env'
require './marvel/marvel'
#use Rack::Env, envfile: 'config/local_env.yml'

post '/' do
  request.body.rewind
  @request_payload = JSON.parse request.body.read
  puts @request_payload

  # type == LaunchRequest
  if @request_payload['request']['type'] == 'LaunchRequest'
    '{
      "version": "1.0",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "Go."
        },
        "shouldEndSession": false
      }
    }'
  else
    @character = @request_payload['request']['intent']['slots']['person']['value']
    puts @character
    
    filmOrCharacterTest = @character.downcase
    if filmOrCharacterTest == 'the force awakens' or filmOrCharacterTest == 'a new hope' or filmOrCharacterTest == 'the empire strikes back' or filmOrCharacterTest == 'attack of the clones' or filmOrCharacterTest == 'the phantom menace' or filmOrCharacterTest == 'revenge of the sith' or filmOrCharacterTest == 'return of the jedi' 

      if filmOrCharacterTest == 'attack of the clones'
        formattedFilm = 'Attack of the Clones'
        puts formattedFilm
      elsif filmOrCharacterTest == 'revenge of the sith'
        formattedFilm = 'Revenge of the Sith'
        puts formattedFilm
      elsif filmOrCharacterTest == 'return of the jedi'
        formattedFilm = 'Return of the Jedi'
        puts formattedFilm
      else
        puts filmOrCharacterTest
        puts "Capitalizing "
        formattedFilm = filmOrCharacterTest.split.map(&:capitalize).*' '
        puts formattedFilm
      end
      films = getFilms()
      result = getFilmCrawl(films, formattedFilm)
      puts "---FILMS---"
      puts result
       
    else 
      puts "---CHARACTER---"
      puts @character
      characters = getAllCharacters()
      result = getCharacterInfoString(characters, @character)
      puts "---RESULT---"
      puts result
    end 

    # result = {
  
    #   "version": "1.0",
    #   "response": {
    #     "outputSpeech": {
    #       "type": "PlainText",
    #       "text": result
    #      },
    #     "shouldEndSession": true
    #   }
    # }
    # JSON.generate(result)
  end
end 



get '/query-star-wars-character' do
  name = "Arm"
  character = queryStarWarsForCharacters(name)
  puts character
end



get '/query-all-characters' do
  name = "Luke Skywalker"
  characters = getAllCharacters()
  character = getCharacterName(characters, name)
end



get '/query-for-field' do
  name = "Luke Skywalker"
  #characters = getAllCharacters()
  characters = getAllCharacters()
  character = getCharacterInfoField(characters, name, 'hair_color')
end


get '/query-for-string' do
  name = "Luke Skywalker"
  characters = getAllCharacters()
  character = getCharacterInfoString(characters, name)
end

get '/get-films' do
  title = 'Return of the Jedi'
  films = getFilms()
  getFilmCrawl(films, title)

end


get '/get-formatted-films' do 
    filmOrCharacterTest = 'a New hope'.downcase!
    if filmOrCharacterTest == 'the force awakens' or filmOrCharacterTest == 'a new hope'
      puts filmOrCharacterTest
      puts "Capitalizing "
      formattedFilm = filmOrCharacterTest.split.map(&:capitalize).*' '
      puts formattedFilm
      films = getFilms()
      result = getFilmCrawl(films, formattedFilm)
      puts "---FILMS---"
      puts result
    end

end 

def queryStarWarsForCharacters(name)
  url = 'http://swapi.co/api/people'
  puts url 
  data = HTTParty.get(url)['results']

  #out_file = File.new("character.txt", "w")
  #out_file.puts(data)
  #out_file.close


  pages = []

  i = 1

  while i < 5 do 

    puts("Loop ")
    i += 1 
    url_page = 'http://swapi.co/api/people/?page=' + i.to_s
    puts url_page
    characters = HTTParty.get(url)['results']
    #puts characters

    pages += [characters]

  end 

  #puts pages


  # loop over data in json array
  data.each do |character|
    puts character['name']
    if name == character['name']
      return character['name']
    else
      return "Sorry. I cannot find that character."
    end 
  end 
end 


def getAllCharacters()
  charactersList = []

  i = 1

  while i < 8 do 

    puts("Loop ") 
    url_page = 'http://swapi.co/api/people/?page=' + i.to_s
    puts url_page
    characters = HTTParty.get(url_page)['results']
    #puts "---Characters---"
    #puts characters

    characters.each do |character|
      #puts character['name']
      charactersList << character
    end 

    i += 1

  end 
  #puts charactersList
  return charactersList
end 


def getCharacterName(characters, name)
  puts name
  characters.each do |character|
    puts character['name']
    if name == character['name']
      return name
    end 
  end 
  return "Sorry. I cannot find that character."
end 

def getCharacterInfoString(characters, name)
  puts name
  characters.each do |character|
    puts character['name']
    if name == character['name']
      return "You wanted to know about " + character['name'] + ". 
      The character is " + character['height'] + " centimeters tall and weighs " + character['mass'] + " kilograms." + " 
      The character has " + character['hair_color'] + " hair and " + character['skin_color'] + " skin color."
    end 
  end 
  return "Sorry. I cannot find that character."
end 


def getCharacterInfoField(characters, name, option)
  puts name 
  puts option
  characters.each do |character|
    #puts character['name']
    if name == character['name']
      return character[option]
    end 
  end 
  return "Sorry. I cannot find that character."
end 

def getFilms()
  url = 'http://swapi.co/api/films/'
  puts url 
  data = HTTParty.get(url)['results']
  return data
end 

def getFilmCrawl(films, title)
  puts title
  films.each do |film|
    #puts character['name']
    if title == film['title']
      return film['opening_crawl']
    end 
  end 
  return "Sorry. I cannot find that film."
end


get '/api-key-hash' do 
  name = 'thor'
  puts name

  response = queryAPI(name)
  puts response

end 


get '/query-api' do
  name = 'thor'
  getDescription(name)
end

def getDescription(name)
  response = queryAPI(name)
  #puts response
  #puts api_res
  puts "---Results---"

  #puts response['data']['results']
  #puts response['data']['results'][0]

  return response['data']['results'][0]['description']

end

