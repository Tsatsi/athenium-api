require 'grape'

module Atheneum
  module API
    class LibraryAPI < ::Grape::API
      version 'v1', using: :path
      format :json
      default_format :json

      namespace :library do
        post :geo_locate do
          location = params[:location]
          library = Library.close_to(location: location)
          library ? library.to_h : error!("Could not find a library close by", 404)
        end


        route_param :library_id do
          get :checked_in do
            library = Atheneum::Model::Library.find(params[:library_id])
            library.books.checked_in.all()
          end
        end
      end
    end
  end
end