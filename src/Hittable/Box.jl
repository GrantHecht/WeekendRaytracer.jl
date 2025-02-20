
# Define Box struct
struct Box{T,N <: BVHNode, M <: AbstractMaterial} <: HittableObject
    box_min ::T
    box_max ::T
    sides   ::N
    mat     ::M
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
    ], SAH())
    return Box(box_min, box_max, sides, mat)
end

# Define bounding box
bounding_box(b::Box, time0, time1) =
    bounding_box(b.sides, time0, time1)

# Define fire_ray
fire_ray(ray_in::Ray, b::Box, t_min, t_max) =
    fire_ray(ray_in, b.sides, t_min, t_max)

# Define hit and unsafe hit functions
hit(ray_in::Ray, b::Box, t_min, t_max) = unsafe_hit(ray_in, b.sides, b.mat, t_min, t_max)
function unsafe_hit(ray_in::Ray, b::Box{T,N,M}, mat::M, t_min, t_max) where {T, N, M}
    return unsafe_hit(ray_in, b.sides, b.mat, t_min, t_max)
end
