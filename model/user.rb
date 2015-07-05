module Atheneum
  module Model
    class User
      include Mongoid::Document
      has_one :bookshelf
    end
  end
end