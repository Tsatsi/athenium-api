require 'grape'
require_relative '../domain/book_lookup'

module Atheneum
  module API
    class BookAPI < ::Grape::API
      version 'v1', using: :path
      format :json
      default_format :json

      namespace :book do
        route_param :isbn_code do
          get :lookup do
            book = Atheneum::Domain::BookLookup.new isbn: params[:isbn_code]
            book.lookup.to_h
          end

          post :scan do
            user = Atheneum::Model::User.find(params[:user_id])
            library = Atheneum::Model::Library.find(params[:library_id])
            user.bookshelf.scan(isbn: params[:isbn_code], library: library)
            {}
          end
        end
      end
    end
  end
end