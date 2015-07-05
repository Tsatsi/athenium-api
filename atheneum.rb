require 'vacuum'
require 'json'
require 'mongoid'
require 'mongoid/geospatial'

require_relative './mongoid_ext/array_or_string'

require_relative './model/book'
require_relative './model/library'
require_relative './model/bookshelf'
require_relative './model/user'

require_relative './domain/book_lookup'

require_relative './api/bookshelf_api'
require_relative './api/book_api'
require_relative './api/library_api'

Mongoid.load!(File.dirname(__FILE__) + '/config/mongoid.yml')

if ENV["SEEDME"]
  library = Atheneum::Model::Library.create!(:name => "Test library")
  user = Atheneum::Model::User.create!
  bookshelf = Atheneum::Model::Bookshelf.create!(:user => user)
  puts library.id
  puts user.id
end