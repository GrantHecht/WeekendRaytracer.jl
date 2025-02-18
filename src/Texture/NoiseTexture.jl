
# permute
function permute!(p)
    n = length(p)
    for i in n:-1:2
        target      = rand(1:i - 1)
        tmp         = p[i]
        p[i]        = p[target]
        p[target]   = tmp
    end
    return nothing
end

# perlin generate perm
function perlin_generate_perm(point_count)
    p = Vector{Int}(undef, point_count)
    for i in 0:point_count-1
        p[i + 1] = i
    end
    permute!(p)
    return p
end

struct Perlin
    point_count::Int
    ranvec::Vector{SVector{3,Float64}}
    perm_x::Vector{Int}
    perm_y::Vector{Int}
    perm_z::Vector{Int}
    function Perlin()
        point_count = 256
        ranvec      = Vector{SVector{3,Float64}}(undef, point_count)
        @inbounds for i in eachindex(ranvec)
            randvec   = @SVector(rand(3))
            randvec   = 2.0*randvec .- 1.0
            invNrandv = 1.0 / norm(randvec)
            randvec   = invNrandv * randvec
            ranvec[i] = randvec
        end
        perm_x      = perlin_generate_perm(point_count)
        perm_y      = perlin_generate_perm(point_count)
        perm_z      = perlin_generate_perm(point_count)
        new(point_count, ranvec, perm_x, perm_y, perm_z)
    end
end

# Utility function for _noise
function get_randvec(perlin::Perlin, i, j, k, di, dj, dk)
    ii = (i + di) & 255
    jj = (j + dj) & 255
    kk = (k + dk) & 255
    idx = perlin.perm_x[ii + 1] ⊻ perlin.perm_y[jj + 1] ⊻ perlin.perm_z[kk + 1] + 1
    return perlin.ranvec[idx]
end

# Perlin noise function
function noise(perlin::Perlin, p)
    u  = p[1] - floor(p[1])
    v  = p[2] - floor(p[2])
    w  = p[3] - floor(p[3])
    i  = floor(Int, p[1])
    j  = floor(Int, p[2])
    k  = floor(Int, p[3])

    cfun(perlin,di,dj,dk) = get_randvec(perlin,i,j,k,di,dj,dk)
    c = @SArray([cfun(perlin,di,dj,dk) for di in 0:1, dj in 0:1, dk in 0:1])

    # Return perlin noise
    return perlin_interp(c, u, v, w)
end

function turb(perlin::Perlin, p, depth = 7)
    accum   = 0.0
    weight  = 1.0
    tp      = SA[p[1], p[2], p[3]]
    @inbounds for i = 1:depth
        accum  += weight*noise(perlin, tp)
        weight *= 0.5
        tp     *= 2.0
    end
    return abs(accum)
end

struct NoiseTexture{T <: Real} <: AbstractTexture
    perlin::Perlin
    scale::T
    function NoiseTexture()
        new{Int}(Perlin(), Int(1))
    end
    function NoiseTexture(scale::T) where {T <: Real}
        new{T}(Perlin(), scale)
    end
end

function value(t::NoiseTexture, u, v, p)
    n = 0.5*(1.0 + sin(t.scale*p[3] + 10.0*turb(t.perlin, p)))
    return RGB(n, n, n)
end
