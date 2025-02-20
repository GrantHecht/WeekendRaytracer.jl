using WeekendRaytracer
using Images
using StaticArrays
using LinearAlgebra
using ChunkSplitters
using Infiltrator
using BenchmarkTools
#using AbbreviatedStackTraces

@enum WorldSetup begin
    RandomScene
    Earth
    PerlinSpheres
    Quads
    CornelBox
    CornelSmoke
    FinalSceneLoFi
    FinalSceneHiFi
end

function get_setup(world_setup::WorldSetup)
    if world_setup == CornelBox || world_setup == CornelSmoke
        world = world_setup == CornelBox ? cornel_box() : cornel_smoke()

        image = Image(
            aspect_ratio      = 1.0,
            width             = 600,
            samples_per_pixel = 50,
            max_depth         = 50,
        )
        cam = Camera(
            SA[278.0,278.0,-800.0],
            SA[278.0,278.0,0.0],
            SA[0.0,1.0,0.0],
            40.0,
            image.aspect_ratio,
            0.1,
            10.0;
        )
    elseif world_setup == FinalSceneLoFi || world_setup == FinalSceneHiFi
        world = final_scene()

        image = Image(
            aspect_ratio      = 1.0,
            width             = world_setup == FinalSceneHiFi ? 800 : 400,
            samples_per_pixel = world_setup == FinalSceneHiFi ? 10000 : 250,
            max_depth         = world_setup == FinalSceneHiFi ? 40 : 4,
        )
        cam = Camera(
            SA[478.0,278.0,-600.0],
            SA[278.0,278.0,0.0],
            SA[0.0,1.0,0.0],
            40.0,
            image.aspect_ratio,
            0.1,
            10.0;
            time0 = 0.0,
            time1 = 0.01,
        )
    elseif world_setup == RandomScene
        world = random_scene()
        image = Image(
            aspect_ratio      = 16.0 / 9.0,
            width             = 800,
            samples_per_pixel = 100,
            max_depth         = 50,
        )
        cam = Camera(
            SA[13.0,2.0,3.0],
            SA[0.0,0.0,0.0],
            SA[0.0,1.0,0.0],
            20.0,
            image.aspect_ratio,
            0.1,
            10.0;
        )
    elseif world_setup == Earth
        world = not_so_pale_blue_dot()
        image = Image(;
            aspect_ratio      = 16.0 / 9.0,
            width             = 400,
            samples_per_pixel = 100,
            max_depth         = 50,
        )
        cam = Camera(
            SA[0.0,0.0,12.0],
            SA[0.0,0.0,0.0],
            SA[0.0,1.0,0.0],
            20.0,
            image.aspect_ratio,
            0.1,
            10.0;
        )
    elseif world_setup == PerlinSpheres
        world = two_perlin_spheres()
        image = Image(
            aspect_ratio      = 16.0 / 9.0,
            width             = 800,
            samples_per_pixel = 100,
            max_depth         = 50,
        )
        cam = Camera(
            SA[13.0,2.0,3.0],
            SA[0.0,0.0,0.0],
            SA[0.0,1.0,0.0],
            20.0,
            image.aspect_ratio,
            0.1,
            10.0;
        )
    elseif world_setup == Quads
        world = quads()
        image = Image(
            aspect_ratio      = 1.0,
            width             = 800,
            samples_per_pixel = 100,
            max_depth         = 50,
        )
        cam = Camera(
            SA[0.0,0.0,9.0],
            SA[0.0,0.0,0.0],
            SA[0.0,1.0,0.0],
            80.0,
            image.aspect_ratio,
            0.1,
            10.0;
        )
    end
    return (world, image, cam)
end

function main(world, image, cam)
    # Shoot image
    shoot!(
        image, cam, world;
        threaded    = true,
        n           = round(Int, Threads.nthreads() / 1),
        split       = RoundRobin()
    )

    save("test_new.png", image)
end

world, image, cam = get_setup(FinalSceneHiFi)

#@btime main($world, $image, $cam)
#Profile.clear_malloc_data()
main(world, image, cam)
# Profile.clear()
# Profile.@profile main(world, image, cam)
# #ProfileView.@profview main(world, image, cam)
# open("profile.txt", "w") do io
#     Profile.print(io)
# end
