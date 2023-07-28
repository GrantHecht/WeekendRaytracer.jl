module WeekendRaytracer

# Image and camera
export Image, shoot!, save
export Camera

# Hittables
export Sphere, HittableList, BVHNode

# Materials
export Lambertian, Dielectric, Metal

# World generation
export random_scene

using StaticArrays
using LinearAlgebra
using Images
using Reexport
using FileIO
import Base.min, Base.show

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
# Depreciated
#include("Material/MaterialInfo.jl")
#include("Material.jl")

# Texture
include("Texture/Texture.jl")
include("Texture/SolidColor.jl")
include("Texture/CheckerTexture.jl")

# Hittable (Objects that can be hit by a Ray)
include("Hittable/Hittable.jl")
include("Hittable/AxisAlignedBoundingBox.jl")
include("Hittable/Sphere.jl")
include("Hittable/HittableList.jl")
include("Hittable/BVHNode.jl")
include("Hittable/BVHWorld.jl")
include("Hittable/WorldGeneration.jl")

# Image
include("Image.jl")

end
