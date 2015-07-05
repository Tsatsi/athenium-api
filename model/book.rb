module Atheneum
  module Model
    class Book
      CHECKED_IN = "checked_in"
      CHECKED_OUT = "checked_out"

      include Mongoid::Document
      field :title, :type => String
      field :isbn, :type => String
      field :asin, :type => String
      field :author, :type => ArrayOrString
      field :publisher, :type => String
      field :small_image, :type => String
      field :medium_image, :type => String
      field :large_image, :type => String
      field :status, :type => String
      belongs_to :library
      belongs_to :bookshelf

      scope :checked_in, -> { where(status: Book::CHECKED_IN) }
      scope :find_by_isbn, -> (isbn) { where(isbn: isbn) }

      def checked_in?
        self.status == Book::CHECKED_IN
      end

      def check_in
        self.status = Book::CHECKED_IN
      end

      def check_in!
        self.check_in
        self.save!
      end

      def checked_out?
        self.status == Book::CHECKED_OUT
      end

      def check_out
        self.status = Book::CHECKED_OUT
      end

      def check_out!
        self.check_out
        self.save!
      end

      def Book.from_excon_response(response, isbn)
        Book.from_hash(response.to_h, isbn)
      end

      def to_h
        {
            :title => title,
            :isbn => isbn,
            :author => author,
            :publisher => publisher,
            :small_image => small_image,
            :medium_image => medium_image,
            :large_image => large_image
        }
      end

      private
      def Book.from_hash(hash, isbn)

        if hash['ItemLookupResponse']['Items']['Item'].is_a? Array
          first_item = {}
          first_item = hash['ItemLookupResponse']['Items']['Item'].first
        else
          first_item = hash['ItemLookupResponse']['Items']['Item']
        end

        attributes = first_item['ItemAttributes']

        Book.new :title => attributes['Title'],
                 :author => attributes['Author'],
                 :publisher => attributes['Manufacturer'],
                 :asin => first_item['ASIN'],
                 :isbn => isbn,
                 :small_image => first_item['SmallImage']['URL'],
                 :medium_image => first_item['MediumImage']['URL'],
                 :large_image => first_item['LargeImage']['URL']
      end
    end
  end
end



