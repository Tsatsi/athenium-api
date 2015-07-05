module Atheneum
  module Model
    class Library
      include Mongoid::Document
      include Mongoid::Geospatial

      field :name, :type => String
      geo_field :location

      has_many :books

      # See http://stackoverflow.com/questions/7837731/units-to-use-for-maxdistance-and-mongodb
      def self.close_to(location:)
        kilometers = 0.1
        radius_kilometer = 111.2
        location = [location[0].to_f, location[1].to_f]
        lib = Library.geo_near(location).max_distance(kilometers/radius_kilometer)
        lib.first
      end

      def check_in(isbn:)
        book = self.books.find_by_isbn(isbn).first()

        if !book
          book = Atheneum::Domain::BookLookup.new(isbn: isbn).lookup
          self.books << book
        end
        book.check_in!
      end

      def check_out(isbn:)
        if checked_in?(isbn: isbn)
          book = self.books.find_by_isbn(isbn).first()
          book.check_out!
          true
        else
          false
        end
      end

      def checked_in?(isbn:)
        book_with_isbn = self.books.where(isbn: isbn, status: Book::CHECKED_IN).first()
        book_with_isbn != nil
      end

      def checked_out?(isbn:)
        book_with_isbn = self.books.where(isbn: isbn, status: Book::CHECKED_OUT).first()
        book_with_isbn != nil
      end

      def checked_in_book_count
        self.books.checked_in.count()
      end

      def to_h
        {
            :name => name,
            :location => location
        }
      end
    end
  end
end