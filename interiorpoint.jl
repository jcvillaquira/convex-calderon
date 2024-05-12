# Imports.
using DelimitedFiles
using CairoMakie

# Load packages.
include("src/utils.jl")

# Setting up de problem.
params = Dict("a" => 0.5,
  "b" => 2.0,
  "bc" => 10,
  "D" => 20,
  "J" => 5,
  "w" => 1.5,
  "alpha0" => 0.0025,
  "dev" => 1,
  "dw" => 0.01,
  "N" => 1_000)
rnd(n = 6) = 0.8 * ( params["b"] - params["a"] ) .* rand(n) .+ params["a"]

# Define real and initial point.
xr = rnd()
xr_txt = join(["-xr$(j-1) $s" for (j, s) in enumerate(xr)], ' ')

# Run the interior-point method.
cores = 6
params_str = join(["-$x $y" for (x, y) in params], " ")
str = "mpiexec -np $cores FreeFem++-mpi src/descent.edp $params_str $xr_txt";
cmd = `$(split(str))`;
@time run(cmd);
run(`notify-send done`)
# Save recording.
prs(x) = parse.(Float64, split(x, ','))
xs = prs.(reshape(readdlm("output.txt"), :))
with_theme(theme_dark()) do
  update_theme!(font = "CMU Concrete", fontsize = 25)
  fig = Figure(;size = (1280, 720))
  ax = Axis(fig[1, 1])
  xr_points = Point2f.(enumerate(xr))
  lines!(ax, xr_points; linewidth = 1.5, color = :dodgerblue)
  x0_points = Observable( Point2f.(enumerate(xs[1])) )
  error = round(maximum(abs.(xs[1] - xr)), digits = 3)
  ax.title = "L_infty_error = $error"
  lines!(ax, x0_points; linewidth = 1.5, color = :crimson)
  framerate = 60
  frames = range(1, size(xs, 1) + 20)
  ctn = 1
  record(fig, "makie.mp4", frames; framerate = framerate) do t
    if ( t > 10 ) && ( ctn <= size(xs, 1) )
      x0_points[] = Point2f.(enumerate(xs[ctn]))
      error = round(maximum(abs.(xs[ctn] - xr)), digits = 3)
      ctn += 1
      ax.title = "L_infty_error = $error"
    end
  end
end
run(`notify-send rendered`)
