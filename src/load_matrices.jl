# %% Read data.
f = open(path, "r")
data = readlines(f)
close(f)

# %% Extract shapes.
sizes_regex = r"^([0-9]+ ){3}"
headers = findall(occursin.(Ref(sizes_regex), data))
sizes = stack([parse.(Ref(Int), split(x.match)) for x in match.(Ref(sizes_regex), data[headers])])

# %% Form matrices.
results = Vector{Matrix}(undef, length(headers))
extract_last = s -> rsplit(s, limit = 2)[end]
for (j, hd) in ProgressBar(enumerate(headers))
  rows = data[hd+1:hd+sizes[3, j]]
  numbers = parse.(Ref(Float64), extract_last.(rows))
  results[j] = reshape(numbers, sizes[1:2, j]...)
end

