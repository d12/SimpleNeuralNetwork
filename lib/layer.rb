require_relative "neuron"

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

      populate_neurons
    end

    # The method that drives network output resolution.
    # get_output calculates the array of neuron values for this layer.
    # This is calculated by recursively fetching the output from the previous layer, then applying edge/node weight and bias rules.
    # The first layer will fetch it's values from @network.inputs
    def get_output
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

        prev_layer_output = prev_layer.get_output

        # Generate the output values for the layer
        (0..@size-1).map do |i|
          value = 0

          prev_layer_output.each_with_index do |output, index|
            value += (output * prev_layer.neurons[index].edges[i])
          end

         value + @neurons[i].bias
        end
      end
    end

    def initialize_neuron_edges
      return unless @next_layer

      @neurons.each do |neuron|
        neuron.initialize_edges(@next_layer.size)
      end
    end

    private

    def populate_neurons
      @size.times do
        @neurons << Neuron.new(layer: self)
      end
    end
  end
end
