require 'sinatra'
require 'json'
require 'net/http'
require 'httparty'
require 'digest/md5'
require 'rack/env'
#require './marvel/marvel'
#use Rack::Env, envfile: 'config/local_env.yml'

post '/' do
  request.body.rewind
  @request_payload = JSON.parse request.body.read

  puts "---REQUEST PAYLOAD---"
  puts @request_payload

  # type == LaunchRequest
  if @request_payload['request']['type'] == 'LaunchRequest'
    result = 
    {
      "version": "1.0",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "Go."
        },
        "shouldEndSession": true
      }
    }
  else
    @input = @request_payload['request']['intent']['slots']['person']['value']
    puts @input

    if @request_payload['request']['session'] != nil
      #['request']['session']['attributes']['input']
      result = "You asked for something else."
    else
      species = getSpecies()
      specie = getSpecie(species, @input)


      films = getFilms()
      film = isMovie(@input)
      formattedFilm = getFilmCrawl(films, film)

      planets = getPlanets()
      planet = getPlanet(planets, @input)

      characters = getAllCharacters()
      character = getCharacterInfoString(characters, @input)



      if specie != "Sorry. I cannot find that species."
        result = specie
      elsif formattedFilm != "Sorry. I cannot find that film."
        result = formattedFilm
      elsif planet != "Sorry. I cannot find that planet."
        result = planet
      elsif character != "Sorry. I cannot find that character."
        result = character
      else
        result = "I don't know what you are talking about. Try again."
      end 
    end 

    result = {
  
      "version": "1.0",
      "sessionAttributes": {
        "input": @input

      },
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": result
         },
        "shouldEndSession": false
      }
    }
    JSON.generate(result)
  end
end 


# Demo routes for testing purposes

# test route for query for a Star Wars character
get '/query-star-wars-character' do
  name = "Arm"
  character = queryStarWarsForCharacters(name)
  puts character
end


# test route for query for a Star Wars 
get '/query-all-characters' do
  name = "Luke Skywalker"
  characters = getAllCharacters()
  character = getCharacterName(characters, name)
end


# test route for query of one specific attribute
get '/query-for-field' do
  name = "Luke Skywalker"
  #characters = getAllCharacters()
  characters = getAllCharacters()
  character = getCharacterInfoField(characters, name, 'hair_color')
end

# test route for query of one specific character description
get '/query-for-string' do
  name = "Luke Skywalker"
  characters = getAllCharacters()
  character = getCharacterInfoString(characters, name)
end

# test route for getting the film crawl for a character
get '/get-films' do
  title = 'Return of the Jedi'
  films = getFilms()
  getFilmCrawl(films, title)

end

# test route for movies that have lower case characters in them 
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

get '/get-all-species' do
  species = getSpecies()
  getSpecie(species, 'Zabrak')
  #puts species
end 

get '/isMovie' do
  movie = isMovie("return of the jedi")
  puts movie 
end 

get '/get-all-planets' do
  name = 'Corellia'
  planets = getPlanets()
  planet = getPlanet(planets, name)
  puts planet
end

def queryStarWarsForCharacters(name)
  url = 'http://swapi.co/api/people'
  puts url 
  data = HTTParty.get(url)['results']

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



def isMovie(title)
  titleLowercase = title.downcase
  if titleLowercase == 'the force awakens' or titleLowercase == 'a new hope' or titleLowercase == 'the empire strikes back' or titleLowercase == 'attack of the clones' or titleLowercase== 'the phantom menace' or titleLowercase == 'revenge of the sith' or titleLowercase == 'return of the jedi' 
    if titleLowercase == 'attack of the clones'
        return 'Attack of the Clones'
    elsif titleLowercase == 'revenge of the sith'
        return 'Revenge of the Sith' 
    elsif titleLowercase == 'return of the jedi'
        return 'Return of the Jedi'
    else
        puts "Capitalizing "
        formattedFilm = title.split.map(&:capitalize).*' '
        puts formattedFilm
        return formattedFilm
    end
  else 
    return "Sorry. I cannot find that film."
  end 
end 

########### Marvel API Code ############
# Note that this version will not work for Alex #
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


def getSpecies()
  speciesList = []

  i = 1

  while i < 5 do 

    puts("Loop ") 
    url_page = 'http://swapi.co/api/species/?page=' + i.to_s
    puts url_page
    species = HTTParty.get(url_page)['results']
    #puts "---Characters---"
    #puts characters

    species.each do |specie|
      #puts character['name']
      speciesList << specie
    end 

    i += 1

  end 
  #puts charactersList
  return speciesList
end

def getSpecie(species, name)
  species.each do |specie|
    puts specie['name']
    if name == specie['name']
      return "You want to know about " + specie['name'] + ". The species falls under the classification " + specie['classification'] + " and designation " + specie['designation'] + "."
    end 
  end 
  return "Sorry. I cannot find that species."
end


def getPlanets()
  planetsList = []

  i = 1

  while i < 8 do 

    puts("Loop ") 
    url_page = 'http://swapi.co/api/planets/?page=' + i.to_s
    puts url_page
    planets = HTTParty.get(url_page)['results']
    #puts "---Characters---"
    #puts characters

    planets.each do |planet|
      puts planet
      planetsList << planet
    end 

    i += 1

  end 
  #puts charactersList
  return planetsList
end

def getPlanet(planets, name)
  planets.each do |planet|
    puts planet['name']
    if name == planet['name']
      return "You want to know about " + planet['name'] + "." 
    end 
  end 
  return "Sorry. I cannot find that planet."
end