module Atheneum
  module Domain
    class BookLookup
      SEARCH_INDEX = 'Books'
      ID_TYPE = 'EAN'
      ASSOCIATE_TAG='tag'

      def initialize(isbn:, lookup_service: initialize_default_lookup_service)
        @isbn = isbn
        @lookup_service = lookup_service
      end

      def lookup
        raw_product_lookup_response = @lookup_service.item_lookup(
          query: {
            'SearchIndex' => SEARCH_INDEX,
            'IdType' => ID_TYPE,
            'ItemId' => @isbn,
            'ResponseGroup' => 'Small, Images'
          })

        Atheneum::Model::Book.from_excon_response(raw_product_lookup_response, @isbn)
      end

      private
      def initialize_default_lookup_service
        lookup_service = Vacuum.new
        lookup_service.configure associate_tag: ASSOCIATE_TAG
        lookup_service
      end
    end
  end
end