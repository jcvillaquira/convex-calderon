

module Barrier
  using LinearAlgebra
  function semidefinite_barrier(Y, Fx; mu = 1.0)
    return mu * log( det( Y - Fx ) )
  end
  function upper_barrier(x, b; mu = 1.0)
    return mu * sum(log.(b .- x))
  end
  function lower_barrier(x, a; mu = 1.0)
    return mu * sum(log.(x .- a))
  end
  function gradient_scalar_barrier(x, a)
    return 1.0 ./ ( x .- a )
  end
  function gradient_semidefinite_barrier(Y, x)
    return nothing
  end
end

