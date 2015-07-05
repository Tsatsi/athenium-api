require 'grape'

module Atheneum
  module API
    class BookshelfAPI < ::Grape::API
      version 'v1', using: :path
      format :json
      default_format :json


      namespace :bookshelf do
        route_param :user_id do
          get :list do
            user = Atheneum::Model::User.find(params[:user_id])
            user.bookshelf.books.all()
          end
        end
      end

    end
  end
end