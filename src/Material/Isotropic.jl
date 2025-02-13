
struct Isotropic{T <: AbstractTexture} <: AbstractMaterial
    albedo::T

    # Define constructor
    Isotropic(albedo_r::T, albedo_g::T, albedo_b::T) where {T <: AbstractFloat} =
        new{SolidColor{RGB{T}}}(SolidColor(RGB{T}(albedo_r, albedo_g, albedo_b)))
    Isotropic(albedo::AbstractArray{T}) where {T <: AbstractFloat} =
        new{SolidColor{RGB{T}}}(SolidColor(RGB{T}(albedo[1], albedo[2], albedo[3])))
    Isotropic(albedo::RGB{T}) where {T <: AbstractFloat} =
        new{SolidColor{RGB{T}}}(SolidColor(albedo))
    Isotropic(albedo::T) where {T <: AbstractTexture} =
        new{T}(albedo)
end

function scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: Isotropic}
    scattered   = Ray(SA[rec.p[1], rec.p[2], rec.p[3]], random_unit_vector(U), time(ray_in))
    attenuation = value(rec.mat.albedo, rec.u, rec.v, rec.p)
    flag        = true
    return flag, scattered, attenuation
end
