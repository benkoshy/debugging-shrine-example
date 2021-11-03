require 'action_controller/railtie'
require "active_record"

require "shrine"
# if you wanna debug shrine locally then do this:
#   gem "shrine", path: "/path/to/your/local/shrine/gem/code"

require "shrine/storage/memory"
require "down"

require "bundler/setup" # if you want to debug shrine locally
require 'minitest/autorun' # if you wanna use minitest

require "./test_data"

require 'byebug'  ## if you're using byebug

Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new,
}

Shrine.plugin :activerecord

class MyUploader < Shrine
  # plugins and uploading logic
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.connection.create_table(:photos) { |t| t.text :image_data }

class Photo < ActiveRecord::Base
  include MyUploader::Attachment(:image)
end

class TestApp < Rails::Application # :nodoc:
  config.root = __dir__
  config.hosts << 'www.example.com'
  config.hosts << 'example.org'
  config.session_store :cookie_store, key: 'cookie_store_key'
  secrets.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    resources :photos
  end
end

class PhotosController < ActionController::Base # :nodoc:
  include Rails.application.routes.url_helpers

  def create
    photo = Photo.create!(create_display_photo_params.delete(:photo))
  end

  def create_display_photo_params
    params.require(:display_photo).permit(
      photo: :image,
    )
  end
end

class TestControllerTest < ActionDispatch::IntegrationTest # :nodoc:
  test 'pagy json output - example' do
    assert_difference 'Photo.count' do
      post photos_path, params: valid_params
    end
  end

  private

  def valid_params
    {
      display_photo: {
        photo: {image: TestImageData.uploaded_image # copy-paste of https://shrinerb.com/docs/testing#test-data
                }
    }}
  end

  def app
    Rails.application
  end
end

# ok
# Photo.new(image_data: TestImageData.uploaded_image)
# Photo.new(image: TestImageData.uploaded_image)
