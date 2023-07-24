
struct HittableList{T <: Tuple} <: HittableCollection
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
    hit_anything, idx = find_closest_hit_object(ray, world) 

    # Call ray_color on the closest hit object
    if !hit_anything
        invNdir  = 1.0 / norm(ray.dir)
        unit_dir = ray.dir * invNdir
        t        = 0.5*(unit_dir[2] + 1.0)
        tm       = 1.0 - t
        return RGB(tm + t*0.5, tm + t*0.7, tm + t)
    else
        # NOTE: Indexing into world.objects[idx] is allocating
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

function find_closest_hit_object(ray::Ray, world::HittableList)
    # Find closest hit object
    t_min           = 0.001
    t_max           = Inf
    hit_anything    = false
    closest_so_far  = t_max
    idx             = 1  
    t               = 0.0
    @inbounds for i in eachindex(world.objects)
        # NOTE: Indexing into world.objects[i] is allocating
        flag, t = hit_time(ray, world.objects[i], t_min, closest_so_far)
        if flag 
            hit_anything = true
            closest_so_far = t
            idx = i
        end
    end
    return hit_anything, idx
end

macro find_closest_hit(ray::Ray, world::HittableList)
end