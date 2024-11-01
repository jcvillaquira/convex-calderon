# %%
using ProgressBars
using GLMakie
using LinearAlgebra

# %% Read data.
N = 3
path = "examples/cone_$N.txt"

# %%
include("src/load_matrices.jl")

# %%
cone = results[1]
projective_cone = - cone * diagm(1.0 ./ cone[end, :])
projected_cone = projective_cone[1:2, :]

points = [Point(x...) for x in eachcol(projected_cone)]

# %%
f = Figure()
ax = Axis(f[1, 1])
N = Int(length(points) / 2)
scatter!(ax, points, color = :dodgerblue)
labels = [abs(x) for x in range(-N, N) if x != 0]
for (i, label) in enumerate(labels)
  text!(ax, points[i]..., text = "$label")
end

