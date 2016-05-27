require 'sinatra'
require 'json'
require 'net/http'
require 'httparty'
require 'digest/md5'

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

    result = getDescription(@character)

    '{
      "version": "1.0",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": result
        },
        "shouldEndSession": true
      }
    }'
  end
end

get '/api-key-hash' do 
  name = 'Batman'
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


def queryAPI(name)

  api_key = 'b9bcb26854f616624e110c29e43b133c'
  private_key = '53e0c3ba58218ff98e19d562e57771fdf439e9cf'

  ts = Time.now.strftime("%Y-%m-1")
  #puts ts
  # private key + public key
  hash = Digest::MD5.hexdigest(ts + private_key + api_key)
  puts hash 

  url = 'http://gateway.marvel.com:80/v1/public/characters?name=' + name + '&ts=' + ts + '&apikey=b9bcb26854f616624e110c29e43b133c&hash=' + hash
  #puts url
  return HTTParty.get(url)
 
end 

