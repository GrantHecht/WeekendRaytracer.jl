
# Define Dielectric struct
struct Dielectric{T} <: AbstractMaterial
    ir::T
end

# Define scatter
function scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: Dielectric}
    # Set attenuation
    attenuation = RGB(1.0,1.0,1.0)

    # Set refrection ration
    refraction_ratio = rec.front_face ? (1.0 / rec.mat.ir) : rec.mat.ir

    # Compute ray unit direction
    invNdir  = 1.0 / norm(ray_in.dir)
    unit_dir = SA[
        invNdir*ray_in.dir[1],
        invNdir*ray_in.dir[2],
        invNdir*ray_in.dir[3],
    ]

    # Compute if we can refract
    cos_theta       = min(dot(-unit_dir, rec.normal), 1.0)
    sin_theta       = sqrt(1.0 - cos_theta*cos_theta)
    cannot_refract  = refraction_ratio * sin_theta > 1.0

    # Compute ray direction
    flag      = (cannot_refract || reflectance(cos_theta, refraction_ratio) > rand())
    direction = flag ? reflect(unit_dir, rec.normal) :
                       refract(unit_dir, rec.normal, refraction_ratio)

    # Compute scattered ray
    scattered = Ray(SA[rec.p[1], rec.p[2], rec.p[3]], direction, time(ray_in))
    flag      = true
    return flag, scattered, attenuation
end
