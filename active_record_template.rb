require "active_record"
require "shrine"
# if you wanna debug shrine locally then do this:
#   gem "shrine", path: "/path/to/your/local/shrine/gem/code"

require "shrine/storage/memory"
require "down"

require "bundler/setup" # if you want to debug shrine locally
require 'minitest/autorun' # if you wanna use minitest
require "sidekiq"
require "sidekiq/testing"
require "./sidekiq_minitest_support"
require "./conversation_pdf_worker"
require "byebug"
require "./promote_job"
require "./destroy_job"

# require 'byebug'  ## if you're using byebug
# byebug

Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new,
}

Shrine.plugin :activerecord
Shrine.plugin :backgrounding

Shrine::Attacher.promote_block do
  PromoteJob.perform_async(self.class.name, record.class.name, record.id, name, file_data)
end

Shrine::Attacher.destroy_block do
  DestroyJob.perform_async(self.class.name, data)
end

class MyUploader < Shrine
  # plugins and uploading logic
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.connection.create_table(:conversations) do |t|
  t.text :pdf_data
  t.text :subject
end

class Conversation < ActiveRecord::Base
  include MyUploader::Attachment(:pdf)
end


## If you like working with minitest:

class ConversationTest < Minitest::Test
  def test_url
    Sidekiq::Testing.inline! do
      c = Conversation.create(pdf: File.open("./files/image.jpg"), subject: "test")
      assert ConversationPdfWorker.perform_async(c.id)
      assert_equal Conversation.first.pdf.original_filename, "test.pdf"
    end
  end
end
