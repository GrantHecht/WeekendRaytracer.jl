
struct HittableList{T <: Tuple} <: HittableCollection
    spheres::T
end

# Define constructor
function HittableList(args...)
    # Check type of arguments and warn if they are not the same 
    # Will cause dynamic dispatch to occur when iterating through 
    # spheres (or other objects to come...)
    n = length(args)
    if n == 0
        throw(ArgumentError("HittableList requires at least one sphere."))
    else
        typea1 = typeof(args[1])
        warn   = false
        for i in 2:n
            if typeof(args[i]) != typea1
                warn = true
            end
        end
        warn && @warn("HittableList contains objects of different types. " *
                      "Dynamic dispatch will occur resulting in slow ray tracing.")
    end

    HittableList(args)
end

# Define bounding_box method
function bounding_box(hl::HittableList, time0, time1)
    out_box = AxisAlignedBoundingBox(
        SVector(0.0, 0.0, 0.0),
        SVector(0.0, 0.0, 0.0)
    )
    first_box = true
    for i in eachindex(hl.spheres)
        box = bounding_box(hl.spheres[i], time0, time1)
        out_box = first_box ? box : surrounding_box(out_box, box)
        first_box = false
    end
    return out_box
end

# Define ray_color method
function ray_color(ray::Ray, world::HittableList, depth)
    # If we've exceeded the ray bounce limit, no more light is gathered
    if depth <= 0
        return RGB(0.0, 0.0, 0.0)
    end

    # Find closest hit object
    hit_anything, idx = find_closest_hit_object(ray, world) 

    # Call ray_color on the closest hit object
    if !hit_anything
        invNdir  = 1.0 / norm(ray.dir)
        unit_dir = ray.dir * invNdir
        t        = 0.5*(unit_dir[2] + 1.0)
        tm       = 1.0 - t
        return RGB(tm + t*0.5, tm + t*0.7, tm + t)
    else
        flag, scattered, attenuation = scatter(ray, world.spheres[idx], 0.001, Inf)
        if flag
            new_color = ray_color(scattered, world, depth - 1)
            return RGB(attenuation.r * new_color.r,
                       attenuation.g * new_color.g,
                       attenuation.b * new_color.b)
        else
            return RGB(0.0, 0.0, 0.0)
        end
    end
end

function find_closest_hit_object(ray::Ray, world::HittableList)
    # Find closest hit object
    t_min           = 0.001
    t_max           = Inf
    hit_anything    = false
    closest_so_far  = t_max
    idx             = 1  
    t               = 0.0
    @inbounds for i in eachindex(world.spheres)
        flag, t = hit_time(ray, world.spheres[i], t_min, closest_so_far)
        if flag 
            hit_anything = true
            closest_so_far = t
            idx = i
        end
    end
    return hit_anything, idx
end

