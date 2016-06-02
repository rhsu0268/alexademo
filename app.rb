require 'sinatra'
require 'json'
require 'net/http'
require 'httparty'
require 'digest/md5'
require 'rack/env'
#require './marvel/marvel'
require  './character/character'
require  './films/films'
#use Rack::Env, envfile: 'config/local_env.yml'

post '/' do
  request.body.rewind
  @request_payload = JSON.parse request.body.read

  puts "---REQUEST PAYLOAD---"
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
        "shouldEndSession": true
      }
    }'
  elsif @request_payload['request']['intent']['name'] == 'AMAZON.CancelIntent'

    # response = {
  
    #   "version": "1.0",
    #   "response": {
    #     "outputSpeech": {
    #       "type": "PlainText",
    #       "text": "Goodbye. See you later..."
    #      },
    #     "shouldEndSession": true
    #     }
    #   }
    #   JSON.generate(response)
    response = returnJSON("Goodbye. See you later...", true)
    JSON.generate(response)
  elsif defined?(@request_payload['session']['attributes']['input'])

    @name = @request_payload['session']['attributes']['input']
    puts @name
    puts "You saved an attribute"
    characters = getAllCharacters()
    result = getCharacterHeight(characters, @name)

    # response = {
  
    #   "version": "1.0",
    #   "response": {
    #     "outputSpeech": {
    #       "type": "PlainText",
    #       "text": result
    #      },
    #     "shouldEndSession": false
    #     }
    #   }
    # JSON.generate(response)
    response = returnJSON(result, false)
    JSON.generate(response)
  else

    puts "---NEW SESSION---"
    @input = @request_payload['request']['intent']['slots']['person']['value']
    puts @input

      #species = getSpecies()
      #specie = getSpecie(species, @input)


      films = getFilms()
      film = isMovie(@input)
      formattedFilm = getFilmCrawl(films, film)

      #planets = getPlanets()
      #planet = getPlanet(planets, @input)

      characters = getAllCharacters()
      #character = getCharacterInfoString(characters, @input)
      character = getCharacterName(characters, @input)


      #if specie != "Sorry. I cannot find that species."
        #result = specie
      if formattedFilm != "Sorry. I cannot find that film."
        result = formattedFilm
      #elsif planet != "Sorry. I cannot find that planet."
        #result = planet
      elsif character != "Sorry. I cannot find that character."
        result = character
      else
        result = "I don't know what you are talking about. Try again."
      end 
  

      # response = {
    
      #   "version": "1.0",
      #   "sessionAttributes": {
      #     "input": @input

      #   },
      #   "response": {
      #     "outputSpeech": {
      #       "type": "PlainText",
      #       "text": result
      #      },
      #     "shouldEndSession": false
      #   }
      # }
      # JSON.generate(response)
      response = storeSessionAttribute(@input, result)
      JSON.generate(response)

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

get '/get-json' do
  #puts returnJSON("hello world", true)
  puts storeSessionAttribute("Luke Skywalker", "Test")
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

 


def returnJSON(text, option)
    json = JSON.parse(
    '{
  
    "version": "1.0",
    "response": {
      "outputSpeech": {
        "type": "PlainText",
        "text": " ' + text + ' "
       },
      "shouldEndSession": " ' + to_sb(option) + ' "
      }
    }')
end 


def storeSessionAttribute(input, result)
  json = JSON.parse(
  '{

    "version": "1.0",
    "sessionAttributes": {
      "input": " ' + input + ' "

    },
    "response": {
      "outputSpeech": {
        "type": "PlainText",
        "text": " ' + result + ' "
       },
      "shouldEndSession": " ' + to_sb(false) + ' "
    }
  }')
end 

def to_sb(option)
  if option == true
    return 'true'
  else
    return 'false'
  end 
end 