
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

# allocate c vector
function alloc_cvec()
    len     = Threads.nthreads()
    cvec    = Vector{Array{Vector{Float64}, 3}}(undef, len)
    @inbounds for i in eachindex(cvec)
        c = Array{Vector{Float64}, 3}(undef, 2, 2, 2)
        for i in eachindex(c); c[i] = Vector{Float64}(undef, 3); end
        cvec[i] = c
    end
    return cvec
end

struct Perlin
    point_count::Int
    ranvec::Vector{Vector{Float64}}
    perm_x::Vector{Int}
    perm_y::Vector{Int}
    perm_z::Vector{Int}
    cvec::Vector{Array{Vector{Float64}, 3}}
    locks::Vector{ReentrantLock}
    function Perlin()
        point_count = 256
        ranvec      = Vector{Vector{Float64}}(undef, point_count)
        @inbounds for i in eachindex(ranvec)
            randvec     = rand(3)
            randvec   .*= 2.0
            randvec   .-= 1.0
            invNrandv   = 1.0 / norm(randvec)
            randvec   .*= invNrandv
            ranvec[i] = randvec
        end
        perm_x      = perlin_generate_perm(point_count)
        perm_y      = perlin_generate_perm(point_count)
        perm_z      = perlin_generate_perm(point_count)
        cvec        = alloc_cvec()
        locks       = [ReentrantLock() for i in 1:Threads.nthreads()]
        new(point_count, ranvec, perm_x, perm_y, perm_z, cvec, locks)
    end
end

# Aquire lock for Perlin _noise call
function aquire_lock(perlin::Perlin)
    lock_idx        = 0
    lock_aquired    = false
    while !lock_aquired
        # Random index guess and check
        i = rand(1:Threads.nthreads())
        # Aquire lock if available
        if trylock(perlin.locks[i])
            # Set lock index
            lock_idx = i
            # Set lock aquired flag
            lock_aquired = true
            # Break from loop 
            break
        end
    end
    return lock_idx
end

# Release Perlin lock
function release_lock(perlin::Perlin, lock_idx)
    unlock(perlin.locks[lock_idx])
end

# Perlin noise function
function _noise(perlin::Perlin, p, cvec_idx)
    u  = p[1] - floor(p[1])
    v  = p[2] - floor(p[2])
    w  = p[3] - floor(p[3])
    i  = floor(Int, p[1])
    j  = floor(Int, p[2])
    k  = floor(Int, p[3])

    c = perlin.cvec[cvec_idx]
    for di = 0:1
        for dj = 0:1
            for dk = 0:1
                ii = (i + di) & 255
                jj = (j + dj) & 255
                kk = (k + dk) & 255
                c[di+1, dj+1, dk+1] = 
                    perlin.ranvec[
                        perlin.perm_x[ii + 1] ⊻ 
                        perlin.perm_y[jj + 1] ⊻ 
                        perlin.perm_z[kk + 1] + 1
                    ]
            end
        end
    end

    # Return perlin noise
    return perlin_interp(c, u, v, w)
end

function noise(perlin::Perlin, p)
    if Threads.nthreads() > 1
        # Aquire lock
        lock_idx = aquire_lock(perlin) 

        n = try 
            # Call _noise
            _noise(perlin, p, lock_idx)
        catch e
            # Throw error if caught
            throw(e)
        finally
            # Release lock
            release_lock(perlin, lock_idx)
        end

        return n
    else
        return _noise(perlin, p, 1)
    end
end

function turb(perlin::Perlin, p, depth = 7)
    accum   = 0.0
    weight  = 1.0
    tp      = SVector(p[1], p[2], p[3])
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

