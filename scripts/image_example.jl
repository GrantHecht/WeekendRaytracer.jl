using WeekendRaytracer
using StaticArrays
using LinearAlgebra
using Infiltrator

function main()
    # Image
    image = Image("test.png")

    # World
    mat_ground = Lambertian(0.8, 0.8, 0.0)
    mat_center = Lambertian(0.7, 0.3, 0.3)
    mat_left   = Metal(0.8, 0.8, 0.8, 0.3)
    mat_right  = Metal(0.8, 0.6, 0.2, 1.0)
    world = HittableList(
        Sphere(SVector( 0.0, -100.5, -1.0), 100.0, mat_ground),
        Sphere(SVector( 0.0,    0.0, -1.0),   0.5, mat_center),
        Sphere(SVector(-1.0,    0.0, -1.0),   0.5, mat_left),
        Sphere(SVector( 1.0,    0.0, -1.0),   0.5, mat_right),
    )

    # Camera
    cam = Camera()

    # Shoot image
    shoot!(image, cam, world; threaded = true)
end

main()