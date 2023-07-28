
struct BVHWorld{N <: BVHNode, C <: RGB} <: HittableWorld
    # Top node in Bounding Volume Hierarchy
    top_node::N
    # Background color
    background::C
end

# Define bounding box method
bounding_box(w::BVHWorld, time0, time1) = 
    bounding_box(w.top_node, time0, time1)

# Define ray color method
function ray_color(ray::Ray, w::BVHWorld, depth)
    # If we've exceeded the ray bounce limit, no more light to gather
    if depth <= 0
        return RGB(0.0, 0.0, 0.0)
    end

    # Call fire_ray
    hflag, sflag, t, scattered, attenuation = fire_ray(ray, w.top_node, 0.001, Inf)
    if !hflag
        return w.background
    end

    if sflag 
        new_color = ray_color(scattered, w, depth - 1)

        return RGB(attenuation.r * new_color.r,
                   attenuation.g * new_color.g,
                   attenuation.b * new_color.b)
    else
        return RGB(0.0, 0.0, 0.0)
    end
end