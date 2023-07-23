
# Define abstract types used in WeekendRaytracer
# Defining these here to avoid circular dependencies
abstract type AbstractMaterial end

abstract type AbstractHittable end
abstract type HittableObject <: AbstractHittable end
abstract type HittableCollection <: AbstractHittable end