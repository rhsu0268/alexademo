
class Character
  def initialize()
  end


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
      return "What do you want to know about " + name + " ?"
    end 
  end 
  return "Sorry. I cannot find that character."
end 


def getCharacterHeight(characters, name)
  #puts name
  characters.each do |character|
    #puts character['name']
    if name == character['name']
      return "The height of " + name + " is " + character['height'] + ' centimeters. Anything else?'
    end 
  end 
  return "Sorry. I cannot find that character's height."
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


