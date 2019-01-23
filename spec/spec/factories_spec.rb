require 'rails_helper'
require 'database_cleaner'

RSpec.describe 'Factories', :qa do
  before(:each) {
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  }

  FactoryBot.factories.each do |factory|
    factories_that_cannot_exist_independently = [
      :index_component
    ]
    next if factories_that_cannot_exist_independently.include?(factory.name)

    it "#{factory.name} factory is valid" do
      FactoryBot.lint([factory])
    end
  end
end
