require "active_record"
require "shrine"
# if you wanna debug shrine locally then do this:
#   gem "shrine", path: "/path/to/your/local/shrine/gem/code"

require "shrine/storage/memory"
require "down"

require "bundler/setup" # if you want to debug shrine locally
require 'minitest/autorun' # if you wanna use minitest

Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new,
}

Shrine.plugin :activerecord

class MyUploader < Shrine
  # plugins and uploading logic

  def generate_location(io, context = {})
    "my/custom/folder/#{super}"
  end
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.connection.create_table(:posts) { |t| t.text :image_data }

class Post < ActiveRecord::Base
  include MyUploader::Attachment(:image)
end


## If you like working with minitest:

class PostTest < Minitest::Test
  def test_it_downloads
    assert_raises do
      post = Post.create(image: Down.download("https://example.com/image-from-internet.jpg"))
    end
  end

  def test_url
    assert Post.create(image: File.open("./files/image.jpg")).image.url
  end
end
