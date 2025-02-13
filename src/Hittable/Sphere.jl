
struct Sphere{T <: AbstractArray,
              U <: AbstractFloat,
              M <: AbstractMaterial} <: HittableObject
    center0 ::T
    center1 ::T
    time0   ::U
    time1   ::U
    radius  ::U
    mat     ::M
end

# Define constructor
Sphere(center::T, r::U, mat::M) where {T,U,M} = Sphere(center, center, U(0.0), U(0.0), r, mat)
Sphere(center0, center1, time0, time1, r, mat) = Sphere(center0, center1, time0, time1, r, mat)

# Define method to get center at time
function center(s::Sphere, t)
    if s.time0 == s.time1 || t == s.time0
        return s.center0
    elseif t == s.time1
        return s.center1
    end
    sf = (t - s.time0) / (s.time1 - s.time0)
    cd = SA[
        s.center1[1] - s.center0[1],
        s.center1[2] - s.center0[2],
        s.center1[3] - s.center0[3],
    ]
    return SA[
        s.center0[1] + sf*cd[1],
        s.center0[2] + sf*cd[2],
        s.center0[3] + sf*cd[3],
    ]
end

# Define bounding box method
function bounding_box(s::Sphere, time0, time1)
    if s.time0 == s.time1
        min = SA[
            s.center0[1] - s.radius,
            s.center0[2] - s.radius,
            s.center0[3] - s.radius,
        ]
        max = SA[
            s.center0[1] + s.radius,
            s.center0[2] + s.radius,
            s.center0[3] + s.radius,
        ]
        return AxisAlignedBoundingBox(min,max)
    end
    b0 = AxisAlignedBoundingBox(
        SA[
            s.center0[1] - s.radius,
            s.center0[2] - s.radius,
            s.center0[3] - s.radius,
        ],
        SA[
            s.center0[1] + s.radius,
            s.center0[2] + s.radius,
            s.center0[3] + s.radius,
        ]
    )
    b1 = AxisAlignedBoundingBox(
        SA[
            s.center1[1] - s.radius,
            s.center1[2] - s.radius,
            s.center1[3] - s.radius,
        ],
        SA[
            s.center1[1] + s.radius,
            s.center1[2] + s.radius,
            s.center1[3] + s.radius,
        ]
    )
    return surrounding_box(b0, b1)
end

# Define hit methods
function hit(ray::Ray, s::Sphere, t_min, t_max)
    # Compute vector pointing from center of sphere to ray origin
    cn = center(s, time(ray))
    oc = SA[ray.orig[1] - cn[1], ray.orig[2] - cn[2], ray.orig[3] - cn[3]]

    # Compute a
    a   = dot(ray.dir, ray.dir)

    # Compute b / 2
    hb  = dot(oc, ray.dir)

    # Compute c
    c   = dot(oc, oc) - s.radius*s.radius

    # Compute discriminant
    d   = hb*hb - a*c

    # Return t for first contact with sphere
    if d < 0
        rec = HitRecord(SA[0.0,0.0,0.0], SA[0.0,0.0,0.0], -1.0, 0.0, 0.0, s.mat, true)
        return false, rec
    else
        sqrtd = sqrt(d)

        # Find the nearest root that lies in the acceptable range
        root = (-hb - sqrtd) / a
        if (root < t_min || t_max < root)
            rec = HitRecord(SA[0.0,0.0,0.0], SA[0.0,0.0,0.0], -1.0, 0.0, 0.0, s.mat, true)
            return false, rec
        end

        # Compute HitRecord
        ir          = 1.0 / s.radius
        t           = root
        p           = at(ray, t)
        on          = SA[ir*(p[1] - cn[1]), ir*(p[2] - cn[2]), ir*(p[3] - cn[3])]
        front_face  = dot(ray.dir, on) < 0
        normal      = front_face ? on : -on
        u, v        = get_uv(s, on)
        rec         = HitRecord(p, normal, t, u, v, s.mat, front_face)

        return true, rec
    end
end

# Define method to get texture coordinates
function get_uv(s::Sphere, p)
    theta = acos(-p[2])
    phi   = atan(-p[3], p[1]) + pi
    πInv  = 1.0 / π
    u     = 0.5*πInv*phi
    v     = πInv*theta
    return u, v
end

# Define fire_ray methods
function fire_ray(ray_in::Ray, s::Sphere, t_min, t_max)
    hflag, rec  = hit(ray_in, s, t_min, t_max)
    t_hit       = rec.t
    sflag, scattered, attenuation = scatter(ray_in, rec)
    emitted     = emit(rec)
    return hflag, sflag, t_hit, scattered, attenuation, emitted
end

# Define ray_color method
function ray_color(ray::Ray, world::Sphere, depth)
    # If we've exceeded the ray bounce limit, no more light is gathered
    if depth <= 0
        return RGB(0.0, 0.0, 0.0)
    end

    # Call ray_color on the closest hit object
    flag, rec = hit(ray, world, 0.001, Inf)
    if !flag
        invNdir  = 1.0 / norm(ray.dir)
        unit_dir = ray.dir * invNdir
        t        = 0.5*(unit_dir[2] + 1.0)
        return (1.0 - t)*RGB(1.0, 1.0, 1.0) + t*RGB(0.5, 0.7, 1.0)
    else
        flag, scattered, attenuation = scatter(ray, world, 0.001, Inf)
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
