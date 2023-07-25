using WeekendRaytracer
using Images
using StaticArrays
using LinearAlgebra
using Profile
using BenchmarkTools
using Infiltrator
using JET

function main()
    # Image
    image = Image(aspect_ratio      = 3.0 / 2.0, 
                  width             = 400, 
                  samples_per_pixel = 500,
                  max_depth         = 50)

    # World
    world = WorldGeneration.random_scene()

    # Camera
    lookfrom    = SVector(13.0,2.0,3.0)
    lookat      = SVector(0.0,0.0,0.0)
    vup         = SVector(0.0,1.0,0.0)
    dist_to_foc = 10.0
    aperture    = 0.1
    cam = Camera(lookfrom,lookat,vup,20.0,image.aspect_ratio,aperture,dist_to_foc)

    # Shoot image
    shoot!(image, cam, world, threaded = true)
    save("test_new.png", image)
end

main()