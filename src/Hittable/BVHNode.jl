
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
    # Choose random axis to sort on
    axis = rand(1:3)
    comparator(a, b) = box_compare(a, b, axis, time0, time1) 

    if length(objects) == 1
            return BVHNode(true, objects[1], objects[1], bounding_box(objects[1], time0, time1))
    elseif length(objects) == 2
        if comparator(objects[1], objects[2])
            return BVHNode(false, objects[1], objects[2], 
                        surrounding_box(bounding_box(objects[1], time0, time1), 
                                        bounding_box(objects[2], time0, time1)))
        else
            return BVHNode(false, objects[2], objects[1], 
                        surrounding_box(bounding_box(objects[2], time0, time1),
                                        bounding_box(objects[1], time0, time1)))
        end
    end

    # Sort objects
    sort!(objects; lt = comparator)

    # Recursively build subtrees
    mid     = div(length(objects), 2) + 1
    left    = BVHNode(time0, time1, objects[1:mid])
    right   = BVHNode(time0, time1, objects[mid:end])
    return BVHNode(false, left, right, surrounding_box(left.box, right.box))
end

# Define bounding box method
bounding_box(node::BVHNode, time0, time1) = node.box

# Define fire_ray method
function fire_ray(ray_in::Ray, node::BVHNode, t_min, t_max)
    # Call hit on node bounding box
    if !hit(ray_in, node.box, t_min, t_max)
        return (false, false, -1.0, Ray(SVector(ray_in.orig...), SVector(ray_in.dir...), time(ray_in)), RGB(0.0, 0.0, 0.0))
    end

    # Call fire_ray on left and right nodes
    if node.same
        return fire_ray(ray_in, node.left, t_min, t_max)
    else
        hfl, sfl, tl, srl, al = fire_ray(ray_in, node.left, t_min, t_max)
        hfr, sfr, tr, srr, ar = fire_ray(ray_in, node.right, t_min, hfl ? tl : t_max)
        if hfr
            return true, sfr, tr, srr, ar
        elseif hfl 
            return true, sfl, tl, srl, al
        else
            return false, false, -1.0, Ray(SVector(ray_in.orig...), SVector(ray_in.dir...), time(ray_in)), RGB(0.0, 0.0, 0.0)
        end
    end
end

# ===== THE FOLLOWING METHODS ARE DEPRECIATED

# Define hit_time method
# New hit method returns
# flag, t, enough information to call scatter in a type stable way
function hit(ray::Ray, node::BVHNode, t_min, t_max)
    # Call hit on node bounding box
    if !hit(ray, node.box, t_min, t_max)
        return false, HitRecord()
    end

    # Call hit_time on left and right nodes
    if node.same
        return hit(ray, node.left, t_min, t_max)
    else
        fl, recl = hit(ray, node.left, t_min, t_max)
        fr, recr = hit(ray, node.right, t_min, fl ? recl.t : t_max)
        if fr
            return true, recr
        elseif fl 
            return true, recl
        else
            return false, recl
        end
    end
end

# Last retern variable is true if left is hit first, false if right is hit first
function min_hit_time(ray::Ray, node::BVHNode, t_min, t_max)
    # Call hit on node bounding box
    if !hit(ray, node.box, t_min, t_max)
        return false, -1.0, true
    end

    # Call hit_time on left and right nodes
    if node.same
        flag, t = hit_time(ray, node.left, t_min, t_max)
        return flag, t, true
    else
        fl, tl = hit_time(ray, node.left, t_min, t_max)
        fr, tr = hit_time(ray, node.right, t_min, fl ? tl : t_max)

        if fr
            return true, tr, false
        elseif fl
            return true, tl, true
        else
            return false, -1.0, true
        end
    end
end

function hit_time(ray::Ray, node::BVHNode, t_min, t_max)
    flag, t, left_hit_first = min_hit_time(ray, node, t_min, t_max)
    return flag, t
end

function scatter(ray::Ray, node::BVHNode, t_min, t_max)
    # Call min hit time on node
    flag, t, left_hit_first = min_hit_time(ray, node, t_min, t_max)

    # If we didn't hit anything, return false
    if !flag
        throw(ErrorException("Scatter called but hit not detected!"))
    end

    # Call scatter on node that was hit first
    if left_hit_first || node.same
        return scatter(ray, node.left, t_min, t_max)
    else
        return scatter(ray, node.right, t_min, t_max)
    end
end

