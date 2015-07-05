require 'rack'
require_relative './atheneum'

class Atheneum::API::AllAPI < Grape::API
  mount Atheneum::API::BookAPI
  mount Atheneum::API::BookshelfAPI
  mount Atheneum::API::LibraryAPI
end

run Atheneum::API::AllAPI