
# Define hit methods for Hittable (should never actually be called)
hit(ray::Ray, h::HittableObject, t_min, t_max)      = error("Method not implemented")
hit(ray::Ray, h::HittableCollection, t_min, t_max)  = error("Hit should not be called on a hittable collection!")
hit(ray::Ray, h::HittableWorld, t_min, t_max)       = error("Hit should not be called on a hittable world!")
hit(ray::Ray, h::BoundingBox, t_min, t_max)         = error("Method not implemented")

# Defind bounding_box method for Hittable
bounding_box(h::HittableObject, time0, time1)       = error("Method not implemented")
bounding_box(h::HittableCollection, time0, time1)   = error("Method not implemented")
bounding_box(h::HittableWorld, time0, time1)        = error("Method not implemented")

# Depreciated
# Define hit_time methods for Hittable
# function hit_time(ray::Ray, h::HittableObject, t_min, t_max)
#     flag, rec = hit(ray, h, t_min, t_max)
#     return flag, rec.t
# end
# hit_time(ray::Ray, h::HittableCollection, t_min, t_max) = error("Method not implemented")

# Define scatter methods for Hittable
scatter(ray_in::Ray, h::HittableObject, t_min, t_max) = error("Method not implemented")
scatter(ray_in::Ray, h::HittableCollection, t_min, t_max) = error("scatter should never be called on a hittable collection! Check your code!")
scatter(ray_in::Ray, h::HittableWorld, t_min, t_max) = error("scatter should never be called on a hittable world! Check your code!")

# Define ray_color method for Hittable
ray_color(ray::Ray, world::HittableWorld, depth) = error("Method not implemented")
ray_color(ray::Ray, world::AbstractHittable, depth) = error("ray_color should never be called on objects that are not a HittableWorld! Check your code!")

# Define fire ray
function fire_ray(ray_in::Ray, obj::O, t_min, t_max) where {O <: HittableObject}
    hflag, rec = hit(ray_in, obj, t_min, t_max)
    t_hit = rec.t
    sflag, scattered, attenuation = scatter(ray_in, rec)
    emitted = emit(rec)
    return hflag, sflag, t_hit, scattered, attenuation, emitted
end

# Define box comparison function
function box_compare(a::AbstractHittable, b::AbstractHittable, axis, time0, time1)
    box_a = bounding_box(a, time0, time1)
    box_b = bounding_box(b, time0, time1)
    return box_a.min[axis] < box_b.min[axis]
end
