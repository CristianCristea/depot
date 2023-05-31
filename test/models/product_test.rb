require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def new_product(image_url)
    Product.new(title: 'New Product',
                description: 'sss',
                price: 1,
                image_url:)
  end

  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:image_url].any?
    assert product.errors[:price].any?
  end

  test 'product price must be positive' do
    product = Product.new(
      title: 'New Product',
      description: 'XYZ',
      image_url: 'ttt.jpg'
    )
    product.price = -1
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
                 product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
                 product.errors[:price]

    product.price = 1
    assert product.valid?
    puts product.errors
  end

  test 'image url' do
    ok = %w[fred.gif fred.jpg fred.png FRED.JPG FRED.PNG FRED.GIF]
    bad = %w[fre.doc fred.gif/more fred.gif.more]

    ok.each do |image_url|
      assert new_product(image_url).valid?,
             "#{image_url} must be valid"
    end

    bad.each do |image_url|
      assert new_product(image_url).invalid?,
             "#{image_url} must be invalid"
    end
  end

  test 'product is not valid without a unique title' do
    product = Product.new(title: products(:ruby).title,
                          description: 'yyy',
                          price: 1,
                          image_url: 'lorem.jpg')
    assert product.invalid?
    assert_equal ['has already been taken'], product.errors[:title]
  end

  test 'product in not valid without a unique title - i18n' do
    product = Product.new(title: products(:ruby).title,
                          description: 'yyy',
                          price: 1,
                          image_url: 'lorem.jpg')
    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')],
                 product.errors[:title]
  end
end
