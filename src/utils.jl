module FreeFemCalls
  using LinearAlgebra
  prs = t -> parse(Float64, rsplit(t, ' '; limit = 2)[end])
  function str_to_matrix(out; bc = 20)
    lines = split(out, '\n')[4:end][1:4*bc^2]
    return LinearAlgebra.Symmetric(reshape(prs.(lines), 2 * bc, 2 * bc))
  end
  function get_ntd_map(sigma = ones(6); bc = 20)
    ss = join(["-s$(j-1) $s" for (j, s) in enumerate(sigma)], ' ')
    str = "FreeFem++ /home/julian/Repos/convex-calderon/ff_scripts/ntd.edp -v 0 -bc $bc $ss"
    cmd = `$(split(str))`
    output = read(cmd, String)
    return str_to_matrix(output; bc = bc)
  end
  function get_gradient(sigma = ones(6); bc = 20)
    ss = join(["-s$(j-1) $s" for (j, s) in enumerate(sigma)], ' ')
    str = "mpiexec -np 6 FreeFem++-mpi /home/julian/Repos/convex-calderon/ff_scripts/gradient_ntd_parallel.edp -v 0 -bc $bc $ss"
    cmd = `$(split(str))`
    output = read(cmd, String)
    gradient_string = split(output, " -placeholder- ")[1:end-1]
    gradient = str_to_matrix.(gradient_string; bc = bc)
    return gradient
  end
end

module Barrier
  using LinearAlgebra
  function semidefinite_barrier(Y, Fx; mu = 1.0)
    return mu * log( det( Y - Fx ) )
  end
  function upper_barrier(x, b; mu = 1.0)
    return .- mu * sum(log.(b .- x))
  end
  function lower_barrier(x, a; mu = 1.0)
    return .- mu * sum(log.(x .- a))
  end
  function gradient_scalar_barrier(x, a)
    return - 1.0 ./ ( x .- a )
  end
  function gradient_semidefinite_barrier(Y, x)
    return nothing
  end
end

