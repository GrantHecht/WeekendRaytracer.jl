using WeekendRaytracer
using Images
using StaticArrays
using LinearAlgebra
using Profile
using BenchmarkTools
using Infiltrator
using JET
#using AbbreviatedStackTraces

function main()
    # Image
    image = Image(aspect_ratio      = 16 / 9, 
                  width             = 400, 
                  samples_per_pixel = 100,
                  max_depth         = 50)

    # World
    world = random_scene()

    # Camera
    lookfrom    = SVector(13.0,2.0,3.0)
    lookat      = SVector(0.0,0.0,0.0)
    vup         = SVector(0.0,1.0,0.0)
    dist_to_foc = 10.0
    aperture    = 0.1
    cam = Camera(lookfrom,lookat,vup,20.0,image.aspect_ratio,aperture,dist_to_foc;
                 time0 = 0.0, time1 = 0.01)

    # Shoot image
    shoot!(image, cam, world; threaded = true)
    save("test_new.png", image)

    #u = (rand(1:image.width) + rand()) / image.width
    #v = (image.height - rand(1:image.height) + rand()) / image.height
    #r = WeekendRaytracer.get_ray(cam, u, v)
    #flag, t, left_hit_first = WeekendRaytracer.min_hit_time(r, world.top_node, cam.time0, cam.time1)
    #pix_color = WeekendRaytracer.ray_color(r, world, image.max_depth)
    #pix_color = WeekendRaytracer.get_pixel_color(image, cam, world, div(image.height, 2), div(image.width, 2))
    #flag, rec = WeekendRaytracer.hit(r, world.top_node, 0.001, Inf)
    #WeekendRaytracer.fire_ray(r, world.top_node, 0.001, Inf)
end

main()