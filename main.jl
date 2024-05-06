# Imports.
using LinearAlgebra
using ProgressBars
using Plots

# Load packages.
include("src/ff_call.jl")
include("src/barrier.jl")

# Setting up de problem.
a, b = 0.5, 2.0
bc = 5
rnd(n = 6) = ( b - a ) .* rand(n) .+ a
x = rnd()
Fx = FreeFemCalls.get_ntd_map(x; bc = bc)

# Finding analytic center.
x0 = 0.9 .* fill(b, 6)
alpha = 0.01
N = 10
xs = Array{Float64}(undef, N + 1, 6)
xs[1, :] .= x0
for j in ProgressBar(range(1, N))
  Fx0 = FreeFemCalls.get_ntd_map(x0; bc = bc)
  idelta = inv(Fx - Fx0)
  @time grad = FreeFemCalls.get_gradient(x0; bc = bc)
  grad_psd = [tr(idelta * dj) for dj in grad]
  grad_ba = Barrier.gradient_scalar_barrier(x0, a)
  grad_bb = Barrier.gradient_scalar_barrier(x0, b)
  x0 .-= alpha .* ( grad_psd .+ grad_ba .+ grad_bb )
  xs[j + 1, :] .= x0
end

@time grad = FreeFemCalls.get_gradient(x0; bc = 20);

