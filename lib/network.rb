require_relative "layer"

# To properly initialze a network:
#  - Initialize the new Network object
#  - Create layers using Network#create_layer
#    (This creates layers from left to right, input -> hidden layers -> output layer)
#  - Call Network#initialize_edges to populate neuron edges in the network.
#    This has to be done after creating all layers because the number of edges depends
#    on the number on neurons in the next layer

# Sample usage:
#
# network = SimpleNeuralNetwork::Network.new
#
# network.create_layer(neurons: 10)
# network.create_layer(neurons: 2)

# network.initialize_edges

# network.run([0.5]*10)

class SimpleNeuralNetwork
  class Network
    class InvalidInputError < StandardError; end
    # An array of layers
    attr_accessor :layers

    attr_accessor :inputs

    def initialize
      @layers = []
      @inputs = []
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
      @layers[-1].get_output
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
      else
        @layers << Layer.new(neurons, self)
      end
    end

    # This traverses the network and initializes all neurons with edges
    # Initializes with random weights between -5 and 5
    def initialize_edges
      @layers.each(&:initialize_neuron_edges)
    end
  end
end
