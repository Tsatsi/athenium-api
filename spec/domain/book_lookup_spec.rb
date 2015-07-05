include Atheneum::Domain

RSpec.describe Atheneum::Domain::BookLookup do
  before do
    json_file = File.join(File.expand_path(File.dirname(__FILE__)), 'item_lookup.json')
    sample_json = File.read(json_file)

    excon_response = double("lookup_service")
    expected_response = JSON.parse sample_json
    allow(excon_response).to receive(:to_h).and_return(expected_response)

    @vacuum_mock = double('vacuum')
    allow(@vacuum_mock).to receive(:item_lookup).and_return(excon_response)
  end

  let (:book_lookup) { @book_isbn = BookLookup.new isbn: '020161622X', lookup_service: @vacuum_mock }

  it 'should lookup a book by ISBN code' do
    book = book_lookup.lookup
    expect(book).to be_a(Book)
    expect(book.title).to eq('The Pragmatic Programmer: From Journeyman to Master')
    expect(book.author).to eq('Andrew Hunt, David Thomas')
    expect(book.publisher).to eq('Addison-Wesley Professional')
    expect(book.small_image).to eq('http://ecx.images-amazon.com/images/I/41BKx1AxQWL._SL75_.jpg')
    expect(book.medium_image).to eq('http://ecx.images-amazon.com/images/I/41BKx1AxQWL._SL160_.jpg')
    expect(book.large_image).to eq('http://ecx.images-amazon.com/images/I/41BKx1AxQWL.jpg')
    expect(book.isbn).to eq('020161622X')
  end
end
