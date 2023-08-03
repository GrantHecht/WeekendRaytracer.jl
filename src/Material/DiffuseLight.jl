
# Define DiffuseLight struct
struct DiffuseLight{T <: AbstractTexture} <: AbstractMaterial
    emit::T

    # Define constructor
    DiffuseLight(emit_r::T, emit_g::T, emit_b::T) where {T <: AbstractFloat} = 
        new{SolidColor{RGB{T}}}(SolidColor(RGB{T}(emit_r, emit_g, emit_b)))
    DiffuseLight(emit::AbstractArray{T}) where {T <: AbstractFloat} = 
        new{SolidColor{RGB{T}}}(SolidColor(RGB{T}(emit[1], emit[2], emit[3])))
    DiffuseLight(emit::RGB{T}) where {T <: AbstractFloat} = 
        new{SolidColor{RGB{T}}}(SolidColor(emit))
    DiffuseLight(emit::T) where {T <: AbstractTexture} = 
        new{T}(emit)
end

# Define scatter
scatter(ray_in::Ray, rec::HitRecord{T,U,M}) where {T,U,M <: DiffuseLight} =
    (false, Ray(ray_in.orig, ray_in.dir, time(ray_in)), RGB(0.0,0.0,0.0))

# Define emit
emit(rec::HitRecord{T,U,M}) where {T,U,M <: DiffuseLight} = 
    value(rec.mat.emit, rec.u, rec.v, rec.p)