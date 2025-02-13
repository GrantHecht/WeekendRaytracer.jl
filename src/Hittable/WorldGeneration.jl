
# Random Scene from Ray Tracing in One Weekend
# See https://raytracing.github.io/books/RayTracingInOneWeekend.html
function random_scene()
    # Create emplty vector for accumulatng objects
    # This won't be type stable but we'll be able to construct
    # a definite type HittableList at the end
    objects = []

    # The ground
    #ground_material = Lambertian(0.5, 0.5, 0.5)
    #ground_material = Metal(RGB(0.5, 0.5, 0.5), 0.5*rand())
    ground_texture  = CheckerTexture(RGB(0.2, 0.3, 0.1), RGB(0.9, 0.9, 0.9))
    ground_material = Lambertian(ground_texture)
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
                    center2 = center + SVector(0.0, 0.5*rand(), 0.0)
                    push!(objects, Sphere(center, center2, 0.0, 1.0, 0.2, sphere_meterial))

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

    # Testing
    return BVHWorld(BVHNode(0.0, 1.0, objects), RGB(0.7, 0.8, 1.0))
end

function two_spheres()
    checker = CheckerTexture(RGB(0.2, 0.3, 0.1), RGB(0.9, 0.9, 0.9))
    s1 = Sphere(SVector(0.0, -10.0, 0.0), 10.0, Lambertian(checker))
    s2 = Sphere(SVector(0.0,  10.0, 0.0), 10.0, Lambertian(checker))
    return BVHWorld(BVHNode(0.0, 0.0, [s1, s2]), RGB(0.7, 0.8, 1.0))
end

function two_perlin_spheres()
    pertext = NoiseTexture(4)
    s1 = Sphere(SVector(0.0, -1000.0, 0.0), 1000.0, Lambertian(pertext))
    s2 = Sphere(SVector(0.0, 2.0, 0.0), 2.0, Lambertian(pertext))
    return BVHWorld(BVHNode(0.0, 0.0, [s1, s2]), RGB(0.7, 0.8, 1.0))
end

function not_so_pale_blue_dot()
    earth_texture = ImageTexture(earth)
    earth_surface = Lambertian(earth_texture)
    globe         = Sphere(SVector(0.0, 0.0, 0.0), 2.0, earth_surface)
    return BVHWorld(BVHNode(0.0, 0.0, [globe]), RGB(0.7, 0.8, 1.0))
end

function simple_light()
    pertext = NoiseTexture(4)
    o1      = Sphere(SVector(0.0, -1000.0, 0.0), 1000.0, Lambertian(pertext))
    o2      = Sphere(SVector(0.0, 2.0, 0.0), 2.0, Lambertian(pertext))
    light   = DiffuseLight(RGB(1.0, 1.0, 1.0))
    o3      = XYRectangle(3.0, 5.0, 1.0, 3.0, -2.0, light)
    return BVHWorld(BVHNode(0.0, 0.0, [o1,o2,o3]), RGB(0.0, 0.0, 0.0))
end

function cornel_box()
    # Define colors
    red     = Lambertian(RGB(0.65, 0.05, 0.05))
    white   = Lambertian(RGB(0.73, 0.73, 0.73))
    green   = Lambertian(RGB(0.12, 0.45, 0.15))
    light   = DiffuseLight(RGB(15.0, 15.0, 15.0))

    # Define world
    world = BVHWorld(
                BVHNode(
                    0.0, 0.0,
                    [
                        YZRectangle(0.0, 555.0, 0.0, 555.0, 555.0, green),
                        YZRectangle(0.0, 555.0, 0.0, 555.0, 0.0, red),
                        XZRectangle(213.0, 343.0, 227.0, 332.0, 554.0, light),
                        XZRectangle(0.0, 555.0, 0.0, 555.0, 0.0, white),
                        XZRectangle(0.0, 555.0, 0.0, 555.0, 555.0, white),
                        XYRectangle(0.0, 555.0, 0.0, 555.0, 555.0, white),
                        Translate(
                            RotateY(
                                Box(SA[0.0, 0.0, 0.0], SA[165.0, 330.0, 165.0], white),
                                15.0,
                            ),
                            SA[265.0, 0.0, 295.0],
                        ),
                        Translate(
                            RotateY(
                                Box(SA[0.0, 0.0, 0.0], SA[165.0, 165.0, 165.0], white),
                                -18.0,
                            ),
                            SA[130.0, 0.0, 65.0],
                        )
                    ],
                ),
                RGB(0.0, 0.0, 0.0)
            )
    return world
end

function cornel_smoke()
    # Define colors
    red     = Lambertian(RGB(0.65, 0.05, 0.05))
    white   = Lambertian(RGB(0.73, 0.73, 0.73))
    green   = Lambertian(RGB(0.12, 0.45, 0.15))
    light   = DiffuseLight(RGB(15.0, 15.0, 15.0))

    # Define world
    world = BVHWorld(
                BVHNode(
                    0.0, 0.0,
                    [
                        YZRectangle(0.0, 555.0, 0.0, 555.0, 555.0, green),
                        YZRectangle(0.0, 555.0, 0.0, 555.0, 0.0, red),
                        XZRectangle(213.0, 343.0, 227.0, 332.0, 554.0, light),
                        XZRectangle(0.0, 555.0, 0.0, 555.0, 0.0, white),
                        XZRectangle(0.0, 555.0, 0.0, 555.0, 555.0, white),
                        XYRectangle(0.0, 555.0, 0.0, 555.0, 555.0, white),
                        Translate(
                            RotateY(
                                ConstantMediumBox(SA[0.0, 0.0, 0.0], SA[165.0, 330.0, 165.0], 0.01, SolidColor(RGB(1.0,1.0,1.0))),
                                15.0,
                            ),
                            SA[265.0, 0.0, 295.0],
                        ),
                        Translate(
                            RotateY(
                                ConstantMediumBox(SA[0.0, 0.0, 0.0], SA[165.0, 165.0, 165.0], 0.01, SolidColor(RGB(0.0,0.0,0.0))),
                                -18.0,
                            ),
                            SA[130.0, 0.0, 65.0],
                        )
                    ],
                ),
                RGB(0.0, 0.0, 0.0)
            )
    return world
end

function final_scene()
    # Define materials
    ground = Lambertian(SolidColor(RGB(0.48, 0.83, 0.53)))

    # Create ground objects
    objects = []
    boxes_per_side = 20
    for i in 0:(boxes_per_side - 1)
        for j in 0:(boxes_per_side - 1)
            w   = 100.0
            x0  = -1000.0 + i*w
            z0  = -1000.0 + j*w
            y0  = 0.0
            x1  = x0 + w
            y1  = 1.0 + 100.0*rand()
            z1  = z0 + w

            push!(objects, Box(SA[x0,y0,z0], SA[x1,y1,z1], ground))
        end
    end

    # Create light
    light = DiffuseLight(SolidColor(RGB(7.0, 7.0, 7.0)))

end
