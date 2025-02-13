
struct RotateY{O <: AbstractHittable, T} <: AbstractRotation
    obj::O
    sin_theta::T
    cos_theta::T

    function RotateY(obj::O, theta::T) where {O <: AbstractHittable, T}
        radians = deg2rad(theta)
        sin_theta = sin(radians)
        cos_theta = cos(radians)
        return new{O, T}(obj, sin_theta, cos_theta)
    end
end

function fire_ray(ray_in::Ray, ry::RotateY, t_min, t_max)
    # Transform the ray from world space to object space
    ray_obj_orig = SA[
        ry.cos_theta*ray_in.orig[1] - ry.sin_theta*ray_in.orig[3],
        ray_in.orig[2],
        ry.sin_theta*ray_in.orig[1] + ry.cos_theta*ray_in.orig[3],
    ]
    ray_obj_dir = SA[
        ry.cos_theta*ray_in.dir[1] - ry.sin_theta*ray_in.dir[3],
        ray_in.dir[2],
        ry.sin_theta*ray_in.dir[1] + ry.cos_theta*ray_in.dir[3],
    ]
    ray_obj = Ray(ray_obj_orig, ray_obj_dir, ray_in.tm)

    # Call fire_ray on the object with the offset ray
    hflag, sflag, t_hit, sray, attenuation, emitted  =
        fire_ray(ray_obj, ry.obj, t_min, t_max)

    # Transform the scattered ray from object space to world space
    sray_wrd_orig = SA[
        ry.cos_theta*sray.orig[1] + ry.sin_theta*sray.orig[3],
        sray.orig[2],
        -ry.sin_theta*sray.orig[1] + ry.cos_theta*sray.orig[3],
    ]
    sray_wrd_dir = SA[
        ry.cos_theta*sray.dir[1] + ry.sin_theta*sray.dir[3],
        sray.dir[2],
        -ry.sin_theta*sray.dir[1] + ry.cos_theta*sray.dir[3],
    ]
    sray_wrd = Ray(sray_wrd_orig, sray_wrd_dir, sray.tm)

    return hflag, sflag, t_hit, sray_wrd, attenuation, emitted
end

function bounding_box(ry::RotateY, time0, time1)
    # Get the objects bounding box
    box = bounding_box(ry.obj, time0, time1)

    # Initialize min and max values
    xmin = Inf; ymin = Inf; zmin = Inf
    xmax = -Inf; ymax = -Inf; zmax = -Inf
    @inbounds for i in 0:1
        for j in 0:1
            for k in 0:1
                x = i*box.max[1] + (1 - i)*box.min[1]
                y = j*box.max[2] + (1 - j)*box.min[2]
                z = k*box.max[3] + (1 - k)*box.min[3]

                nx = ry.cos_theta*x + ry.sin_theta*z
                nz = -ry.sin_theta*x + ry.cos_theta*z

                xmin = min(xmin, nx)
                xmax = max(xmax, nx)
                ymin = min(ymin, y)
                ymax = max(ymax, y)
                zmin = min(zmin, nz)
                zmax = max(zmax, nz)
            end
        end
    end

    return AxisAlignedBoundingBox(
        SA[xmin, ymin, zmin],
        SA[xmax, ymax, zmax],
    )
end
