# Function to check if all componants of iterable are near zero
function near_zero(iterable)
    s = 1e-8
    all_small = true
    @inbounds for i in eachindex(iterable)
        if abs(iterable[i]) > s
            all_small = false
            break
        end
    end
    return all_small
end

# Function to compute reflection vector
function reflect(v, n)
    dvn = dot(v,n)
    rv  = SVector(v[1] - 2.0*dvn*n[1],
                  v[2] - 2.0*dvn*n[2],
                  v[3] - 2.0*dvn*n[3])
    return rv
end

# Function for getting random vector in unit sphere
function random_in_unit_sphere(::Type{T}) where{T <: AbstractFloat}
    while true
        c1 = rand(T)
        c2 = rand(T)
        c3 = rand(T)
        if c1*c1 + c2*c2 + c3*c3 < 1.0
            return SVector(c1, c2, c3)
        end
    end
end

function random_in_unit_sphere!(vec::AbstractVector{T}) where{T <: AbstractFloat}
    while true
        c1 = rand(T)
        c2 = rand(T)
        c3 = rand(T)
        if c1*c1 + c2*c2 + c3*c3 < 1.0
            vec[1] = c1
            vec[2] = c2
            vec[3] = c3
            return nothing
        end
    end
end

# Function for getting random unit vector
function random_unit_vector(::Type{T}) where{T <: AbstractFloat}
    vec     = random_in_unit_sphere(T)
    invNvec = 1.0 / norm(vec)
    return invNvec * vec
end

function random_unit_vector!(vec::AbstractVector{T}) where {T <: AbstractFloat}
    random_in_unit_sphere!(vec)
    invNvec = 1.0 / norm(vec)
    vec[1] *= invNvec
    vec[2] *= invNvec
    vec[3] *= invNvec
    return nothing
end
