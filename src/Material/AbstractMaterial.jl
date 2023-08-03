
# Define scatter function for abstract type Material
# Should return a boolean indicating if the ray was scattered,
# the scattered ray (Ray), and the attenuation (RGB)
scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: AbstractMaterial} = error("Method not implemented")

# Define emitted function for abstract type Material
# Should return zero RGB
emit(rec::HitRecord{T,U,M}) where {T,U,M <: AbstractMaterial} = RGB(0.0,0.0,0.0)