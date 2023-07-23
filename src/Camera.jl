
struct Camera{T <: AbstractArray}
    origin              ::T
    lower_left_corner   ::T
    horizontal          ::T
    vertical            ::T
end

# Constructor
function Camera()
    aspect_ratio    = 16.0 / 9.0
    viewport_height = 2.0
    viewport_width  = aspect_ratio * viewport_height
    focal_length    = 1.0

    origin          = SVector(0.0, 0.0, 0.0)
    horizontal      = SVector(viewport_width, 0.0, 0.0)
    vertical        = SVector(0.0, viewport_height, 0.0)
    lower_left_corner = origin - horizontal / 2.0 - vertical / 2.0 - 
                            SVector(0.0, 0.0, focal_length)
    return Camera(origin, lower_left_corner, horizontal, vertical)
end

# Function to get ray
function get_ray(cam::Camera, u, v) 
    return Ray(cam.origin, 
               cam.lower_left_corner + 
               u*cam.horizontal + v*cam.vertical - cam.origin)
end