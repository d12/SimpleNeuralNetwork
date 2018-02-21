require 'minitest/autorun'
require 'minitest/spec'

require_relative '../lib/network.rb'
require_relative '../lib/layer.rb'
require_relative '../lib/neuron.rb'

# Assign shorthands to prevent specs from being too verbose
Network = SimpleNeuralNetwork::Network
Layer = SimpleNeuralNetwork::Layer
Neuron = SimpleNeuralNetwork::Neuron
