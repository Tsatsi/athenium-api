module Atheneum
  module Model
    class Bookshelf
      include Mongoid::Document
      belongs_to :user
      has_many :books

      def scan(isbn:, library:)
        if self.checked_in?(isbn: isbn)
          return check_out(isbn: isbn, library: library)
        else
          return check_in(isbn: isbn, library: library)
        end
      end

      def checked_in?(isbn: )
        self.books.where(isbn: isbn).first() != nil
      end

      private
      def check_in(isbn: , library: )
        return false if self.checked_in?(isbn: isbn)

        if library.checked_in?(isbn: isbn)
          library.check_out(isbn: isbn)
          book = library.books.find_by_isbn(isbn).first()
          self.books << book
          return self.save

        else
          library.check_in(isbn: isbn)
          return true
        end

      end

      def check_out(isbn:, library:)
        library.check_in(isbn: isbn)
        book = self.books.find_by_isbn(isbn).first()
        book.bookshelf = nil
        book.save!

        self.save
      end
    end
  end
end