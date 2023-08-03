
# Define abstract types used in WeekendRaytracer
# Defining these here to avoid circular dependencies
abstract type AbstractMaterial end
abstract type AbstractTexture end

abstract type AbstractHittable end
abstract type HittableObject <: AbstractHittable end
abstract type HittableRectangle <: HittableObject end
abstract type BoundingBox <: AbstractHittable end
abstract type HittableCollection <: AbstractHittable end
abstract type HittableWorld <: AbstractHittable end