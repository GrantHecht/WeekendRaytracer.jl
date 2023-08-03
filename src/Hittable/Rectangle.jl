# Define rectangle structs
struct XYRectangle{T, M <: AbstractMaterial} <: HittableRectangle
    x0  ::T
    x1  ::T
    y0  ::T
    y1  ::T
    k   ::T
    mat ::M
end

struct XZRectangle{T, M <: AbstractMaterial} <: HittableRectangle
    x0  ::T
    x1  ::T
    z0  ::T
    z1  ::T
    k   ::T
    mat ::M
end

struct YZRectangle{T, M <: AbstractMaterial} <: HittableRectangle
    y0  ::T
    y1  ::T
    z0  ::T
    z1  ::T
    k   ::T
    mat ::M
end

# Define constructors
function XYRectangle(xs::T, ys::T, k, mat) where {T}
    return XYRectangle(xs[1], xs[2], ys[1], ys[2], k, mat)
end
function XZRectangle(xs::T, zs::T, k, mat) where {T}
    return XZRectangle(xs[1], xs[2], zs[1], zs[2], k, mat)
end
function YZRectangle(ys::T, zs::T, k, mat) where {T}
    return YZRectangle(ys[1], ys[2], zs[1], zs[2], k, mat)
end

# Define bounding box method
function bounding_box(r::XYRectangle, time0, time1)
    return AxisAlignedBoundingBox(
        SVector(r.x0, r.y0, r.k - 0.0001),
        SVector(r.x1, r.y1, r.k + 0.0001)
    )
end
function bounding_box(r::XZRectangle, time0, time1)
    return AxisAlignedBoundingBox(
        SVector(r.x0, r.k - 0.0001, r.z0),
        SVector(r.x1, r.k + 0.0001, r.z1)
    )
end
function bounding_box(r::YZRectangle, time0, time1)
    return AxisAlignedBoundingBox(
        SVector(r.k - 0.0001, r.y0, r.z0),
        SVector(r.k + 0.0001, r.y1, r.z1)
    )
end

# Define hit method
function hit(ray::Ray, r::XYRectangle, t_min, t_max)
    t = (r.k - ray.orig[3]) / ray.dir[3]
    if t < t_min || t > t_max
        return false, HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, 0.0, 0.0, r.mat, true)
    end
    x = ray.orig[1] + t*ray.dir[1]
    y = ray.orig[2] + t*ray.dir[2]
    if x < r.x0 || x > r.x1 || y < r.y0 || y > r.y1
        return false, HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, 0.0, 0.0, r.mat, true)
    end
    u           = (x - r.x0) / (r.x1 - r.x0)
    v           = (y - r.y0) / (r.y1 - r.y0)
    p           = at(ray, t)
    on          = SVector(0.0, 0.0, 1.0)
    front_face  = dot(ray.dir, on) < 0.0
    normal      = front_face ? on : -on
    rec         = HitRecord(p, normal, t, u, v, r.mat, front_face)
    return true, rec
end
function hit(ray::Ray, r::XZRectangle, t_min, t_max)
    t = (r.k - ray.orig[2]) / ray.dir[2]
    if t < t_min || t > t_max
        return false, HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, 0.0, 0.0, r.mat, true)
    end
    x = ray.orig[1] + t*ray.dir[1]
    z = ray.orig[3] + t*ray.dir[3]
    if x < r.x0 || x > r.x1 || z < r.z0 || z > r.z1
        return false, HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, 0.0, 0.0, r.mat, true)
    end
    u           = (x - r.x0) / (r.x1 - r.x0)
    v           = (z - r.z0) / (r.z1 - r.z0)
    p           = at(ray, t)
    on          = SVector(0.0, 1.0, 0.0)
    front_face  = dot(ray.dir, on) < 0.0
    normal      = front_face ? on : -on
    rec         = HitRecord(p, normal, t, u, v, r.mat, front_face)
    return true, rec
end
function hit(ray::Ray, r::YZRectangle, t_min, t_max)
    t = (r.k - ray.orig[1]) / ray.dir[1]
    if t < t_min || t > t_max
        return false, HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, 0.0, 0.0, r.mat, true)
    end
    y = ray.orig[2] + t*ray.dir[2]
    z = ray.orig[3] + t*ray.dir[3]
    if y < r.y0 || y > r.y1 || z < r.z0 || z > r.z1
        return false, HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, 0.0, 0.0, r.mat, true)
    end
    u           = (y - r.y0) / (r.y1 - r.y0)
    v           = (z - r.z0) / (r.z1 - r.z0)
    p           = at(ray, t)
    on          = SVector(1.0, 0.0, 0.0)
    front_face  = dot(ray.dir, on) < 0.0
    normal      = front_face ? on : -on
    rec         = HitRecord(p, normal, t, u, v, r.mat, front_face)
    return true, rec
end

# Define fire_ray methods
function fire_ray(ray_in::Ray, r::HittableRectangle, t_min, t_max)
    hflag, rec  = hit(ray_in, r, t_min, t_max)
    t_hit       = rec.t
    sflag, scattered, attenuation = scatter(ray_in, rec)
    emitted     = emit(rec)
    return hflag, sflag, t_hit, scattered, attenuation, emitted
end