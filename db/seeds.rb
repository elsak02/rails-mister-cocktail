# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts "Destroying cocktails"
Cocktail.destroy_all
puts "Destroying ingredients"
Ingredient.destroy_all


require 'json'
require 'open-uri'

puts "Creating ingredients"
url = 'https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list'
ingredients_serialized = open(url).read
ingredients = JSON.parse(ingredients_serialized)

ingredients['drinks'].each { |ingredient| Ingredient.create(name: ingredient['strIngredient1']) }

puts "Creating cocktails"
url_cocktails = 'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail'
cocktails_serialized = open(url_cocktails).read
cocktails = JSON.parse(cocktails_serialized)

cocktails['drinks'].each do |cocktail|

  file = URI.open(cocktail['strDrinkThumb'])
  drink = Cocktail.create(name: cocktail['strDrink'])
  drink.photo.attach(io: file, filename: 'cocktail.jpg', content_type: 'image/jpg')
  id = cocktail['idDrink']


  url_detail = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{id}"
  cocktail_details_serialized = open(url_detail).read
  cocktail_details = JSON.parse(cocktail_details_serialized)

  cocktail_details['drinks'].each do |detail|
    n = 1
    ingredient_name = detail["strIngredient#{n}"]
    until ingredient_name.nil?
      search_ingr = Ingredient.where(name: ingredient_name)
      ingr = search_ingr.empty? ? Ingredient.create(name: ingredient_name) : search_ingr[0]
      Dose.create(description: detail["strMeasure#{n}"], cocktail_id: drink.id, ingredient_id: ingr.id)
      n += 1
      ingredient_name = detail["strIngredient#{n}"]
    end
  end
end
