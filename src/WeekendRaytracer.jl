module WeekendRaytracer

# Image and camera
export Image, shoot!, save
export Camera

# Hittables
export Sphere, HittableList
export BVHNode, MedianSplit, SAH

# Materials
export Lambertian, Dielectric, Metal

# Textures
export SolidTexture, CheckerTexture, NoiseTexture, ImageTexture

# World generation
export random_scene, two_spheres, two_perlin_spheres, quads
export not_so_pale_blue_dot, simple_light, cornel_box, cornel_smoke
export final_scene

using ChunkSplitters
using StaticArrays
using LinearAlgebra
using Images
using Match
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

# Texture
include("Texture/Texture.jl")
include("Texture/SolidColor.jl")
include("Texture/CheckerTexture.jl")
include("Texture/NoiseTexture.jl")
include("Texture/ImageTexture.jl")

# Material
include("Material/AbstractMaterial.jl")
include("Material/Lambertian.jl")
include("Material/Dielectric.jl")
include("Material/Metal.jl")
include("Material/Isotropic.jl")
include("Material/DiffuseLight.jl")

# Hittable (Objects that can be hit by a Ray)
include("Hittable/Hittable.jl")
include("Hittable/AxisAlignedBoundingBox.jl")
include("Hittable/Sphere.jl")
include("Hittable/Rectangle.jl")
include("Hittable/Quadrilateral.jl")
include("Hittable/BVHNode.jl")
include("Hittable/Box.jl")
include("Hittable/ConstantMedium.jl")
include("Hittable/Transformations.jl")
include("Hittable/BVHWorld.jl")
include("Hittable/WorldGeneration.jl")

# Image
include("Image.jl")

end
