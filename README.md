# SimpleNeuralNetwork

This is a simple neural network implementation in Ruby. 

Currently, it allows generation of networks with randomized weights and neuron biases. In the future, this will be configurable.

This gem does not include any learning implementations (back-prop, etc).

## Sample usage:

network = SimpleNeuralNetwork::Network.new

network.create_layer(neurons: 10)
network.create_layer(neurons: 2)

network.initialize_edges

network.run([0.5]*10)
=> [3, 0.1]

## Improvements / Bugs
Improvements and bugs are listed as issues in the gem repository.
