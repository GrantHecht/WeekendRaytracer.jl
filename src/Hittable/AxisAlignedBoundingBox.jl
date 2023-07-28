
struct AxisAlignedBoundingBox{T} <: BoundingBox
    min::T
    max::T
end

# Surrounding box method
function surrounding_box(box0::AxisAlignedBoundingBox, box1::AxisAlignedBoundingBox)
    small = SVector(min(box0.min[1], box1.min[1]),
                    min(box0.min[2], box1.min[2]),
                    min(box0.min[3], box1.min[3]))
    big   = SVector(max(box0.max[1], box1.max[1]),
                    max(box0.max[2], box1.max[2]),
                    max(box0.max[3], box1.max[3]))
    return AxisAlignedBoundingBox(small, big)
end

# Hit method
function hit(ray::Ray, aabb::AxisAlignedBoundingBox, t_min, t_max)
    @inbounds for a in 1:3
        invD    = 1.0 / ray.dir[a]
        t0      = (aabb.min[a] - ray.orig[a]) * invD
        t1      = (aabb.max[a] - ray.orig[a]) * invD
        if invD < 0.0
            t0, t1 = t1, t0
        end
        t_min = t0 > t_min ? t0 : t_min
        t_max = t1 < t_max ? t1 : t_max
        if t_max <= t_min
            return false
        end
    end
    return true
end
