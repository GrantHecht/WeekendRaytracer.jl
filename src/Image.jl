mutable struct Image{FT, IT, PT}
    # Image aspect ratio
    aspect_ratio::FT

    # Image width and height in pixels
    width::IT
    height::IT

    # Samples averaged together per pixel
    samples_per_pixel::IT

    # Max recursion depth (max number of ray bounces)
    max_depth::IT

    # Allocated array for pixels
    pix::PT
end

# Constructor
function Image(;aspect_ratio = 16.0 / 9.0, width = 400, samples_per_pixel = 100, max_depth = 50)
    FT      = typeof(aspect_ratio)
    height  = round(typeof(width),width / aspect_ratio)
    pix     = zeros(RGB{FT}, height, width)
    return Image(aspect_ratio, width, height, samples_per_pixel, max_depth, pix)
end

# Define FileIO.save
FileIO.save(filename, image::Image) = save(filename, image.pix)

# Define function to shoot image
function shoot!(
    image::Image, camera::Camera, world::AbstractHittable;
    threaded    = false,
    n           = Threads.nthreads(),
    split       = Consecutive(),
)
    if !threaded
        _shoot_sequential!(image, camera, world)
    else
        _shoot_multithreaded!(
            image, camera, world;
            n       = n,
            split   = split,
        )
    end
end

function get_pixel_color(image::Image{FT,IT,PT}, camera::Camera, world::AbstractHittable, row, col) where {FT,IT,PT}
    scale   = 1.0 / image.samples_per_pixel
    pr      = 0.0
    pg      = 0.0
    pb      = 0.0
    @inbounds for s in 1:image.samples_per_pixel
        # Compute u and v
        u = (col + rand()) / image.width
        v = (image.height - row + rand()) / image.height

        # Create ray
        r = get_ray(camera, u, v)

        # Update color
        pixel_color = ray_color(r, world, image.max_depth)

        pr += pixel_color.r
        pg += pixel_color.g
        pb += pixel_color.b
    end
    return RGB(FT(clamp(sqrt(pr*scale), 0.0, 1.0)),
               FT(clamp(sqrt(pg*scale), 0.0, 1.0)),
               FT(clamp(sqrt(pb*scale), 0.0, 1.0)))
end

function _shoot_sequential!(image::Image, camera::Camera, world::AbstractHittable)
    @inbounds for idx in eachindex(image.pix)
        # Compute row and column
        row = mod(idx - 1, image.height) + 1
        col = div(idx - 1, image.height) + 1

        # Set color by averading accumulated colors and correcting for gamma
        image.pix[idx] = get_pixel_color(image, camera, world, row, col)
    end
    return nothing
end

function _shoot_multithreaded!(image::Image, camera::Camera, world::AbstractHittable, start, stop)
    @inbounds for idx in start:stop
        # Compute row and column
        row = mod(idx - 1, image.height) + 1
        col = div(idx - 1, image.height) + 1

        # Set color by averaging accumulated colors and correcting for gamma
        image.pix[idx] = get_pixel_color(image, camera, world, row, col)
    end
    return nothing
end

function _shoot_multithreaded!(image::Image, camera::Camera, world::AbstractHittable, idxs)
    @inbounds for idx in idxs
        # Compute row and column
        row = mod(idx - 1, image.height) + 1
        col = div(idx - 1, image.height) + 1

        # Set color by averaging accumulated colors and correcting for gamma
        image.pix[idx] = get_pixel_color(image, camera, world, row, col)
    end
    return nothing
end

function _shoot_multithreaded!(
    image::Image, camera::Camera, world::AbstractHittable;
    n       = Threads.nthreads(),
    split   = Consecutive()
)
    tasks = map(chunks(eachindex(image.pix); n=n, split=split)) do idxs
        Threads.@spawn _shoot_multithreaded!(image, camera, world, idxs)
    end
    wait.(tasks)
    return nothing
end
