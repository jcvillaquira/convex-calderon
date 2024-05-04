# Imports.
using LinearAlgebra
using ProgressBars

# Auxiliar function.
rnd(n = 6) = 0.15 .* rand(n) .+ 0.45

# Load packages.
include("src/ff_call.jl")
include("src/barrier.jl")

h = 0.000000001;
x0 = FreeFemCalls.get_ntd_map(bc = 2);
x1 = FreeFemCalls.get_ntd_map([1.0 + h, 1, 1, 1, 1, 1]; bc = 2);
( x1 - x0 ) / h

# Create original conductivity.
x = [0.5, 0.55, 0.5, 0.55, 0.5, 0.55]
Fx = FreeFemCalls.get_ntd_map(x)

# Set problem parameters.
a, b = 0.2, 1.0

# Compute analytic center.
x0 = fill(0.99 * b, 6)
Fx0 = get_ntd_map(x0)

