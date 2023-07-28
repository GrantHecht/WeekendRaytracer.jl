
# Define Metal material
struct Metal{T,U <: AbstractFloat} <: AbstractMaterial
    albedo::T
    fuzz::U
end

# Define constructor
function Metal(albedo_r::T, albedo_g::T, albedo_b::T, fuzz::T) where {T}
    return Metal(RGB(albedo_r, albedo_g, albedo_b), fuzz)
end
function Metal(albedo::AbstractArray, fuzz::AbstractFloat)
    if length(albedo) != 4
        throw(ArgumentError("albedo must be a 3-element array"))
    end
    return Metal(RGB(albedo[1], albedo[2], albedo[3]), fuzz)
end

# Define scatter function
function scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: Metal}
    # Compute reflected ray direction
    invNdir     = 1.0 / norm(ray_in.dir)
    unit_dir    = SVector(invNdir*ray_in.dir[1],
                          invNdir*ray_in.dir[2],
                          invNdir*ray_in.dir[3])
    reflected   = reflect(unit_dir, rec.normal)
    
    # Return bool indicating ray was scattered, the scattered ray, and attenuation
    rng_ref     = reflected + rec.mat.fuzz*random_in_unit_sphere(U)
    scattered   = Ray(SVector(rec.p...), rng_ref, time(ray_in))
    attenuation = rec.mat.albedo
    flag        = dot(scattered.dir, rec.normal) > 0
    return flag, scattered, attenuation
end