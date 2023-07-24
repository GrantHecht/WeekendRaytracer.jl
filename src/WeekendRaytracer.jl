module WeekendRaytracer

export Ray, at
export Image, shoot!
export Camera, get_ray

# Hittables
export Sphere, HittableList

# Materials
export Lambertian, Dielectric, Metal

using StaticArrays
using LinearAlgebra
using Images
using FileIO
using FLoops

# Inalude abstract types to avoid circular dependencies
include("AbstractTypes.jl")

# Include Ray
include("Ray.jl")

# Include utilities
include("utils.jl")

# Camera object
include("Camera.jl")

# Include HitRecord
include("HitRecord.jl")

# Material
include("Material/AbstractMaterial.jl")
include("Material/Lambertian.jl")
include("Material/Dielectric.jl")
include("Material/Metal.jl")

# Hittable (Objects that can be hit by a Ray)
include("Hittable/Hittable.jl")
include("Hittable/Sphere.jl")
include("Hittable/HittableList.jl")

# Image
include("Image.jl")

end