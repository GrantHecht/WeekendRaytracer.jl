@enum MaterialType begin
    lambertian = 1
    dielectric = 2
    metal      = 3
end

# Define material struct
struct Material{T,U} <: AbstractMaterial
    # Material type
    type::MaterialType

    # Albedo of the material
    albedo::T

    # Index of refraction for dielectric materials
    ir::U

    # Fuzzy reflection ratio
    fuzz::U
end

# Lambertian constructor
Lambertian(albedo_r::T, albedo_g::T, albedo_b::T) where {T} = 
    Material(lambertian, RGB(albedo_r, albedo_g, albedo_b), T(0.0), T(0.0))
Lambertian(albedo::AbstractArray{T}) where {T} = 
    Material(lambertian, RGB(albedo[1], albedo[2], albedo[3]), T(0.0), T(0.0))
Lambertian(albedo::RGB{T}) where {T} = 
    Material(lambertian, albedo, T(0.0), T(0.0))

# Dielectric constructor
Dielectric(ir::T) where {T} = 
    Material(dielectric, RGB(T(1.0), T(1.0), T(1.0)), ir, T(0.0)) 

# Metal constructor
Metal(albedo_r::T, albedo_g::T, albedo_b::T, fuzz::T) where {T} = 
    Material(metal, RGB(albedo_r, albedo_g, albedo_b), T(0.0), fuzz)
Metal(albedo::AbstractArray{T}, fuzz::T) where {T} = 
    Material(metal, RGB(albedo[1], albedo[2], albedo[3]), T(0.0), fuzz)
Metal(albedo::RGB{T}, fuzz::T) where {T} = 
    Material(metal, albedo, T(0.0), fuzz)

# Define scatter function
function scatter(ray_in::Ray, rec::HitRecord)
    if rec.mat.type == lambertian
        return lambertian_scatter(ray_in, rec)
    elseif rec.mat.type == dielectric
        return dielectric_scatter(ray_in, rec)
    elseif rec.mat.type == metal
        return metal_scatter(ray_in, rec)
    else
        throw(ArgumentError("Material type not recognized"))
    end
end

# Define lambertian scatter
function lambertian_scatter(ray_in::Ray, rec::HitRecord{R,U,M}) where {R,U,M}
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

# Define dielectric scatter
function dielectric_scatter(ray_in::Ray, rec::HitRecord)
    # Set refrection ration
    refraction_ratio = rec.front_face ? (1.0 / rec.mat.ir) : rec.mat.ir

    # Compute ray unit direction
    invNdir  = 1.0 / norm(ray_in.dir)
    unit_dir = SVector(invNdir*ray_in.dir[1],
                       invNdir*ray_in.dir[2],
                       invNdir*ray_in.dir[3])

    # Compute if we can refract
    cos_theta       = min(dot(-unit_dir, rec.normal), 1.0)
    sin_theta       = sqrt(1.0 - cos_theta*cos_theta)
    cannot_refract  = refraction_ratio * sin_theta > 1.0

    # Compute ray direction
    flag      = (cannot_refract || reflectance(cos_theta, refraction_ratio) > rand())
    direction = flag ? reflect(unit_dir, rec.normal) : 
                       refract(unit_dir, rec.normal, refraction_ratio)

    # Compute scattered ray
    scattered   = Ray(SVector(rec.p...), direction)
    attenuation = rec.mat.albedo
    flag        = true
    return flag, scattered, attenuation
end

# Define metal scatter
function metal_scatter(ray_in::Ray, rec::HitRecord{R,U,M}) where {R,U,M}
    # Compute reflected ray direction
    invNdir     = 1.0 / norm(ray_in.dir)
    unit_dir    = SVector(invNdir*ray_in.dir[1],
                          invNdir*ray_in.dir[2],
                          invNdir*ray_in.dir[3])
    reflected   = reflect(unit_dir, rec.normal)
    
    # Return bool indicating ray was scattered, the scattered ray, and attenuation
    rng_ref     = reflected + rec.mat.fuzz*random_in_unit_sphere(U)
    scattered   = Ray(SVector(rec.p...), rng_ref)
    attenuation = rec.mat.albedo
    flag        = dot(scattered.dir, rec.normal) > 0
    return flag, scattered, attenuation
end