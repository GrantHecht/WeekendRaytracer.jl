
# Define Lambertian material
struct Lambertian{T} <: AbstractMaterial
    albedo::T
end

# Define constructor
function Lambertian(albedo_r::T, albedo_g::T, albedo_b::T) where {T}
    return Lambertian(RGB(albedo_r, albedo_g, albedo_b))
end
function Lambertian(albedo::AbstractArray)
    if length(albedo) != 3
        throw(ArgumentError("albedo must be a 3-element array"))
    end
    return Lambertian(RGB(albedo[1], albedo[2], albedo[3]))
end

function scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: Lambertian}
    # Compute scatter direction
    ruv               = random_unit_vector(U)
    scatter_direction = SVector(rec.normal[1] - ruv[1],
                                rec.normal[2] - ruv[2],
                                rec.normal[3] - ruv[3])

    # Catch degenerate scatter direction
    if near_zero(scatter_direction)
        scatter_direction = SVector(rec.normal...)
    end

    # Return bool indicating ray was scattered, the scattered ray, and attenuation
    scattered   = Ray(SVector(rec.p...), scatter_direction)
    attenuation = rec.mat.albedo
    flag        = true
    return flag, scattered, attenuation
end