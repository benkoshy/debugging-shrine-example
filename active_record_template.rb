require "active_record"
require "shrine"
# if you wanna debug shrine locally then do this:
#   gem "shrine", path: "/path/to/your/local/shrine/gem/code"

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

Shrine.plugin :activerecord

class ImageUploader < Shrine
  # plugins and uploading logic
end

class TopicIconUploader < ImageUploader
  # Again, since this code is sensitive, this is as much as I can give you. Apologies.

  plugin :default_url

  Attacher.default_url do |**_options|
    '/images/icons/topic.png'
  end
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.connection.create_table(:topics) { |t| t.text :icon_data }

class Topic < ActiveRecord::Base
  include TopicIconUploader::Attachment(:icon)
end


## If you like working with minitest:

class TopicTest < Minitest::Test
  def test_it_downloads
    assert_raises do
      topic = Topic.create(icon: Down.download("https://example.com/image-from-internet.jpg"))
    end
  end

  def test_url
    topic = Topic.create(icon: File.open("./files/image.jpg"))
    assert topic.icon.url
    assert topic.icon_url
  end
end
