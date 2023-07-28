
# Define Lambertian material
struct Lambertian{T <: AbstractTexture} <: AbstractMaterial
    albedo::T

    # Define constructor
    Lambertian(albedo_r::T, albedo_g::T, albedo_b::T) where {T <: AbstractFloat} = 
        new{SolidColor{RGB{T}}}(SolidColor(RGB{T}(albedo_r, albedo_g, albedo_b)))
    Lambertian(albedo::AbstractArray{T}) where {T <: AbstractFloat} = 
        new{SolidColor{RGB{T}}}(SolidColor(RGB{T}(albedo[1], albedo[2], albedo[3])))
    Lambertian(albedo::RGB{T}) where {T <: AbstractFloat} = 
        new{SolidColor{RGB{T}}}(SolidColor(albedo))
    Lambertian(albedo::T) where {T <: AbstractTexture} = 
        new{T}(albedo)
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
    scattered   = Ray(SVector(rec.p...), scatter_direction, time(ray_in))
    attenuation = value(rec.mat.albedo, rec.u, rec.v, rec.p)
    flag        = true
    return flag, scattered, attenuation
end