require "active_record"
require "shrine"
# if you wanna debug shrine locally then do this:
#   gem "shrine", path: "/path/to/your/local/shrine/gem/code"

require "shrine/storage/memory"
require "down"

require "bundler/setup" # if you want to debug shrine locally
require 'minitest/autorun' # if you wanna use minitest

require "factory_bot"

require "byebug"
# require "test/factories/private_attachment"


# require 'byebug'  ## if you're using byebug
# byebug

Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new,
}

Shrine.plugin :activerecord

class MyUploader < Shrine
  # plugins and uploading logic
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.connection.create_table(:posts) { |t| t.text :image_data }

class Post < ActiveRecord::Base
  include MyUploader::Attachment(:image)

  def filename
    image.metadata["filename"]
  end
end


## If you like working with minitest:
class PostTest < Minitest::Test
  include FactoryBot::Syntax::Methods

  def test_file_name_without_factory_bot
    image_data = %!{"id":"***.jpg","storage":"store","metadata":{"filename":"konnichiwa.jpeg","size":976220,"mime_type":"image/jpeg","width":4032,"height":3024}}!
    post = Post.new
    post.image_data = image_data
    post.save
    assert_equal "konnichiwa.jpeg", Post.last.filename
  end

  def test_filename_with_factory_bot
  end
end
