require_relative "layer"
require 'json'

# To properly initialze a network:
#  - Initialize the new Network object
#  - Create layers using Network#create_layer
#    (This creates layers from left to right, input -> hidden layers -> output layer)

# Sample usage:
#
# network = SimpleNeuralNetwork::Network.new
#
# network.create_layer(neurons: 10)
# network.create_layer(neurons: 2)

# network.run([0.5]*10)

class SimpleNeuralNetwork
  class Network
    class InvalidInputError < StandardError; end
    # An array of layers
    attr_accessor :layers

    attr_accessor :inputs

    attr_accessor :normalization_function

    attr_accessor :edge_initialization_function
    attr_accessor :neuron_bias_initialization_function

    def initialize
      @layers = []
      @inputs = []

      @normalization_function = method(:default_normalization_function)
      @edge_initialization_function = method(:default_edge_initialization_function)
      @neuron_bias_initialization_function = method(:default_neuron_bias_initialization_function)
    end

    # Run an input set against the neural network.
    # Accepts an array of input integers between 0 and 1
    # Input array length must be equal to the size of the first layer.
    # Returns an array of outputs.
    def run(inputs)
      unless inputs.size == input_size && inputs.all? { |input| input >= 0 && input <= 1 }
        raise InvalidInputError.new("Invalid input passed to Network#run")
      end

      @inputs = inputs

      # Get output from last layer. It recursively depends on layers before it.
      @layers[-1].get_output.map do |output|
        (@normalization_function || method(:default_normalization_function)).call(output)
      end
    end

    # Returns the number of input nodes
    def input_size
      @layers[0].size
    end

    # Returns the number of output nodes
    def output_size
      @layers[-1].size
    end

    def create_layer(neurons:)
      unless @layers.empty?
        new_layer = Layer.new(neurons, self)
        prev_layer = @layers.last

        @layers << new_layer

        new_layer.prev_layer = prev_layer
        prev_layer.next_layer = new_layer

        prev_layer.initialize_neuron_edges
      else
        @layers << Layer.new(neurons, self)
      end
    end

    def reset_normalization_function
      @normalization_function = method(:default_normalization_function)
    end

    # Serializes the neural network into a JSON string. This can later be deserialized back into a Network object
    # Useful for storing partially trained neural networks.
    # Note: Currently does not serialize bias init function, edge init function, or normalization function
    def serialize
      {
        layers: layers.map do |layer|
          {
            neurons: layer.neurons.map do |neuron|
              {
                bias: neuron.bias.to_f,
                edges: neuron.edges.map(&:to_f)
              }
            end
          }
        end
      }.to_json
    end

    # Deserialize a JSON neural network back into a Ruby object
    # Note that the normalization function will need to be reset.
    # Normalization function serialization in the future would be cool.
    def self.deserialize(string)
      hash = JSON.parse(string)

      network = Network.new

      hash["layers"].each do |layer|
        neurons_array = layer["neurons"]
        layer = Layer.new(neurons_array.length, network)
        network.layers << layer

        layer.neurons.each_with_index do |neuron, index|
          neuron_hash = neurons_array[index]

          neuron.bias = neuron_hash["bias"].to_f
          neuron.edges = neuron_hash["edges"].map(&:to_f)
        end
      end

      network.layers.each_with_index do |layer, index|
        unless index == 0
          layer.prev_layer = network.layers[index - 1]
        end

        layer.next_layer = network.layers[index + 1]
      end

      network
    end

    private

    # The default normalization function for the network output
    # The standard logistic sigmoid function
    # f(x) = 1 / (1 + e^(-x))
    def default_normalization_function(output)
      1 / (1 + (Math::E ** (-1 * output)))
    end

    def default_edge_initialization_function
      rand(-5..5)
    end

    def default_neuron_bias_initialization_function
      0
    end
  end
end
