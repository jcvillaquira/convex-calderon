module FreeFemCalls
  using LinearAlgebra
  prs = t -> parse(Float64, rsplit(t, ' '; limit = 2)[end])
  function get_ntd_map(sigma = ones(6); bc = 20)
    ss = join(["-s$(j-1) $s" for (j, s) in enumerate(sigma)], ' ')
    str = "FreeFem++ /home/julian/Repos/convex-calderon/ff_scripts/ntd.edp -v 0 -bc $bc $ss"
    cmd = `$(split(str))`
    output = read(cmd, String)
    lines = split(output, '\n')[4:end][1:4*bc^2]
    return LinearAlgebra.Symmetric(reshape(prs.(lines), 2 * bc, 2 * bc))
  end
end

