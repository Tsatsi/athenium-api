RSpec.describe Atheneum::API::BookshelfAPI do
  include Rack::Test::Methods

  def app
    Atheneum::API::BookshelfAPI
  end

  context "GET /v1/bookshelf/list" do
    let(:book) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                           :author => "Andrew Hunt",
                           :publisher => "Addison-Wesley Professional",
                           :isbn => "020161622X" }

    it "a book from supplied ISBN code" do
      library = Library.create!(name: "TW Johannesburg")
      VCR.use_cassette("bookshelf_library_setup", :match_requests_on => [:method, :path, :host]) do
        library.check_in(isbn: book.isbn)
        library
      end

      user = User.create!
      bookshelf = Bookshelf.create!(:user => user)
      bookshelf.scan(isbn: book.isbn, library: library)

      expected_book = bookshelf.books.find_by_isbn(book.isbn).first.to_json

      get "/v1/bookshelf/#{user.id}/list"
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq([JSON.parse(expected_book)])

    end
  end
end
