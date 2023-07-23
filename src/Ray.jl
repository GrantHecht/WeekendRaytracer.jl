
# Define Ray struct
struct Ray{T <: AbstractArray}
    orig    ::T
    dir     ::T
end

# Define fuction for computing location of ray
at(ray::Ray, t) = ray.orig + t*ray.dir