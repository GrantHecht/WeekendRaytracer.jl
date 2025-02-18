
# Define Metal material
struct Metal{T <: AbstractTexture, U <: AbstractFloat} <: AbstractMaterial
    albedo::T
    fuzz::U

    function Metal(albedo_r::T, albedo_g::T, albedo_b::T, fuzz::U) where {T,U}
        return new{SolidColor{RGB{T}},U}(SolidColor(RGB(albedo_r, albedo_g, albedo_b)), fuzz)
    end
    function Metal(albedo::AbstractArray{T}, fuzz::U) where {T,U}
        if length(albedo) != 4
            throw(ArgumentError("albedo must be a 3-element array"))
        end
        return new{SolidColor{RGB{T}},U}(SolidColor(RGB(albedo[1], albedo[2], albedo[3])), fuzz)
    end
    function Metal(albedo::RGB{T}, fuzz::U) where {T,U}
        return new{SolidColor{RGB{T}},U}(SolidColor(albedo), fuzz)
    end
    function Metal(albedo::SolidColor{RGB{T}}, fuzz::U) where {T,U}
        return new{SolidColor{RGB{T}},U}(albedo, fuzz)
    end
end

# Define scatter function
function scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: Metal}
    # Compute reflected ray direction
    invNdir     = 1.0 / norm(ray_in.dir)
    unit_dir    = SA[
        invNdir*ray_in.dir[1],
        invNdir*ray_in.dir[2],
        invNdir*ray_in.dir[3],
    ]
    reflected   = reflect(unit_dir, rec.normal)

    # Return bool indicating ray was scattered, the scattered ray, and attenuation
    rng_ref     = reflected + rec.mat.fuzz*random_in_unit_sphere(U)
    scattered   = Ray(SA[rec.p[1], rec.p[2], rec.p[3]], rng_ref, time(ray_in))
    attenuation = value(rec.mat.albedo, rec.u, rec.v, rec.p)
    flag        = dot(scattered.dir, rec.normal) > 0
    return flag, scattered, attenuation
end
