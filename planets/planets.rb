
class Planets
  def initialize()
  end


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