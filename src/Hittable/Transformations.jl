
# Pure translation
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

# Pure Rotation about Y
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

# General transformations (rotation and translation)
struct Transformation{O <: AbstractHittable, T} <: AbstractTransformation
    obj::O

    offset_in_world::SVector{3,T}
    R_object_to_world::SMatrix{3,3,T,9}

    function Transformation(
        obj::O, object_to_world::AbstractMatrix{T},
    ) where {O <: AbstractHittable, T}
        offset = SA[
            object_to_world[1,4],
            object_to_world[2,4],
            object_to_world[3,4],
        ]
        R = SA[
            object_to_world[1,1] object_to_world[1,2] object_to_world[1,3];
            object_to_world[2,1] object_to_world[2,2] object_to_world[2,3];
            object_to_world[3,1] object_to_world[3,2] object_to_world[3,3]
        ]
        new{O,T}(obj, offset, R)
    end
    function Transformation(
        obj::O, rot::AbstractMatrix{T}, offset::AbstractVector{T},
    ) where {O <: AbstractHittable, T}
        _offset = SVector{3,T}(offset)
        _rot = SMatrix{3,3,T,9}(rot)
        new{O,T}(obj, _offset, _rot)
    end
end

function bounding_box(t::Transformation, time0, time1)
    # Get rotation and transformation
    offset_in_world = t.offset_in_world
    rot_to_world = t.R_object_to_world

    # get the base objects bounding box
    box = bounding_box(t.obj, time0, time1)

    # update box for rotation
    xmin = Inf; ymin = Inf; zmin = Inf
    xmax = -Inf; ymax = -Inf; zmax = -Inf
    @inbounds for i in 0:1
        for j in 0:1
            for k in 0:1
                r_obj = SA[
                    i*box.max[1] + (1 - i)*box.min[1],
                    j*box.max[2] + (1 - j)*box.min[2],
                    k*box.max[3] + (1 - k)*box.min[3],
                ]
                r_wld = rot_to_world*r_obj

                xmin = min(xmin, r_wld[1])
                xmax = max(xmax, r_wld[1])
                ymin = min(ymin, r_wld[2])
                ymax = max(ymax, r_wld[2])
                zmin = min(zmin, r_wld[3])
                zmax = max(zmax, r_wld[3])
            end
        end
    end

    box = AxisAlignedBoundingBox(SA[xmin, ymin, zmin],SA[xmax, ymax, zmax])

    # offset the box
    box = box + offset_in_world

    return box
end

function fire_ray(ray_in::Ray, t::Transformation, t_min, t_max)
    # Get rotation and transformation
    offset_in_world = t.offset_in_world
    rot_to_world = t.R_object_to_world

    # Transform the ray into object space
    rot_to_obj = transpose(rot_to_world)
    ray_obj_orig = rot_to_obj*(ray_in.orig - offset_in_world)
    ray_obj_dir = rot_to_obj*ray_in.dir
    ray_obj = Ray(ray_obj_orig, ray_obj_dir, ray_in.tm)

    # Call fire_ray on the object with the offset ray
    hflag, sflag, t_hit, sray, attenuation, emitted  =
        fire_ray(ray_obj, t.obj, t_min, t_max)

    # Transform scattered ray back to world space
    sray_wld_orig = rot_to_world*sray.orig + offset_in_world
    sray_wld_dir = rot_to_world*sray.dir
    sray_wld = Ray(sray_wld_orig, sray_wld_dir, sray.tm)

    return hflag, sflag, t_hit, sray_wld, attenuation, emitted
end
