
struct Camera{T <: AbstractArray, U <: AbstractFloat}
    # Origin of camera
    origin              ::T

    # Location of lower left corner of viewport (in pixle coordinates)
    lower_left_corner   ::T

    # Horizontal and vertial dimensions of viewport (in pixles)
    horizontal          ::T
    vertical            ::T

    # Camera frame basis vectors
    u                   ::T
    v                   ::T
    w                   ::T

    # Camera lense radius
    lens_radius        ::U

    # Shutter time
    time0              ::U
    time1              ::U
end

# Constructor
function Camera(
    lookfrom, lookat, vup, vfov, aspect_ratio, aperture, focus_dist;
    time0 = 0.0,
    time1 = 0.0,
)
    theta           = deg2rad(vfov)
    h               = tan(0.5 * theta)
    viewport_height = 2.0 * h
    viewport_width  = aspect_ratio * viewport_height

    wvec            = lookfrom - lookat
    uvec            = cross(vup, wvec)
    vvec            = cross(wvec, uvec)
    invNwvec        = 1.0 / norm(wvec)
    invNuvec        = 1.0 / norm(uvec)
    invNvvec        = 1.0 / norm(vvec)
    w               = SA[invNwvec*wvec[1], invNwvec*wvec[2], invNwvec*wvec[3]]
    u               = SA[invNuvec*uvec[1], invNuvec*uvec[2], invNuvec*uvec[3]]
    v               = SA[invNvvec*vvec[1], invNvvec*vvec[2], invNvvec*vvec[3]]

    origin          = lookfrom
    horizontal      = focus_dist * viewport_width * u
    vertical        = focus_dist * viewport_height * v
    lower_left_corner = origin - 0.5 * horizontal - 0.5 * vertical - focus_dist * w
    lens_radius     = 0.5 * aperture
    return Camera(origin, lower_left_corner, horizontal, vertical, u, v, w, lens_radius, time0, time1)
end

# Function to get ray
function get_ray(cam::Camera, s::T, t::T)  where {T <: AbstractFloat}
    unit    = random_in_unit_disk(T)
    rd      = SA[cam.lens_radius*unit[1], cam.lens_radius*unit[2]]
    offset  = SA[cam.u[1]*rd[1] + cam.v[1]*rd[2], cam.u[2]*rd[1] + cam.v[2]*rd[2], 0.0]

    origin  = SA[cam.origin[1] + offset[1], cam.origin[2] + offset[2], cam.origin[3] + offset[3]]
    dir     = cam.lower_left_corner + s*cam.horizontal + t*cam.vertical - cam.origin - offset
    tm      = cam.time0 + (cam.time1 - cam.time0)*rand()
    return Ray(origin, dir, tm)
end
