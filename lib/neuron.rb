class SimpleNeuralNetwork
  class Neuron
    # Define the minimum and maximum edge weight
    EDGE_RANGE = -5..5

    attr_accessor :bias

    # The neuron parent layer
    attr_accessor :layer

    # A neuron's edges connect it to the #{layer.next_layer.size} neurons of the next layer
    attr_accessor :edges

    def initialize(layer)
      @layer = layer
      @bias = 0
      @edges = []
      @value = nil
    end

    # A neuron should have one edge per neuron in the next layer
    def initialize_edges(next_layer_size)
      next_layer_size.times do
        @edges << rand(EDGE_RANGE)
      end
    end
  end
end
