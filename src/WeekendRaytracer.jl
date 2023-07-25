module WeekendRaytracer

# Image and camera
export Image, shoot!, save
export Camera

# Hittables
export Sphere, HittableList

# Materials
export Lambertian, Dielectric, Metal

# World generation
export WorldGeneration

using StaticArrays
using LinearAlgebra
using Images
using Reexport
using FileIO

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
include("Material.jl")

# The following are depreciated
#include("Material/AbstractMaterial.jl")
#include("Material/Lambertian.jl")
#include("Material/Dielectric.jl")
#include("Material/Metal.jl")

# Hittable (Objects that can be hit by a Ray)
include("Hittable/Hittable.jl")
include("Hittable/Sphere.jl")
include("Hittable/HittableList.jl")
include("Hittable/WorldGeneration.jl")

# Image
include("Image.jl")

end
