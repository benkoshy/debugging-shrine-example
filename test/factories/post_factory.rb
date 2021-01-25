FactoryBot.define do
  factory :post do
    image {File.open(File.join(File.dirname(__FILE__), "../../files/image.jpg")) }
    # use image_data
  end
end
