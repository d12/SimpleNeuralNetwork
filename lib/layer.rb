require_relative "neuron"
require "nmatrix"

class SimpleNeuralNetwork
  class Layer
    # Number of neurons
    attr_accessor :size

    attr_accessor :prev_layer
    attr_accessor :next_layer

    # List of #{size} neurons
    attr_accessor :neurons

    attr_accessor :network

    def initialize(size, network)
      @size = size
      @neurons = []
      @network = network

      @prev_layer = nil
      @next_layer = nil

      populate_neurons
      edge_matrix # Caches edge matrix
    end

    # The method that drives network output resolution.
    # get_output calculates the array of neuron values for this layer.
    # This is calculated by recursively fetching the output from the previous layer, then applying edge/node weight and bias rules.
    # The first layer will fetch it's values from @network.inputs
    def get_output(normalize: @network.hidden_layer_normalization_function)
      if !prev_layer
        # This is the first layer, so the output set is simply the network input set
        @network.inputs
      else
        # Each neuron output value is calculated by:
        # output[i] = (
        #                (prev_layer.neurons[0] * prev_layer.neurons[0].edges[i])
        #              + (prev_layer.neurons[1] * prev_layer.neurons[1].edges[i])
        #              + ...
        #             ) + self.neurons[i].bias
        prev_output = prev_layer.get_output
        prev_output_matrix = NMatrix.new([prev_output.length, 1], prev_output, dtype: :float64)

        result = (edge_matrix.dot(prev_output_matrix)).each_with_index.map do |val, i|
          val + @neurons[i].bias
        end

        result.map {|item| normalize.call(item) }
      end
    end

    def initialize_neuron_edges
      return unless @next_layer

      @neurons.each do |neuron|
        neuron.initialize_edges(@next_layer.size)
      end
    end

    def edge_matrix
      return unless prev_layer

      @edge_matrix ||= begin
        elements = prev_layer.neurons.map{|a| a.edges}
        NMatrix.new([elements.count, elements[0].count], elements.flatten, dtype: :float64).transpose
      end
    end

    def clear_edge_cache
      @edge_matrix = nil
    end

    private

    def populate_neurons
      @size.times do
        @neurons << Neuron.new(layer: self)
      end
    end
  end
end
