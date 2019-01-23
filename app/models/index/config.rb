class Index::Config
  def initialize(name)
    @name = name.to_sym
  end

  def description
    if minimum_component_weight == maximum_component_weight
      <<~TEXT
        Tracks the top #{number_of_components} cryptocurrencies by market
        capitalization with an even #{minimum_component_weight_percent}%
        component weighting.
      TEXT
    else
      <<~TEXT
        Tracks the top #{number_of_components} cryptocurrencies by market
        capitalization with a #{minimum_component_weight_percent}% minimum
        component weighting and a #{maximum_component_weight_percent}%
        maximum component weighting.
      TEXT
    end
  end

  def number_of_components
    DATA[name][:number_of_components]
  end

  def minimum_component_weight
    DATA[name][:minimum_component_weight]
  end

  def minimum_component_weight_percent
    minimum_component_weight.as_percent
  end

  def maximum_component_weight
    DATA[name][:maximum_component_weight]
  end

  def maximum_component_weight_percent
    maximum_component_weight.as_percent
  end

  def centered_component_weight
    (minimum_component_weight + maximum_component_weight) / 2
  end

  private

  attr_reader :name

  DATA = {
    market10: {
      number_of_components: 10,
      minimum_component_weight: 0.01,
      maximum_component_weight: 0.25
    },

    'market10-even': {
      number_of_components: 10,
      minimum_component_weight: 0.1,
      maximum_component_weight: 0.1
    },

    market20: {
      number_of_components: 20,
      minimum_component_weight: 0.005,
      maximum_component_weight: 0.20
    }
  }.freeze
end
