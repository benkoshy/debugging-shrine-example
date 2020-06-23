require "sequel"
require "shrine"
require "shrine/storage/memory"
require "down"

require "bundler/setup" # if you want to debug shrine locally
require 'minitest/autorun' # if you wanna use minitest

# require 'byebug'  ## if you're using byebug
# byebug


Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new,
}

Shrine.plugin :sequel

class MyUploader < Shrine
  # plugins and uploading logic
end

DB = Sequel.sqlite # SQLite memory database
DB.create_table :posts do
  primary_key :id
  String :image_data
end

class Post < Sequel::Model
  include MyUploader::Attachment(:image)
end


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
