require_relative '../test_helper'

class LayerTest < Minitest::Test
  def setup
    @network = Network.new
    @network.edge_initialization_function = lambda { 0 }
    @network.neuron_bias_initialization_function = lambda { 0 }
  end

  def test_can_create_layer
    refute_nil Layer.new(5, @network)
  end

  def test_layer_knows_its_size
    assert Layer.new(5, @network).size == 5
  end

  def test_is_populated_with_the_correct_number_of_neurons
    assert Layer.new(5, @network).neurons.size == 5
  end

  def test_initialize_neuron_edges_does_nothing_if_no_next_layer
    layer = Layer.new(5, @network)
    layer.initialize_neuron_edges

    assert layer.neurons[0].edges.empty?
  end

  def test_initialize_neuron_edges_creates_right_number_of_edges
    first_layer = Layer.new(2, @network)
    second_layer = Layer.new(3, @network)

    first_layer.next_layer = second_layer
    second_layer.prev_layer = first_layer

    first_layer.initialize_neuron_edges

    assert first_layer.neurons[0].edges.count == 3
    assert first_layer.neurons[1].edges.count == 3
  end

  def get_output_returns_inputs_if_first_layer
    @network.inputs = [1, 2, 3, 4, 5]

    first_layer = Layer.new(5, @network)
    assert first_layer.get_output == @network.inputs
  end

  # Sets inputs to 0, and edge weights are set to 0 in setup
  # This should make the network output equal to the biases of the last layer.
  def test_get_output_correctly_applies_biases_to_output_values
    @network.inputs = [0, 0]

    first_layer = Layer.new(2, @network)
    second_layer = Layer.new(2, @network)

    first_layer.next_layer = second_layer
    second_layer.prev_layer = first_layer

    first_layer.initialize_neuron_edges

    second_layer.neurons[0].bias = 5
    second_layer.neurons[1].bias = 10

    assert second_layer.get_output == [5, 10]
  end

  def test_get_output_correctly_applies_edge_weights_to_output_values
    @network.inputs = [2, 4]
    @network.edge_initialization_function = lambda { 2 }

    first_layer = Layer.new(2, @network)
    second_layer = Layer.new(2, @network)

    first_layer.next_layer = second_layer
    second_layer.prev_layer = first_layer

    first_layer.initialize_neuron_edges

    second_layer.neurons[0].bias = 1

    # Output layer should be
    # [
    #   (2 * 2) + (2 * 4) + 1 = 13,
    #   (2 * 2) + (2 * 4) + 0 = 12
    # ]

    assert second_layer.get_output == [13, 12]
  end
end
