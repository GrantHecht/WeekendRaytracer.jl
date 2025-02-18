
struct BVHNode{LT   <: AbstractHittable,
               RT   <: AbstractHittable,
               AABB <: AxisAlignedBoundingBox} <: HittableCollection
    same    ::Bool
    left    ::LT
    right   ::RT
    box     ::AABB
end

# Define new Base.show method
function Base.show(io::Base.IO, node::BVHNode)
    println(io, "BVHNode: Add nice Base.show later...")
end

# Define constructor
function BVHNode(time0::AbstractFloat, time1::AbstractFloat, objects::AbstractArray)
    # Build the bounding box for all objects and get longest axis
    bbox = AxisAlignedBoundingBox(SA[Inf,Inf,Inf], SA[-Inf,-Inf,-Inf])
    for obj in objects
        bbox = surrounding_box(bbox, bounding_box(obj, time0, time1))
    end
    axis = longest_axis(bbox)

    # Choose axis to sort on
    comparator(a, b) = box_compare(a, b, axis, time0, time1)

    if length(objects) == 1
            return BVHNode(true, objects[1], objects[1], bbox)
    elseif length(objects) == 2
        if comparator(objects[1], objects[2])
            return BVHNode(false, objects[1], objects[2], bbox)
        else
            return BVHNode(false, objects[2], objects[1], bbox)
        end
    end

    # Sort objects
    sort!(objects; lt = comparator)

    # Recursively build subtrees
    mid     = div(length(objects), 2) + 1
    left    = BVHNode(time0, time1, objects[1:mid])
    right   = BVHNode(time0, time1, objects[mid:end])
    return BVHNode(false, left, right, bbox)
end

# Define bounding box method
bounding_box(node::BVHNode, time0, time1) = node.box

# Define fire_ray method
function fire_ray(ray_in::Ray, node::BVHNode, t_min, t_max)
    # Call hit on node bounding box
    if !hit(ray_in, node.box, t_min, t_max)
        return (
            false, false, -1.0,
            Ray(
                SA[ray_in.orig[1], ray_in.orig[2], ray_in.orig[3]],
                SA[ray_in.dir[1], ray_in.dir[2], ray_in.dir[3]],
                time(ray_in),
            ),
            RGB(0.0, 0.0, 0.0), RGB(0.0, 0.0, 0.0))
    end

    # Call fire_ray on left and right nodes
    if node.same
        return fire_ray(ray_in, node.left, t_min, t_max)
    else
        hfl, sfl, tl, srl, al, el = fire_ray(ray_in, node.left, t_min, t_max)
        hfr, sfr, tr, srr, ar, er = fire_ray(ray_in, node.right, t_min, hfl ? tl : t_max)
        if hfr
            return true, sfr, tr, srr, ar, er
        elseif hfl
            return true, sfl, tl, srl, al, el
        else
            return (false, false, -1.0, Ray(SVector(ray_in.orig...), SVector(ray_in.dir...), time(ray_in)),
                RGB(0.0, 0.0, 0.0), RGB(0.0, 0.0, 0.0))
        end
    end
end

# Define unsafe hit method. This should only be used in cases where all primitives
# in the BVH are the same material "mat"
function unsafe_hit(
    ray_in::Ray,
    node::BVHNode,
    mat::AbstractMaterial,
    t_min, t_max,
)
    # Call hit on node bounding box
    if !hit(ray_in, node.box, t_min, t_max)
        return false, HitRecord(SA[0.0,0.0,0.0], SA[0.0,0.0,0.0], -1.0, 0.0, 0.0, mat, true)
    end

    return unsafe_hit_left_right(ray_in, node, mat, t_min, t_max)
end

# Define helper functions for unsafe hit
function unsafe_hit_left_right(
    ray_in::Ray,
    node::BVHNode{LT,RT},
    mat::M,
    t_min, t_max,
) where {LT <: HittableObject, RT <: HittableObject, M <: AbstractMaterial}
    if node.same
        return hit(ray_in, node.left, t_min, t_max)
    end
    hflag_left, rec_left    = hit(ray_in, node.left, t_min, t_max)
    hflag_right, rec_right  = hit(ray_in, node.right, t_min, hflag_left ? rec_left.t : t_max)
    if hflag_right
        return hflag_right, rec_right
    elseif hflag_left
        return hflag_left, rec_left
    else
        return hflag_left, rec_left
    end
end
function unsafe_hit_left_right(
    ray_in::Ray,
    node::BVHNode{LT,RT},
    mat::M,
    t_min, t_max,
) where {LT <: HittableObject, RT <: HittableCollection, M <: AbstractMaterial}
    hflag_left, rec_left    = hit(ray_in, node.left, t_min, t_max)
    hflag_right, rec_right  = unsafe_hit(ray_in, node.right, mat, t_min, hflag_left ? rec_left.t : t_max)
    if hflag_right
        return hflag_right, rec_right
    elseif hflag_left
        return hflag_left, rec_left
    else
        return hflag_left, rec_left
    end
end
function unsafe_hit_left_right(
    ray_in::Ray,
    node::BVHNode{LT,RT},
    mat::M,
    t_min, t_max,
) where {LT <: HittableCollection, RT <: HittableObject, M <: AbstractMaterial}
    hflag_left, rec_left    = unsafe_hit(ray_in, node.left, mat, t_min, t_max)
    hflag_right, rec_right  = hit(ray_in, node.right, t_min, hflag_left ? rec_left.t : t_max)
    if hflag_right
        return hflag_right, rec_right
    elseif hflag_left
        return hflag_left, rec_left
    else
        return hflag_left, rec_left
    end
end
function unsafe_hit_left_right(
    ray_in::Ray,
    node::BVHNode{LT,RT},
    mat::M,
    t_min, t_max,
) where {LT <: HittableCollection, RT <: HittableCollection, M <: AbstractMaterial}
    if node.same
        return unsafe_hit(ray_in, node.left, mat, t_min, t_max)
    end
    hflag_left, rec_left    = unsafe_hit(ray_in, node.left, mat, t_min, t_max)
    hflag_right, rec_right  = unsafe_hit(ray_in, node.right, mat, t_min, hflag_left ? rec_left.t : t_max)
    if hflag_right
        return hflag_right, rec_right
    elseif hflag_left
        return hflag_left, rec_left
    else
        return hflag_left, rec_left
    end
end
