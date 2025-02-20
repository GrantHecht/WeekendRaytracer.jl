
struct BVHNode{LT   <: AbstractHittable,
               RT   <: AbstractHittable,
               AABB <: AxisAlignedBoundingBox} <: HittableCollection
    same    ::Bool
    left    ::LT
    right   ::RT
    box     ::AABB
end

# Define struct flags for different BVH construction methods
abstract type AbstractBVHConstruction end
struct MedianSplit <: AbstractBVHConstruction end
struct SAH{T} <: AbstractBVHConstruction
    Ct::T
    Ci::T
    function SAH()
        return new{Float64}(1.0,1.0)
    end
    function SAH(Ct::T, Ci::T) where T
        return new{T}(Ct,Ci)
    end
end

# Define constructors
function BVHNode(
    time0::AbstractFloat,
    time1::AbstractFloat,
    objects::AbstractArray,
    builder::MedianSplit,
)
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
    left    = BVHNode(time0, time1, objects[1:mid-1], builder)
    right   = BVHNode(time0, time1, objects[mid:end], builder)
    return BVHNode(false, left, right, bbox)
end
BVHNode(time0, time1, objects) = BVHNode(time0,time1,objects,MedianSplit())

function BVHNode(
    time0::AbstractFloat,
    time1::AbstractFloat,
    objects::AbstractArray,
    builder::SAH,
)
    # Get cost scalars and number of objects
    Ct = builder.Ct
    Ci = builder.Ci
    n = length(objects)

    # Build the bounding box for all objects and get longest axis
    bbox = AxisAlignedBoundingBox(SA[Inf,Inf,Inf], SA[-Inf,-Inf,-Inf])
    for obj in objects
        bbox = surrounding_box(bbox, bounding_box(obj, time0, time1))
    end

    # Make leaf
    if n <= 2
        if n == 1
                return BVHNode(true, objects[1], objects[1], bbox)
        else
            comparator(a, b) = box_compare(a, b, 1, time0, time1)
            if comparator(objects[1], objects[2])
                return BVHNode(false, objects[1], objects[2], bbox)
            else
                return BVHNode(false, objects[2], objects[1], bbox)
            end
        end
    end

    A_parent = surface_area(bbox)
    best_cost = Inf
    best_axis = 0
    best_split = 0
    best_objs_sorted = nothing

    # Try each axis
    left_boxes = Vector{typeof(bbox)}(undef, n)
    right_boxes = Vector{typeof(bbox)}(undef, n)
    for axis in 1:3
        # Sort the objects along the current axis
        sort!(objects; lt = (a,b) -> box_compare(a,b, axis, time0, time1))

        # Precompute cumulative bounding boxes from the left
        left_boxes[1] = bounding_box(objects[1], time0, time1)
        for i in 2:n
            left_boxes[i] = surrounding_box(
                left_boxes[i-1],
                bounding_box(objects[i], time0, time1),
            )
        end

        # Precompute cumulative bounding boxes from the right
        right_boxes[n] = bounding_box(objects[n], time0, time1)
        for i in (n-1):-1:1
            right_boxes[i] = surrounding_box(
                right_boxes[i+1],
                bounding_box(objects[i], time0, time1),
            )
        end

        # Try each possible split: objects[1:i] vs objects[i+1:end].
        best_set = false
        for i in 1:(n-1)
            A_left = surface_area(left_boxes[i])
            A_right = surface_area(right_boxes[i+1])
            N_left = i
            N_right = n - i
            cost = Ct + (A_left / A_parent) * N_left * Ci + (A_right / A_parent) * N_right * Ci
            if cost < best_cost
                best_cost = cost
                best_axis = axis
                best_split = i
                best_set = true
            end
        end
        if best_set
            best_objs_sorted = copy(objects)
        end
    end

    # Partition the objects along the best axis using the best split index.
    left_objs = best_objs_sorted[1:best_split]
    right_objs = best_objs_sorted[best_split+1:end]

    left_node = BVHNode(time0, time1, left_objs, builder)
    right_node = BVHNode(time0, time1, right_objs, builder)
    return BVHNode(false, left_node, right_node, bbox)
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
        hfr, sfr, tr, srr, ar, er = fire_ray(ray_in, node.right, t_min, ifelse(hfl,tl,t_max))
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

# Define new Base.show method
function display_aux(node, label::String)
    # Determine whether node is a leaf: either not a BVHNode or
    # a BVHNode with node.same true or where left and right are identical.
    isleaf = !(node isa BVHNode) || (node isa BVHNode && (node.same || node.left === node.right))

    # For a leaf, always print “O”
    s_str = isleaf ? "O" : label
    u = length(s_str)

    # Base case: no children.
    if isleaf
        return ([s_str], u, 1, div(u,2))
    end

    # Recursively get the representation of the left and right subtrees.
    left_lines, n, p, x = display_aux(node.left, "A")
    right_lines, m, q, y = display_aux(node.right, "B")

    # Build the string for the current node.
    # first_line puts underscores connecting to the left and right parts.
    first_line = string(repeat(" ", x+1),
                        repeat("_", n - x - 1),
                        s_str,
                        repeat("_", y),
                        repeat(" ", m - y))
    # second_line draws the slashes that connect the root with the subtrees.
    second_line = string(repeat(" ", x),
                        "/",
                        repeat(" ", n - x - 1 + u + y),
                        "\\",
                        repeat(" ", m - y - 1))

    # If the two subtrees have different heights, pad the shorter one with blank lines.
    if p < q
        left_lines = vcat(left_lines, [repeat(" ", n) for i in 1:(q - p)])
        p = q
    elseif q < p
        right_lines = vcat(right_lines, [repeat(" ", m) for i in 1:(p - q)])
        q = p
    end

    # Combine the left and right subtrees line by line.
    zipped_lines = [ left_lines[i] * " " * right_lines[i] for i in 1:p ]
    return (vcat([first_line, second_line], zipped_lines), n + m + u, max(p,q) + 2, n + div(u,2))
end

function Base.show(io::Base.IO, node::BVHNode)
    #_show_tree(io, node, 0)
    lines, _, _, _ = display_aux(node, "T")
    for line in lines
        println(io, line)
    end
end
