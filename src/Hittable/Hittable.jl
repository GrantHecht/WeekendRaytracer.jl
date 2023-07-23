
# Define hit methods for Hittable (should never actually be called)
hit(ray::Ray, h::HittableObject, t_min, t_max) = error("Method not implemented")
hit(ray::Ray, h::HittableCollection, t_min, t_max) = error("hit should never be called on a hittable collection! Check your code!")

# Define hit_time methods for Hittable (could never actually be called)
function hit_time(ray::Ray, h::HittableObject, t_min, t_max)
    flag, rec = hit(ray, h, t_min, t_max)
    return flag, rec.t
end
hit_time(ray::Ray, h::HittableCollection, t_min, t_max) = error("hit_time should never be called on a hittable collection! Check your code!")

# Define scatter methods for Hittable
scatter(ray_in::Ray, h::HittableObject, t_min, t_max) = error("Method not implemented")
scatter(ray_in::Ray, h::HittableCollection, t_min, t_max) = error("scatter should never be called on a hittable collection! Check your code!")

# Define ray_color method for Hittable
ray_color(ray::Ray, world::AbstractHittable, depth) = error("Method not implemented")
