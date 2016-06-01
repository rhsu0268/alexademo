
class Films
  def initialize()
  end


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