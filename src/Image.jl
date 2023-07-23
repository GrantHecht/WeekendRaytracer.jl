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
    height  = Int(width / aspect_ratio)
    pix     = zeros(RGB, height, width)
    return Image(aspect_ratio, width, height, samples_per_pixel, max_depth, file, pix)
end

# Define function to shoot image
function shoot!(image::Image, camera::Camera, world::AbstractHittable; threaded = false)
    if !threaded
        _shoot_sequential(image, camera, world)
    else
        _shoot_multithreaded(image, camera, world)
    end
end

function _shoot_sequential(image::Image, camera::Camera, world::AbstractHittable)
    scale = 1.0 / image.samples_per_pixel 
    for i in 1:image.width
        for j in 1:image.height
            pr = 0.0
            pg = 0.0
            pb = 0.0
            for s in 1:image.samples_per_pixel
                # Compute u and v
                u = (i + rand()) / image.width
                v = (image.height - j + rand()) / image.height

                # Create ray
                r = get_ray(camera, u, v)

                # Set color
                pixel_color = ray_color(r, world, image.max_depth)
                pr += pixel_color.r
                pg += pixel_color.g
                pb += pixel_color.b
            end
            new_color = RGB(clamp(sqrt(pr*scale), 0.0, 0.999),
                            clamp(sqrt(pg*scale), 0.0, 0.999),
                            clamp(sqrt(pb*scale), 0.0, 0.999))
            image.pix[j, i] = new_color
        end
    end
    save(image.file, image.pix)
    return nothing
end

function _shoot_multithreaded(image::Image, camera::Camera, world::AbstractHittable)
    scale = 1.0 / image.samples_per_pixel 
    #@floop for idx in eachindex(image.pix)
    Threads.@threads for idx in eachindex(image.pix)
        row = mod(idx - 1, image.height) + 1
        col = div(idx - 1, image.height) + 1

        pr = 0.0
        pg = 0.0
        pb = 0.0
        for s in 1:image.samples_per_pixel
            # Compute u and v (coordinates of point to shoot ray)
            u = (col + rand()) / image.width
            v = (image.height - row + rand()) / image.height

            # Create ray shooting from camera origin to point (v,u)
            r = get_ray(camera, u, v)

            # Set color by shooting ray at world with max depth reflections
            pixel_color = ray_color(r, world, image.max_depth)

            # Accumulate colors
            pr += pixel_color.r
            pg += pixel_color.g
            pb += pixel_color.b
        end
        # Set color by averaging accumulated colors and correcting for gamma
        new_color = RGB(clamp(sqrt(pr*scale), 0.0, 0.999),
                        clamp(sqrt(pg*scale), 0.0, 0.999),
                        clamp(sqrt(pb*scale), 0.0, 0.999))
        image.pix[idx] = new_color
    end
    save(image.file, image.pix)
    return nothing
end