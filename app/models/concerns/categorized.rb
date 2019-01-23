module Categorized
  extend ActiveSupport::Concern

  class_methods do
    def categories(*categories)
      _categorized_constant(categories)
      _categorized_validations
      _categorized_scopes
    end
  end

  def category?(category)
    self.category == category.to_s
  end

  class_methods do
    private

    def _categorized_constant(categories)
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        CATEGORIES = #{categories.map(&:to_s)}.freeze
      RUBY
    end

    def _categorized_validations
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        validates :category,
          inclusion: {in: CATEGORIES}
      RUBY
    end

    def _categorized_scopes
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        CATEGORIES.each { |category|
          scope category, -> { where(category: category) }
        }
      RUBY
    end
  end
end
