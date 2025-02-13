
struct Translate{O <: AbstractHittable, T} <: AbstractTranslation
    obj::O
    offset::T
end

function fire_ray(ray_in::Ray, t::Translate, t_min, t_max)
    # Move the ray backwards by the offset
    ray_offset  = Ray(
        SA[
            ray_in.orig[1] - t.offset[1],
            ray_in.orig[2] - t.offset[2],
            ray_in.orig[3] - t.offset[3],
        ],
        ray_in.dir, ray_in.tm,
    )

    # Call fire_ray on the object with the offset ray
    hflag, sflag, t_hit, scattered, attenuation, emitted  =
        fire_ray(ray_offset, t.obj, t_min, t_max)

    # Shift origin of scattered ray towards the offset
    scattered_offset = Ray(
        SA[
            scattered.orig[1] + t.offset[1],
            scattered.orig[2] + t.offset[2],
            scattered.orig[3] + t.offset[3],
        ],
        scattered.dir, scattered.tm,
    )

    return hflag, sflag, t_hit, scattered_offset, attenuation, emitted
end

function bounding_box(t::Translate, time0, time1)
    # Get the objects bounding box
    box = bounding_box(t.obj, time0, time1)

    # Offset the box
    box_offset = box + t.offset
    return box_offset
end
