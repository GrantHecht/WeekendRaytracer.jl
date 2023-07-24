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

# Function to compute refraction vector
function refract(uv, n, etai_over_etat)
    cos_theta   = min(dot(-uv, n), 1.0)
    r_out_perp  = SVector(etai_over_etat * (uv[1] + cos_theta*n[1]),
                          etai_over_etat * (uv[2] + cos_theta*n[2]),
                          etai_over_etat * (uv[3] + cos_theta*n[3]))
    temp        = -sqrt(abs(1.0 - r_out_perp[1]^2 - r_out_perp[2]^2 - r_out_perp[3]^2))
    r_out_para  = SVector(temp*n[1], temp*n[2], temp*n[3])
    rv          = SVector(r_out_perp[1] + r_out_para[1],
                          r_out_perp[2] + r_out_para[2],
                          r_out_perp[3] + r_out_para[3])
    return rv
end

# Function to compute reflectance
function reflectance(cosine, ref_idx)
    # Use Schlick's approximation for reflectance
    r0 = (1.0 - ref_idx) / (1.0 + ref_idx)
    r0 *= r0
    return r0 + (1.0 - r0)*(1.0 - cosine)^5
end

# Function for getting random vector in unit dist
function random_in_unit_disk(::Type{T}) where {T <: AbstractFloat}
    #while true
    #    c1 = 2.0*rand(T) - 1.0
    #    c2 = 2.0*rand(T) - 1.0
    #    if c1*c1 + c2*c2 < 1.0
    #        return SVector(c1, c2, 0.0)
    #    end
    #end
    c1 = 2.0*rand(T) - 1.0
    c2 = 2.0*rand(T) - 1.0
    n  = 0.5
    return SVector(n*c1, n*c2, 0.0)
end

function random_in_unit_disk!(vec::AbstractVector{T}) where {T <: AbstractFloat}
    #while true
    #    c1 = 2.0*rand(T) - 1.0
    #    c2 = 2.0*rand(T) - 1.0
    #    if c1*c1 + c2*c2 < 1.0
    #        vec[1] = c1
    #        vec[2] = c2
    #        vec[3] = 0.0
    #        return nothing
    #    end
    #end
    c1 = 2.0*rand(T) - 1.0
    c2 = 2.0*rand(T) - 1.0
    n  = 0.5
    vec[1] = n*c1
    vec[2] = n*c2
    vec[3] = 0.0
    return nothing
end

# Function for getting random vector in unit sphere
function random_in_unit_sphere(::Type{T}) where{T <: AbstractFloat}
    #while true
    #    c1 = 2.0*rand(T) - 1.0
    #    c2 = 2.0*rand(T) - 1.0
    #    c3 = 2.0*rand(T) - 1.0
    #    if c1*c1 + c2*c2 + c3*c3 < 1.0
    #        return SVector(c1, c2, c3)
    #    end
    #end
    c1 = 2.0*rand(T) - 1.0
    c2 = 2.0*rand(T) - 1.0
    c3 = 2.0*rand(T) - 1.0
    n  = 1.0 / 3.0
    return SVector(n*c1, n*c2, n*c3)
end

function random_in_unit_sphere!(vec::AbstractVector{T}) where{T <: AbstractFloat}
    #while true
    #    c1 = 2.0*rand(T) - 1.0
    #    c2 = 2.0*rand(T) - 1.0
    #    c3 = 2.0*rand(T) - 1.0
    #    if c1*c1 + c2*c2 + c3*c3 < 1.0
    #        vec[1] = c1
    #        vec[2] = c2
    #        vec[3] = c3
    #        return nothing
    #    end
    #end
    c1 = 2.0*rand(T) - 1.0
    c2 = 2.0*rand(T) - 1.0
    c3 = 2.0*rand(T) - 1.0
    n  = 1.0 / 3.0
    vec[1] = n*c1
    vec[2] = n*c2
    vec[3] = n*c3
    return nothing
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
