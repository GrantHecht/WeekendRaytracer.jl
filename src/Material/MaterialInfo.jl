# Define enumeration for material type
@enum MaterialType begin
    lambertian = 1
    metal = 2
    dielectric = 3
    miss = 4
end

struct MaterialInfo <: AbstractMaterial
    # The material type
    type::MaterialType

    # Albedo
    albedo::RGB{Float64}

    # Index of refraction
    ir::Float64

    # Fuzzy reflection ratio
    fuzz::Float64
end

function MaterialInfo()
    return MaterialInfo(miss, RGB(0.0, 0.0, 0.0), 0.0, 0.0)
end
function MaterialInfo(m::M, u, v) where {M <: Lambertian}
    return MaterialInfo(lambertian, value(m.albedo, u, v, p), 0.0, 0.0)
end
function MaterialInfo(m::M, u, v, p) where {M <: Metal}
    return MaterialInfo(metal, m.albedo, 0.0, m.fuzz)
end
function MaterialInfo(m::M, u, v, p) where {M <: Dielectric}
    return MaterialInfo(dielectric, RGB(1.0, 1.0, 1.0), m.ir, 0.0)
end