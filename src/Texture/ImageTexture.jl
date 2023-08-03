
struct ImageTexture{T} <: AbstractTexture
    data                ::T
    width               ::Int
    height              ::Int
end

# Constructors
function ImageTexture(filename)
    # Load image file
    data = load(filename)

    # get width and height
    width  = size(data, 1)
    height = size(data, 2)

    # Return
    return ImageTexture(data, width, height)
end

function ImageTexture(texture::DefaultTexture)
    # Get filename
    filename = DEFAULT_TEXTURE[texture]

    # Load image file
    data = load(filename)

    # get width and height
    width  = size(data, 2)
    height = size(data, 1)

    # Return
    return ImageTexture(data, width, height)
end

# value function
function value(t::ImageTexture, u, v, p)
    # Clamp input texture poordinates to [0,1] x [1,0]
    u = clamp(u, 0.0, 1.0)
    v = 1.0 - clamp(v, 0.0, 1.0) # Flip V to image coordinates

    i = round(Int, u * t.width)
    j = round(Int, v * t.height)

    # Clamp integer mapping, since actual coordinates should be less than 1.0
    if i >= t.width;  i = t.width - 1;  end
    if j >= t.height; j = t.height - 1; end

    # Get pixel and return
    pixel = t.data[j + 1, i + 1]
    return pixel
end