
struct CheckerTexture{TO <: AbstractTexture, TE <: AbstractTexture} <: AbstractTexture
    odd     ::TO
    even    ::TE
    function CheckerTexture(odd::TO, even::TE) where {TO <: AbstractTexture, TE <: AbstractTexture}
        new{TO,TE}(odd, even)
    end
    function CheckerTexture(color1::RGB{T}, color2::RGB{T}) where {T} 
        new{SolidColor{RGB{T}},SolidColor{RGB{T}}}(SolidColor(color1), SolidColor(color2))
    end
end

function value(t::CheckerTexture, u, v, p)
    sines = sin(10*p[1])*sin(10*p[2])*sin(10*p[3])
    if sines < 0
        return value(t.odd, u, v, p)
    else
        return value(t.even, u, v, p)
    end
end