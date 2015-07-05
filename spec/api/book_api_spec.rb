RSpec.describe Atheneum::API::BookAPI do
  include Rack::Test::Methods

  def app
    Atheneum::API::BookAPI
  end

  context "GET /v1/book/{isbn_code}/lookup" do
    it "a book from supplied ISBN code" do
      expected_book = {
          "title" => "The Pragmatic Programmer: From Journeyman to Master",
          "author" => "Andrew Hunt, David Thomas",
          "publisher" => "Addison-Wesley Professional",
          "isbn" => "020161622X",
          "small_image" => "http://ecx.images-amazon.com/images/I/41BKx1AxQWL._SL75_.jpg",
          "medium_image" => "http://ecx.images-amazon.com/images/I/41BKx1AxQWL._SL160_.jpg",
          "large_image" => "http://ecx.images-amazon.com/images/I/41BKx1AxQWL.jpg"
      }

      VCR.use_cassette("lookup020161622X", :match_requests_on => [:method, :path, :host]) do
        get "/v1/book/020161622X/lookup"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq(expected_book)
      end
    end
  end

  context "POST /v1/book/{isbn_code}/scan" do
    let(:book) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                          :author => "Andrew Hunt",
                          :publisher => "Addison-Wesley Professional",
                          :isbn => "020161622X" }

    it "should check in a new book to the library" do
      VCR.use_cassette("scan020161622X", :match_requests_on => [:method, :path, :host]) do
        library = Library.create!(:name => "Test library")
        user = User.create!
        bookshelf = Bookshelf.create!(:user => user)
        post '/v1/book/020161622X/scan', {:user_id => user.id, :library_id => library.id}
         expect(last_response.status).to eq(201)
      end
    end
  end
end
