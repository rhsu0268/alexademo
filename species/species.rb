
class Species
  def initialize()
  end


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