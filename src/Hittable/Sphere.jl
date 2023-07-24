
struct Sphere{T <: AbstractArray, 
              U <: AbstractFloat, 
              M <: AbstractMaterial} <: HittableObject
    center  ::T 
    radius  ::U
    mat     ::M
end

# Define constructor
Sphere(center, r, mat) = Sphere(center, r, mat)

# Define hit methods
function hit(ray::Ray, s::Sphere, t_min, t_max)
    # Compute vector pointing from center of sphere to ray origin
    oc = SVector(ray.orig[1] - s.center[1],
                 ray.orig[2] - s.center[2],
                 ray.orig[3] - s.center[3])

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
        rec = HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, s.mat, true)
        return false, rec
    else
        sqrtd = sqrt(d)

        # Find the nearest root that lies in the acceptable range
        root = (-hb - sqrtd) / a
        if (root < t_min || t_max < root)
            rec = HitRecord(SVector(0.0,0.0,0.0), SVector(0.0,0.0,0.0), -1.0, s.mat, true)
            return false, rec
        end

        # Compute HitRecord
        ir          = 1.0 / s.radius
        t           = root
        p           = at(ray, t)
        on          = SVector(ir*(p[1] - s.center[1]),
                              ir*(p[2] - s.center[2]),
                              ir*(p[3] - s.center[3]))
        front_face  = dot(ray.dir, on) < 0
        normal      = front_face ? on : -on
        rec         = HitRecord(p, normal, t, s.mat, front_face)

        return true, rec
    end
end

# Define scatter method
function scatter(ray_in::Ray, s::Sphere, t_min, t_max)
    hflag, rec = hit(ray_in, s, t_min, t_max)
    sflag, scattered, attenuation = scatter(ray_in, rec)
    flag  = hflag ? sflag : false
    return flag, scattered, attenuation
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