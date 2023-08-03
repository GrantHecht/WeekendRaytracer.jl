# Define enum for included textures
@enum DefaultTexture begin
    earth = 1
end

# Define constant global variable for path to textures
const TEXTURE_PATH = joinpath(@__DIR__, "..", "..", "textures")

# Define global dictionary for mapping DefaultTexture to filename
const DEFAULT_TEXTURE = Dict(
    earth => joinpath(TEXTURE_PATH, "8081_earthmap4k.jpg")
)

# Define value function
value(t::AbstractTexture, u, v, p) = error("Method not implemented.")