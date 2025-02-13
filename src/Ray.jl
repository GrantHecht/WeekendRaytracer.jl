
# Define Ray struct
struct Ray{T <: AbstractArray, U <: AbstractFloat}
    orig    ::T
    dir     ::T
    tm      ::U
end

# Define function to get time
time(ray::Ray) = ray.tm

# Define fuction for computing location of ray
function at(ray::Ray{T}, t) where T
    Tt = eltype(T)
    return ray.orig + Tt(t)*ray.dir
end
