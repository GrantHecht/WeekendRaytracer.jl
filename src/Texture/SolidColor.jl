
struct SolidColor{T} <: AbstractTexture
    color_value::T

    function SolidColor(color::T) where T
        new{T}(color)
    end
    function SolidColor(r::T, g::T, b::T) where T
        new{RGB{T}}(RGB{T}(r, g, b))
    end
end

function value(t::SolidColor, u, v, p)
    return t.color_value
end