require_relative '../test_helper'

class NeuronTest < Minitest::Test
  def setup
    @network = Network.new
    @layer = Layer.new(1, @network)
  end

  def test_can_create_neuron
    refute_nil Neuron.new(layer: @layer)
  end

  def test_is_given_a_bias
    refute_nil Neuron.new(layer: @layer).bias
  end

  def test_uses_bias_initialization_method_to_assign_bias
    @network.neuron_bias_initialization_function = lambda { 1000 }
    assert Neuron.new(layer: @layer).bias == 1000
  end

  def test_initializes_edges
    neuron = Neuron.new(layer: @layer)
    neuron.initialize_edges(5)

    assert neuron.edges.count == 5
  end

  def test_uses_edge_initialization_method
    @network.edge_initialization_function = lambda { 100 }

    neuron = Neuron.new(layer: @layer)
    neuron.initialize_edges(5)

    neuron.edges.each do |edge|
      assert edge == 100
    end
  end
end
