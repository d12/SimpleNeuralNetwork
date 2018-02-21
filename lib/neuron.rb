class SimpleNeuralNetwork
  class Neuron
    attr_accessor :bias

    # A neuron's edges connect it to the #{layer.next_layer.size} neurons of the next layer
    attr_accessor :edges

    def initialize(layer:)
      @layer = layer
      @bias = layer.network.neuron_bias_initialization_function.call
      @edges = []
      @value = nil
    end

    # A neuron should have one edge per neuron in the next layer
    def initialize_edges(next_layer_size)
      init_function = @layer.network.edge_initialization_function

      next_layer_size.times do
        @edges << init_function.call
      end
    end
  end
end
