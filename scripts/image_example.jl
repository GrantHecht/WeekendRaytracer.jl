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
    image = Image(aspect_ratio      = 1.0,
                  width             = 600,
                  samples_per_pixel = 400,
                  max_depth         = 50)

    # World
    #world = random_scene()
    #world = two_spheres()
    #world = two_perlin_spheres()
    #world = not_so_pale_blue_dot()
    #world = simple_light()
    world = cornel_box()
    #world = cornel_smoke()

    # Camera
    lookfrom    = SVector(278.0,278.0,-800.0)
    lookat      = SVector(278.0,278.0,0.0)
    vup         = SVector(0.0,1.0,0.0)
    dist_to_foc = 10.0
    aperture    = 0.1
    vfov        = 40.0
    cam = Camera(
        lookfrom, lookat,
        vup, vfov,
        image.aspect_ratio,
        aperture,
        dist_to_foc;
        time0 = 0.0,
        time1 = 0.0,
    )

    # Shoot image
    shoot!(image, cam, world; threaded = true)
    save("test_new.png", image)

    # u = (rand(1:image.width) + rand()) / image.width
    # v = (image.height - rand(1:image.height) + rand()) / image.height
    # r = WeekendRaytracer.get_ray(cam, u, v)
    # #flag, t, left_hit_first = WeekendRaytracer.min_hit_time(r, world.top_node, cam.time0, cam.time1)
    # pix_color = WeekendRaytracer.ray_color(r, world, image.max_depth)
    # pix_color = WeekendRaytracer.get_pixel_color(image, cam, world, div(image.height, 2), div(image.width, 2))
    # #flag, rec = WeekendRaytracer.hit(r, world.top_node, 0.001, Inf)
    # #@report_opt WeekendRaytracer.fire_ray(r, world.top_node, 0.001, Inf)
end

main()
