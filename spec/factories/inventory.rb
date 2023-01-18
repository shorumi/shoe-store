FactoryBot.define do
  factory :inventory, class: ::Entities::Inventory do
    sales_data do
      {
        id: SecureRandom.uuid,
        store: Faker::Company.name,
        model: Faker::Commerce.product_name,
        inventory: Faker::Number.number(digits: 4)
      }
    end
  end
end