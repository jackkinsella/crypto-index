FactoryBot.define do
  factory(:index_component, class: Index::Component) do
    association :currency, strategy: :find_or_create
    association :allocation, factory: :index_allocation, strategy: :build
    weight 0.1
  end
end
