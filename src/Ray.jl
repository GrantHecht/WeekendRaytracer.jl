
# Define Ray struct
struct Ray{T <: AbstractArray, U <: AbstractFloat}
    orig    ::T
    dir     ::T
    tm      ::U
end

# Define function to get time
time(ray::Ray) = ray.tm

# Define fuction for computing location of ray
at(ray::Ray, t) = ray.orig + t*ray.dir