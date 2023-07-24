using WeekendRaytracer
using Images
using StaticArrays
using LinearAlgebra
using BenchmarkTools
using Infiltrator

function random_scene()
    # Create emplty vector for accumulatng objects
    # This won't be type stable but we'll be able to construct 
    # a definite type HittableList at the end
    objects = []

    # The ground
    ground_material = Lambertian(0.5, 0.5, 0.5)
    push!(objects, Sphere(SVector(0.0, -1000.0, 0.0), 1000.0, ground_material))

    for a = -11:10
        for b = -11:10
            choose_mat = rand()
            center = SVector(a + 0.9*rand(), 0.2, b + 0.9*rand())

            if norm(center - SVector(4.0, 0.2, 0.0)) > 0.9
                if choose_mat < 0.8
                    # Diffuse
                    albedo = RGB(rand()*rand(), rand()*rand(), rand()*rand())
                    sphere_meterial = Lambertian(albedo)
                    push!(objects, Sphere(center, 0.2, sphere_meterial))

                elseif choose_mat < 0.95
                    # Metal
                    albedo  = RGB(0.5*(1.0 + rand()), 0.5*(1.0 + rand()), 0.5*(1.0 + rand()))
                    fuzz    = 0.5*rand()
                    sphere_material = Metal(albedo, fuzz)
                    push!(objects, Sphere(center, 0.2, sphere_material))
                else
                    # Glass
                    sphere_material = Dielectric(1.5)
                    push!(objects, Sphere(center, 0.2, sphere_material))
                end
            end
        end
    end

    mat1 = Dielectric(1.5)
    push!(objects, Sphere(SVector(0.0, 1.0, 0.0), 1.0, mat1))

    mat2 = Lambertian(0.4, 0.2, 0.1)
    push!(objects, Sphere(SVector(-4.0, 1.0, 0.0), 1.0, mat2))

    mat3 = Metal(0.7, 0.6, 0.5, 0.0)
    push!(objects, Sphere(SVector(4.0, 1.0, 0.0), 1.0, mat3))

    return HittableList(objects...)
end

function main()
    # Image
    image = Image("test.png"; aspect_ratio      = 3.0 / 2.0, 
                              width             = 1200, 
                              samples_per_pixel = 500,
                              max_depth         = 50)

    # World
    world = random_scene()

    # Camera
    lookfrom    = SVector(13.0,2.0,3.0)
    lookat      = SVector(0.0,0.0,0.0)
    vup         = SVector(0.0,1.0,0.0)
    dist_to_foc = 10.0
    aperture    = 0.1
    cam = Camera(lookfrom,lookat,vup,20.0,image.aspect_ratio,aperture,dist_to_foc)

    # Shoot image
    shoot!(image, cam, world; threaded = true)
    #@btime shoot!($image, $cam, $world; threaded = false)
    #@btime shoot!($image, $cam, $world; threaded = true)
end

main()