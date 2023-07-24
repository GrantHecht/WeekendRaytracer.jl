struct Image{FT, IT, PT}
    aspect_ratio::FT
    width::IT
    height::IT
    samples_per_pixel::IT
    max_depth::IT
    file::String
    pix::PT
end

# Constructor
function Image(file;aspect_ratio = 16.0 / 9.0, width = 400, samples_per_pixel = 100, max_depth = 50)
    height  = round(typeof(width),width / aspect_ratio)
    pix     = zeros(RGB, height, width)
    return Image(aspect_ratio, width, height, samples_per_pixel, max_depth, file, pix)
end

# Define function to shoot image
function shoot!(image::Image, camera::Camera, world::AbstractHittable; threaded = false)
    if !threaded
        _shoot_sequential!(image, camera, world)
    else
        _shoot_multithreaded!(image, camera, world)
    end
end

function get_pixel_color(image::Image, camera::Camera, world::AbstractHittable, row, col)
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
    return RGB(clamp(sqrt(pr*scale), 0.0, 1.0),
               clamp(sqrt(pg*scale), 0.0, 1.0),
               clamp(sqrt(pb*scale), 0.0, 1.0))
end

function _shoot_sequential!(image::Image, camera::Camera, world::AbstractHittable)
    @inbounds for col in 1:image.width
        for row in 1:image.height
            color = get_pixel_color(image, camera, world, row, col) 
            image.pix[row, col] = color
        end
    end
    return nothing
end

function _shoot_multithreaded!(image::Image, camera::Camera, world::AbstractHittable)
    @inbounds Threads.@threads for idx in eachindex(image.pix)
        # Compute row and column
        row = mod(idx - 1, image.height) + 1
        col = div(idx - 1, image.height) + 1

        # Set color by averaging accumulated colors and correcting for gamma
        color = get_pixel_color(image, camera, world, row, col)
        image.pix[idx] = color
    end
    return nothing
end