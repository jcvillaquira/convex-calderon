# Imports.
using LinearAlgebra
using ProgressBars
using CairoMakie

# Load packages.
include("src/utils.jl")

# Setting up de problem.
a, b = 0.5, 2.0
bc = 20
cores = 6
J = 4
rnd(n = 6) = 0.8 * ( b - a ) .* rand(n) .+ a

# Define real and initial point.
xr = rnd()
xr_txt = join(["-xr$(j-1) $s" for (j, s) in enumerate(xr)], ' ')
dw = 0.05;

# Apply interior point method.
x0 = 0.9 .* fill(b, 6)
w = 0.0
N = 200
xs = zeros(Float64, N + 1, 6)
xs[1, :] .= x0
iter = ProgressBar(range(1, N))
for j in iter
  if j == 2
    w = 1.0
  end
  x0_txt = join(["-x0$(k-1) $s" for (k, s) in enumerate(x0)], ' ')
  str = "mpiexec -np $cores FreeFem++-mpi $(pwd())/src/descent.edp -v 0 -bc $bc $x0_txt $xr_txt -J $J -w $w -alpha 0.0025"
  cmd = `$(split(str))`
  output = read(cmd, String)
  x0 = parse.(Ref(Float64), split(output[1:end-1], ','))
  xs[j + 1, :] .= x0
  w *= 1 + dw
  err = maximum(abs.( xr .- x0 ))
  if (err < 0.05) || (err > 2)
    break
  end
  set_description(iter, "Err: $(round(err, digits = 2))")
end

with_theme(theme_dark()) do
  update_theme!(font = "CMU Concrete", fontsize = 25)
  fig = Figure(;size = (1280, 720))
  ax = Axis(fig[1, 1])
  xr_points = Point2f.(enumerate(xr))
  lines!(ax, xr_points; linewidth = 1.5, color = :dodgerblue)
  x0_points = Observable( Point2f.(enumerate(xs[1, :])) )
  error = round(maximum(abs.(xs[1, :] - xr)), digits = 3)
  ax.title = "l_infty_error = $error"
  lines!(ax, x0_points; linewidth = 1.5, color = :crimson)
  framerate = 30
  duration = 18
  frames = range(1, duration * framerate)
  ctn = 1
  record(fig, "makie00.mp4", frames; framerate = framerate) do t
    if (mod(t, 4) == 0) && ( t > 10 ) && ( ctn <= size(xs, 1) )
      x0_points[] = Point2f.(enumerate(xs[ctn, :]))
      error = round(maximum(abs.(xs[ctn, :] - xr)), digits = 3)
      ctn += 1
      ax.title = "l_infty_error = $error"
    end
  end
end

