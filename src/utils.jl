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
    T = promote_type(eltype(v), eltype(n))
    dvn = dot(v,n)
    return SA[
        v[1] - T(2.0)*dvn*n[1],
        v[2] - T(2.0)*dvn*n[2],
        v[3] - T(2.0)*dvn*n[3],
    ]
end

# Function to compute refraction vector
function refract(uv, n, etai_over_etat)
    T = promote_type(eltype(uv), eltype(n), typeof(etai_over_etat))
    cos_theta   = min(dot(-uv, n), one(T))
    r_out_perp  = SA[
        etai_over_etat * (uv[1] + cos_theta*n[1]),
        etai_over_etat * (uv[2] + cos_theta*n[2]),
        etai_over_etat * (uv[3] + cos_theta*n[3]),
    ]
    temp        = -sqrt(abs(one(T) - r_out_perp[1]^2 - r_out_perp[2]^2 - r_out_perp[3]^2))
    r_out_para  = SA[temp*n[1], temp*n[2], temp*n[3]]
    return SA[
        r_out_perp[1] + r_out_para[1],
        r_out_perp[2] + r_out_para[2],
        r_out_perp[3] + r_out_para[3],
    ]
end

# Function to compute reflectance
function reflectance(cosine::T, ref_idx) where T
    # Use Schlick's approximation for reflectance
    r0 = (one(T) - ref_idx) / (one(T) + ref_idx)
    r0 *= r0
    return r0 + (one(T) - r0)*(one(T) - cosine)^5
end

# Function for getting random vector in unit dist
function random_in_unit_disk(::Type{T}) where {T <: AbstractFloat}
    two = T(2.0)
    c1 = two*rand(T) - one(T)
    c2 = two*rand(T) - one(T)
    n  = T(0.5)
    return SA[n*c1, n*c2, zero(T)]
end

function random_in_unit_disk!(vec::AbstractVector{T}) where {T <: AbstractFloat}
    two = T(2.0)
    c1 = two*rand(T) - one(T)
    c2 = two*rand(T) - one(T)
    n  = T(0.5)
    vec[1] = n*c1
    vec[2] = n*c2
    vec[3] = zero(T)
    return nothing
end

# Function for getting random vector in unit sphere
function random_in_unit_sphere(::Type{T}) where{T <: AbstractFloat}
    two = T(2.0)
    c1 = two*rand(T) - one(T)
    c2 = two*rand(T) - one(T)
    c3 = two*rand(T) - one(T)
    n  = one(T) / T(3.0)
    return SA[n*c1, n*c2, n*c3]
end

function random_in_unit_sphere!(vec::AbstractVector{T}) where{T <: AbstractFloat}
    two = T(2.0)
    c1 = two*rand(T) - one(T)
    c2 = two*rand(T) - one(T)
    c3 = two*rand(T) - one(T)
    n  = one(T) / T(3.0)
    vec[1] = n*c1
    vec[2] = n*c2
    vec[3] = n*c3
    return nothing
end

# Function for getting random unit vector
function random_unit_vector(::Type{T}) where{T <: AbstractFloat}
    vec     = random_in_unit_sphere(T)
    invNvec = one(T) / norm(vec)
    return invNvec * vec
end

function random_unit_vector!(vec::AbstractVector{T}) where {T <: AbstractFloat}
    random_in_unit_sphere!(vec)
    invNvec = one(T) / norm(vec)
    vec[1] *= invNvec
    vec[2] *= invNvec
    vec[3] *= invNvec
    return nothing
end

# Trilinear interpolation
function trilinear_interp(c::AbstractArray{T}, u, v, w) where T
    accum = zero(T)
    for i = 0:1
        for j = 0:1
            for k = 0:1
                accum += (i*u + (1 - i)*(1 - u)) *
                         (j*v + (1 - j)*(1 - v)) *
                         (k*w + (1 - k)*(1 - w)) *
                         c[i + 1,j + 1,k + 1]
            end
        end
    end
    return accum
end

# Perlin interpolation
function perlin_interp(c::AbstractArray{T}, u, v, w) where T
    two = T(2.0)
    thr = T(3.0)
    uu = u*u*(thr - two*u)
    vv = v*v*(thr - two*v)
    ww = w*w*(thr - two*w)
    accum = zero(T)
    @inbounds for i = 0:1
        for j = 0:1
            for k = 0:1
                weight_v = SVector(u - i, v - j, w - k)
                accum += (i*uu + (1 - i)*(1 - uu)) *
                         (j*vv + (1 - j)*(1 - vv)) *
                         (k*ww + (1 - k)*(1 - ww)) *
                         dot(c[i + 1,j + 1,k + 1], weight_v)
            end
        end
    end
    return accum
end
