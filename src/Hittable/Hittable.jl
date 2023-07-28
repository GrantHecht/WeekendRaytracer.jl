
# Define hit methods for Hittable (should never actually be called)
hit(ray::Ray, h::HittableObject, t_min, t_max) = error("Method not implemented")
hit(ray::Ray, h::HittableCollection, t_min, t_max) = error("Hit should not be called on a hittable collection!")

# Defind bounding_box method for Hittable
bounding_box(h::HittableObject, time0, time1) = error("Method not implemented")
bounding_box(h::HittableCollection, time0, time1) = error("bounding_box should never be called on a hittable collection! Check your code!")

# Define hit_time methods for Hittable (could never actually be called)
function hit_time(ray::Ray, h::HittableObject, t_min, t_max)
    flag, rec = hit(ray, h, t_min, t_max)
    return flag, rec.t
end
hit_time(ray::Ray, h::HittableCollection, t_min, t_max) = error("Method not implemented")

# Define scatter methods for Hittable
scatter(ray_in::Ray, h::HittableObject, t_min, t_max) = error("Method not implemented")
scatter(ray_in::Ray, h::HittableCollection, t_min, t_max) = error("scatter should never be called on a hittable collection! Check your code!")

# Define ray_color method for Hittable
ray_color(ray::Ray, world::AbstractHittable, depth) = error("Method not implemented")

# Define box comparison function
function box_compare(a::HittableObject, b::HittableObject, axis, time0, time1)
    box_a = bounding_box(a, time0, time1)
    box_b = bounding_box(b, time0, time1)
    return box_a.min[axis] < box_b.min[axis]
end
