include Atheneum::Model

RSpec.describe Atheneum::Model::Bookshelf do
  let(:bookshelf) { Bookshelf.create! }

  let(:book1) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                        :author => "Andrew Hunt",
                        :publisher => "Addison-Wesley Professional",
                        :isbn => "020161622X" }
  let(:book2) { Book.new :title => "The Pragmatic Programmer: From Journeyman to Master",
                         :author => "Andrew Hunt",
                         :publisher => "Addison-Wesley Professional",
                         :isbn => "020161622X" }

  context "Empty library" do
    let(:library) { Library.create!(name: "TW Johannesburg") }

    context "Empty bookshelf" do
      it "should check in book to library" do
        VCR.use_cassette("bookshelf_check_in", :match_requests_on => [:method, :path, :host]) do
          expect(bookshelf.scan(isbn: book1.isbn, library: library)).to eq true
          expect(library.checked_in?(isbn: book1.isbn)).to eq true
        end
      end
    end
  end

  context "Library with books" do
    let(:library) do
      VCR.use_cassette("bookshelf_library_setup", :match_requests_on => [:method, :path, :host]) do
        library = Library.create!(name: "TW Johannesburg")
        library.check_in(isbn: book1.isbn)
        library
      end
    end

    it "should add an existing book to the bookshelf and check it out of the library" do
      expect(bookshelf.scan(isbn: book1.isbn, library: library)).to eq true
      expect(library.checked_out?(isbn: book1.isbn)).to eq true
    end

    it 'should remove books from the bookshelf and check it in to the library' do
      bookshelf.scan(isbn: book1.isbn, library: library)
      expect(bookshelf.scan(isbn: book1.isbn, library: library)).to eq true
      expect(library.checked_in?(isbn: book1.isbn)).to eq true
    end
  end

end