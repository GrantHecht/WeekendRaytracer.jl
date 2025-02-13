
struct ConstantMediumBox{B <: Box, T} <: AbstractHittable
    obj::B
    neg_inv_density::T
end

function ConstantMediumBox(p0, p1, density, albedo_r, albedo_g, albedo_b)
    # Construct box
    box = Box(p0, p1, Isotropic(albedo_r, albedo_g, albedo_b))
    return ConstantMediumBox(box, -1.0/density)
end
function ConstantMediumBox(
    p0, p1, density, albedo::A,
) where {A <: Union{AbstractArray, SolidColor}}
    # Construct box
    box = Box(p0, p1, Isotropic(albedo))
    return ConstantMediumBox(box, -1.0/density)
end

# The following could probably be optimized a decent bit since we have to
# essentially redo the hit check
function fire_ray(ray_in::Ray, cmb::ConstantMediumBox, t_min, t_max)
    # Fire rays at the box
    hflag_1, sflag_1, t_hit_1, sray_1, attenuation_1, emitted_1 =
        fire_ray(ray_in, cmb.obj, -Inf, Inf)
    if !hflag_1
        return false, false, t_hit_1, sray_1, attenuation_1, emitted_1
    end

    hflag_2, sflag_2, t_hit_2, sray_2, attenuation_2, emitted_2 =
        fire_ray(ray_in, cmb.obj, t_hit_1 + 0.0001, Inf)
    if !hflag_2
        return false, false, t_hit_2, sray_2, attenuation_2, emitted_2
    end

    if t_hit_1 < t_min; t_hit_1 = t_min; end
    if t_hit_2 > t_max; t_hit_2 = t_max; end

    if t_hit_1 >= t_hit_2
        return false, false, t_hit_1, sray_1, attenuation_1, emitted_1
    end

    if t_hit_1 < 0.0; t_hit_1 = 0.0; end

    ray_length = norm(ray_in.dir)
    distance_inside_boundary = (t_hit_2 - t_hit_1) * ray_length
    hit_distance = cmb.neg_inv_density * log(rand())

    if hit_distance > distance_inside_boundary
        return false, false, t_hit_1, sray_1, attenuation_1, emitted_1
    end

    t_hit = t_hit_1 + hit_distance / ray_length
    p     = at(ray_in, t_hit)

    scattered   = Ray(SA[p[1],p[2],p[3]], sray_2.dir, time(ray_in))
    attenuation = attenuation_2

    return true, true, t_hit, scattered, attenuation, emitted_2
end

# Define bounding box
bounding_box(cmb::ConstantMediumBox, time0, time1) =
    bounding_box(cmb.obj, time0, time1)
