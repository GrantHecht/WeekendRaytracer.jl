
struct ConstantMedium{O <: AbstractHittable, T, CT} <: HittableObject
    obj::O
    neg_inv_density::T
    mat::Isotropic{SolidColor{RGB{CT}}}
end

function ConstantMediumSphere(center0, center1, time0, time1, r, density, albedo_r, albedo_g, albedo_b)
    mat = Isotropic(albedo_r, albedo_g, albedo_b)
    return ConstantMedium(
        Sphere(center0, center1, time0, time1, r, mat),
        1.0 / density, mat,
    )
end
function ConstantMediumSphere(
    center0, center1, time0, time1, r, density, albedo::A,
) where {A <: Union{AbstractArray, RGB, SolidColor}}
    mat = Isotropic(albedo)
    return ConstantMedium(
        Sphere(center0, center1, time0, time1, r, mat),
        1.0 / density, mat,
    )
end
ConstantMediumSphere(center,r,density,albedo_r,albedo_g,albedo_b) =
    ConstantMediumSphere(center,center,0.0,0.0,r,density,albedo_r,albedo_g,albedo_b)
ConstantMediumSphere(center,r,density,albedo) =
    ConstantMediumSphere(center,center,0.0,0.0,r,density,albedo)
function ConstantMedium(sphere::S,density,albedo_r,albedo_g,albedo_b) where {S <: Sphere}
    return ConstantMediumSphere(
        sphere.center0, sphere.center1,
        sphere.time0, sphere.time1, sphere.radius,
        density, albedo_r, albedo_g, albedo_b)
end
function ConstantMedium(
    sphere::S,density,albedo::A,
) where {S <: Sphere, A <: Union{AbstractArray, RGB, SolidColor}}
    return ConstantMediumSphere(
        sphere.center0, sphere.center1,
        sphere.time0, sphere.time1, sphere.radius,
        density, albedo)
end

function ConstantMediumBox(p0, p1, density, albedo_r, albedo_g, albedo_b)
    # Construct box
    mat = Isotropic(albedo_r, albedo_g, albedo_b)
    return ConstantMedium(Box(p0, p1, mat), -1.0/density, mat)
end
function ConstantMediumBox(
    p0, p1, density, albedo::A,
) where {A <: Union{AbstractArray, RGB, SolidColor}}
    # Construct box
    mat = Isotropic(albedo)
    return ConstantMedium(Box(p0, p1, mat), -1.0/density, mat)
end

# hit implementations
function hit(ray_in::Ray, cmb::ConstantMedium{O}, t_min, t_max) where {O <: HittableObject}
    hflag1, rec1 = hit(ray_in, cmb.obj, -Inf, Inf)
    if !hflag1
        return hflag1, rec1
    end

    hflag2, rec2 = hit(ray_in, cmb.obj, rec1.t + 0.0001, Inf)
    if !hflag2
        return hflag2, rec2
    end

    t_hit1 = rec1.t
    t_hit2 = rec2.t
    if t_hit1 < t_min; t_hit1 = t_min; end
    if t_hit2 > t_max; t_hit2 = t_max; end

    if t_hit1 >= t_hit2
        return false, rec1
    end

    if t_hit1 < 0.0
        t_hit1 = 0.0
    end

    ray_length = norm(ray_in.dir)
    distance_inside_boundary = (t_hit2 - t_hit1)*ray_length
    hit_distance = cmb.neg_inv_density*log(rand())

    if hit_distance > distance_inside_boundary
        return false, rec1
    end

    t_hit = t_hit1 + hit_distance / ray_length
    p = at(ray_in, t_hit)
    return true, HitRecord(p, SA[1.0,0.0,0.0], t_hit, 0.0, 0.0, cmb.mat, true)
end

# Define bounding box
bounding_box(cmb::ConstantMedium, time0, time1) =
    bounding_box(cmb.obj, time0, time1)
