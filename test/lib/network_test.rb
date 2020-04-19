require_relative '../test_helper'
require 'json'

class NetworkTest < Minitest::Test
  def setup
    @network = Network.new
    @network.edge_initialization_function = lambda { 1 }
    @network.neuron_bias_initialization_function = lambda { 1 }
    @network.normalization_function = lambda { |x| x }
  end

  def test_can_create_network
    refute_nil @network
  end

  def test_network_initializes_with_empty_layers
    assert @network.layers == []
  end

  def test_network_intiializes_with_empty_inputs
    assert @network.inputs == []
  end

  def test_can_create_layer_in_new_network
    @network.create_layer(neurons: 5)
    assert @network.layers.count == 1
  end

  def test_create_layer_correctly_configures_next_and_prev_layer
    @network.create_layer(neurons: 5)
    @network.create_layer(neurons: 5)

    assert @network.layers[0].next_layer == @network.layers[1]
    assert @network.layers[1].prev_layer == @network.layers[0]
  end

  def test_create_layer_initializes_neuron_edges
    @network.create_layer(neurons: 3)
    @network.create_layer(neurons: 4)

    assert @network.layers[0].neurons.size == 3
    @network.layers[0].neurons.each do |neuron|
      assert neuron.edges.count == 4
    end
  end

  def test_input_size_and_output_size_are_correct
    @network.create_layer(neurons: 5)
    @network.create_layer(neurons: 10)

    assert @network.input_size == 5
    assert @network.output_size == 10
  end

  def test_run_errors_with_not_enough_inputs
    @network.create_layer(neurons: 2)

    assert_raises Network::InvalidInputError do
      @network.run([1])
    end
  end

  def test_run_errors_with_inputs_outside_of_bounds
    @network.create_layer(neurons: 1)

    assert_raises Network::InvalidInputError do
      @network.run([2])
    end

    assert_raises Network::InvalidInputError do
      @network.run([-1])
    end
  end

  def test_run_applies_normalization_function
    @network.normalization_function = lambda { |x| 2 * x }

    @network.create_layer(neurons: 1)
    output = @network.run([1])

    assert output == [2]
  end

  def test_allows_setting_of_neuron_initialization_bias
    @network.neuron_bias_initialization_function = lambda { 100 }

    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)

    output = @network.run([0])

    assert output == [100]
  end

  def test_allows_setting_of_edge_initialization_function
    @network.edge_initialization_function = lambda { 5 }

    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)

    output = @network.run([1])

    # Layer 1: 1
    # Layer 2: (1 * 5) + 1 = 6
    # Layer 3: (6 * 5) + 1 = 31
    assert output == [31]
  end

  def test_does_not_apply_edge_weight_changes_if_cache_not_busted
    @network.edge_initialization_function = lambda { 5 }

    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)

    output = @network.run([1])
    assert output == [31]

    @network.layers[0].neurons[0].edges = [1]

    output = @network.run([1])
    assert output == [31]
  end

  def test_applies_edge_weight_changes_if_cache_busted
    @network.edge_initialization_function = lambda { 5 }

    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)

    output = @network.run([1])
    assert output == [31]

    @network.layers[0].neurons[0].edges[0] += 5
    @network.clear_edge_caches

    output = @network.run([1])
    assert output == [56]
  end

  def test_serialize_generates_valid_json
    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)

    assert JSON.parse(@network.serialize)
  end

  def test_deserialize_generates_a_valid_network_object
    @network.create_layer(neurons: 1)
    @network.create_layer(neurons: 1)

    new_network = Network.deserialize(@network.serialize)

    assert new_network.is_a?(Network)
  end

  def test_deserialized_network_behaves_same_as_before_serialization
    # Generate network with random edges and biases
    @network.reset_normalization_function
    @network.edge_initialization_function = lambda { rand(-1..1) }
    @network.neuron_bias_initialization_function = lambda { rand(-1..1) }

    @network.create_layer(neurons: 5)
    @network.create_layer(neurons: 50)
    @network.create_layer(neurons: 50)

    original_output = @network.run([0.5]*5)

    new_network = Network.deserialize(@network.serialize)
    new_output = new_network.run([0.5]*5)

    assert original_output == new_output
  end
end
