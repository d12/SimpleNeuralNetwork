# SimpleNeuralNetwork

This is a simple neural network implementation in Ruby.

This gem does not include any learning implementations (back-prop, etc).

## Installation

```
gem install simple_neural_network
```

## Sample usage:

![Sample Neural Network](https://cdn-images-1.medium.com/max/1600/0*IUWJ5oJ_z6AiG7Ja.jpg)

The following code implements the above neural network.

```ruby
network = SimpleNeuralNetwork::Network.new

network.create_layer(neurons: 5)
network.create_layer(neurons: 7)
network.create_layer(neurons: 7)
network.create_layer(neurons: 4)
```

Neural networks are initialized with random edge weights and zero-valued neuron biases. Edge/bias initialization is configurable by setting the initialization lambdas.

The following code runs an input set against the network.

```ruby
 network.run([0.5, 0.4, 0.8, 0, 0.9])
 => [0.2257, 0.7488, 0.1016, 0.9935]
```

## Manipulating the network

### Setting a neuron bias

```ruby
network.layers[layer_index].neurons[neuron_index].bias = new_neuron_bias
```

### Setting an edge weight

In `SimpleNeuralNetwork`, edges point forward and edge weights stored as an array of integers on a `Neuron` object. To access the edge pointing from a neuron to the `n'th` neuron in the next layer:

```ruby
network.layers[layer_index].neurons[neuron_index].edges[n] = new_edge_weight
```

## Improvements / Bugs
Improvements and bugs are listed as issues in the gem repository.
