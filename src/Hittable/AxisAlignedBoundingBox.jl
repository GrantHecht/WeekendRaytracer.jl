
struct AxisAlignedBoundingBox{T} <: BoundingBox
    min::T
    max::T
end

# Construct box for 4 points
function FourPointAABB(p1, p2, p3, p4)
    delta = 0.0001
    half_delta = delta / 2.0

    # Construct box for p1 and p2
    xmin = min(p1[1],p2[1]); xmax = max(p1[1],p2[1])
    ymin = min(p1[2],p2[2]); ymax = max(p1[2],p2[2])
    zmin = min(p1[3],p2[3]); zmax = max(p1[3],p2[3])

    if xmax - xmin  < delta; xmin - half_delta; xmax + half_delta; end
    if ymax - ymin  < delta; ymin - half_delta; ymax + half_delta; end
    if zmax - zmin  < delta; zmin - half_delta; zmax + half_delta; end

    box1 = AxisAlignedBoundingBox(SA[xmin,ymin,zmin], SA[xmax,ymax,zmax])

    # Construct box for p3 and p4
    xmin = min(p3[1],p4[1]); xmax = max(p3[1],p4[1])
    ymin = min(p3[2],p4[2]); ymax = max(p3[2],p4[2])
    zmin = min(p3[3],p4[3]); zmax = max(p3[3],p4[3])

    if xmax - xmin  < delta; xmin - half_delta; xmax + half_delta; end
    if ymax - ymin  < delta; ymin - half_delta; ymax + half_delta; end
    if zmax - zmin  < delta; zmin - half_delta; zmax + half_delta; end

    box2 = AxisAlignedBoundingBox(SA[xmin,ymin,zmin], SA[xmax,ymax,zmax])

    return surrounding_box(box1, box2)
end

# Translate method through summation
function Base.:+(box::AxisAlignedBoundingBox, offset::T) where {T}
    new_min = SA[
        box.min[1] + offset[1],
        box.min[2] + offset[2],
        box.min[3] + offset[3]
    ]
    new_max = SA[
        box.max[1] + offset[1],
        box.max[2] + offset[2],
        box.max[3] + offset[3]
    ]
    return AxisAlignedBoundingBox(new_min,new_max)
end
function Base.:+(offset::T, box::AxisAlignedBoundingBox) where {T}
    return box + offset
end

# Get the longest axis
function longest_axis(box::AxisAlignedBoundingBox)
    xsize = box.max[1] - box.min[1]
    ysize = box.max[2] - box.min[2]
    zsize = box.max[3] - box.min[3]
    if xsize > ysize
        return xsize > zsize ? 1 : 3
    else
        return ysize > zsize ? 2 : 3
    end
end

# Surrounding box method
function surrounding_box(box0::AxisAlignedBoundingBox, box1::AxisAlignedBoundingBox)
    small = SA[
        min(box0.min[1], box1.min[1]),
        min(box0.min[2], box1.min[2]),
        min(box0.min[3], box1.min[3]),
    ]
    big   = SA[
        max(box0.max[1], box1.max[1]),
        max(box0.max[2], box1.max[2]),
        max(box0.max[3], box1.max[3]),
    ]
    return AxisAlignedBoundingBox(small, big)
end

# Hit method
function hit(ray::Ray, aabb::AxisAlignedBoundingBox, t_min, t_max)
    is_hit = true
    @inbounds for a in 1:3
        invD    = 1.0 / ray.dir[a]
        v0      = (aabb.min[a] - ray.orig[a]) * invD
        v1      = (aabb.max[a] - ray.orig[a]) * invD
        is_pos  = invD > 0.0
        t0      = ifelse(is_pos, v0, v1)
        t1      = ifelse(is_pos, v1, v0)
        t_min   = ifelse(t0 > t_min, t0, t_min)
        t_max   = ifelse(t1 < t_max, t1, t_max)

        if t_max <= t_min
            return false
            #is_hit = false
            #break
        end
    end
    #return is_hit
    return true
end
