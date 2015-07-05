RSpec.describe Atheneum::API::BookshelfAPI do
  include Rack::Test::Methods

  def app
    Atheneum::API::LibraryAPI
  end

  context "GET /v1/library/<library_id>/checked_in" do
    let(:book) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                          :author => "Andrew Hunt",
                          :publisher => "Addison-Wesley Professional",
                          :isbn => "020161622X" }

    it "a book from supplied ISBN code" do
      library = Library.create!(name: "TW Johannesburg", location: [-26.19406,28.0358])

      VCR.use_cassette("bookshelf_library_setup", :match_requests_on => [:method, :path, :host]) do
        library.check_in(isbn: book.isbn)
        library
      end

      expected_book = library.books.find_by_isbn(book.isbn).first.to_json

      get "/v1/library/#{library.id}/checked_in"
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq([JSON.parse(expected_book)])

    end
  end

  context "POST /v1/library/geo_locate" do
    it  'should find a library when close to it' do
      library = Library.create!(name: "TW Johannesburg", location: [-26.19406,28.0358])
      Library.create_indexes

      post '/v1/library/geo_locate', {location:  [-26.19406,28.0358] }

      expect(last_response.status).to eq(201)
      expected_library_response = JSON.parse(library.to_json)
      expected_library_response.delete("_id")
      expect(JSON.parse(last_response.body)).to eq(expected_library_response)
    end

    it 'should not find a library when not close to it' do
      library = Library.create!(name: "TW Johannesburg", location: [-26.19406,28.0358])
      Library.create_indexes

      post '/v1/library/geo_locate', {location:  [26.19406,28.0358] }

      expect(last_response.status).to eq(404)

    end
  end
end
