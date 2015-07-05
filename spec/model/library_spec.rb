include Atheneum::Model

RSpec.describe Atheneum::Model::Library do

  before :each do
    @library = Library.new location: [-26.12895218, +27.97805541], name: "ThoughtWorks JHB"
    @library.save
  end

  let(:book) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                        :author => "Andrew Hunt",
                        :publisher => "Addison-Wesley Professional",
                        :isbn => "020161622X" }
  let(:book2) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                         :author => "Andrew Hunt",
                         :publisher => "Addison-Wesley Professional",
                         :isbn => "020161622X" }

  it 'should save the libary name' do
    expect(@library.name).to eq('ThoughtWorks JHB')
  end

  it 'should save the library location' do
    expect(@library.location.to_a).to eq([-26.12895218, +27.97805541])
  end

  context 'An empty library' do
    context 'Add a new book to the library' do
      it 'should add new books to the library checked in books' do
        VCR.use_cassette("library_check_in", :match_requests_on => [:method, :path, :host]) do
          expect(@library.check_in(isbn: book.isbn)).to be(true)
          expect(@library.checked_in?(isbn: book.isbn)).to be(true)
          expect(@library.checked_in_book_count).to eq(1)
          expect(Book.count).to eq(1)

          expect(Book.find_by_isbn(book.isbn).first().library).to eq(@library)
        end
      end

      it 'should not allow checking out a book that does not exist' do
        expect(@library.check_out(isbn: book.isbn)).to be(false)
      end
    end
  end

  context 'Library with existing books' do
    before do
      VCR.use_cassette("library_existing_books", :match_requests_on => [:method, :path, :host]) do
        @library.check_in(isbn: book.isbn)
      end
    end

    it 'should checkout existing books' do
      expect(@library.check_out(isbn: book.isbn)).to be true
      expect(@library.checked_in?(isbn: book.isbn)).to be false
      expect(@library.checked_in_book_count).to eq 0
    end
  end

  context 'Find library by geo location' do
    it 'should indicate that a location is close to this library' do
      location =  [-26.128952, 27.978055]
      Library.create_indexes
      lib = Library.close_to location: location
      expect(lib.name).to eq('ThoughtWorks JHB')
    end



    it 'should indicate that a location is not close to this library' do
      cape_town = [-33.989639, 18.5998546]
      Library.create_indexes
      lib = Library.close_to location: cape_town
      expect(lib).to be_nil

      close_by = [-26.1302954,27.9772707]
      Library.create_indexes
      lib = Library.close_to location: close_by
      expect(lib).to be_nil
    end
  end


end