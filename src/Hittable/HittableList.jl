
mutable struct HittableList{T <: Tuple} <: HittableCollection
    objects::T
end

# Define constructor
HittableList(args...) = HittableList(args)

# Define ray_color method
function ray_color(ray::Ray, world::HittableList, depth)
    # If we've exceeded the ray bounce limit, no more light is gathered
    if depth <= 0
        return RGB(0.0, 0.0, 0.0)
    end

    # Find closest hit object
    t_min           = 0.001
    t_max           = Inf
    hit_anything    = false
    closest_so_far  = t_max
    idx             = 1  
    for i in eachindex(world.objects)
        flag, t = hit_time(ray, world.objects[i], t_min, closest_so_far)
        if flag 
            hit_anything = true
            closest_so_far = t
            idx = i
        end
    end

    # Call ray_color on the closest hit object
    if !hit_anything
        invNdir  = 1.0 / norm(ray.dir)
        unit_dir = ray.dir * invNdir
        t        = 0.5*(unit_dir[2] + 1.0)
        return (1.0 - t)*RGB(1.0, 1.0, 1.0) + t*RGB(0.5, 0.7, 1.0)
    else
        flag, scattered, attenuation = scatter(ray, world.objects[idx], 0.001, Inf)
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
