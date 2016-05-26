require 'sinatra'
require 'json'

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
    @sku_amount = @request_payload['request']['intent']['slots']['Item']['value']
    puts @sku_amount

    '{
      "version": "1.0",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "There are 12 units of ' + @sku_amount + ' in stock."
        },
        "shouldEndSession": true
      }
    }'
  end
end
