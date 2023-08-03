
# Define Box struct
struct Box{T,N <: BVHNode} <: HittableCollection
    box_min ::T
    box_max ::T
    sides   ::N
end

# Constructor
function Box(p0, p1, mat)
    box_min = p0
    box_max = p1
    sides   = BVHNode(0.0, 0.0, [
        XYRectangle(p0.x, p1.x, p0.y, p1.y, p1.z, mat),
        XYRectangle(p0.x, p1.x, p0.y, p1.y, p0.z, mat),
        XZRectangle(p0.x, p1.x, p0.z, p1.z, p1.y, mat),
        XZRectangle(p0.x, p1.x, p0.z, p1.z, p0.y, mat),
        YZRectangle(p0.y, p1.y, p0.z, p1.z, p1.x, mat),
        YZRectangle(p0.y, p1.y, p0.z, p1.z, p0.x, mat)
    ])
    return Box(box_min, box_max, sides)
end

# Define bounding box
bounding_box(b::Box, time0, time1) = 
    bounding_box(b.sides, time0, time1)

# Define fire_ray
fire_ray(ray_in::Ray, b::Box, t_min, t_max) = 
    fire_ray(ray_in, b.sides, t_min, t_max)