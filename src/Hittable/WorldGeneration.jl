
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
    a1 = 15.0
    a2 = -18.0
    R1 = SA[cosd(a1) 0.0 sind(a1); 0.0 1.0 0.0; -sind(a1) 0.0 cosd(a1)]
    R2 = SA[cosd(a2) 0.0 sind(a2); 0.0 1.0 0.0; -sind(a2) 0.0 cosd(a2)]
    o1 = SA[265.0, 0.0, 295.0]
    o2 = SA[130.0, 0.0, 65.0]

    box1 = Transformation(
        Box(SA[0.0, 0.0, 0.0], SA[165.0, 330.0, 165.0], white),
        R1, o1,
    )
    box2 = Transformation(
        Box(SA[0.0, 0.0, 0.0], SA[165.0, 165.0, 165.0], white),
        R2, o2,
    )

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
                        box1, box2
                    ],
                    SAH(),
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
    a1 = 15.0
    a2 = -18.0
    R1 = SA[cosd(a1) 0.0 sind(a1); 0.0 1.0 0.0; -sind(a1) 0.0 cosd(a1)]
    R2 = SA[cosd(a2) 0.0 sind(a2); 0.0 1.0 0.0; -sind(a2) 0.0 cosd(a2)]
    o1 = SA[265.0, 0.0, 295.0]
    o2 = SA[130.0, 0.0, 65.0]
    box1 = Transformation(
        ConstantMediumBox(SA[0.0, 0.0, 0.0], SA[165.0, 330.0, 165.0], 0.01, SolidColor(RGB(0.0,0.0,0.0))),
        R1, o1,
    )
    box2 = Transformation(
        ConstantMediumBox(SA[0.0, 0.0, 0.0], SA[165.0, 165.0, 165.0], 0.01, SolidColor(RGB(1.0,1.0,1.0))),
        R2, o2,
    )
    world = BVHWorld(
                BVHNode(
                    0.0, 0.0,
                    [
                        YZRectangle(0.0, 555.0, 0.0, 555.0, 555.0, green),
                        YZRectangle(0.0, 555.0, 0.0, 555.0, 0.0, red),
                        Quadrilateral(SA[113.0,554.0,127.0], SA[330.0,0.0,0.0], SA[0.0,0.0,305.0], light),
                        XZRectangle(0.0, 555.0, 0.0, 555.0, 0.0, white),
                        XZRectangle(0.0, 555.0, 0.0, 555.0, 555.0, white),
                        XYRectangle(0.0, 555.0, 0.0, 555.0, 555.0, white),
                        box1, box2,
                    ],
                ),
                RGB(0.0, 0.0, 0.0)
            )
    return world
end

function quads()
    # Materials
    left_red     = Lambertian(SolidColor(RGB(1.0, 0.2, 0.2)));
    back_green   = Lambertian(SolidColor(RGB(0.2, 1.0, 0.2)));
    right_blue   = Lambertian(SolidColor(RGB(0.2, 0.2, 1.0)));
    upper_orange = Lambertian(SolidColor(RGB(1.0, 0.5, 0.0)));
    lower_teal   = Lambertian(SolidColor(RGB(0.2, 0.8, 0.8)));

    # Quads
    world = BVHWorld(
        BVHNode(
            0.0, 0.0,
            [
                Quadrilateral(SA[-3.0,-2.0,5.0], SA[0.0,0.0,-4.0], SA[0.0,4.0,0.0], left_red),
                Quadrilateral(SA[-2.0,-2.0,0.0], SA[4.0,0.0,0.0], SA[0.0,4.0,0.0], back_green),
                Quadrilateral(SA[3.0,-2.0,1.0], SA[0.0,0.0,4.0], SA[0.0,4.0,0.0], right_blue),
                Quadrilateral(SA[-2.0,3.0,1.0], SA[4.0,0.0,0.0], SA[0.0,0.0,4.0], upper_orange),
                Quadrilateral(SA[-2.0,-3.0,5.0], SA[4.0,0.0,0.0], SA[0.0,0.0,-4.0], lower_teal),
            ],
        ),
        RGB(0.7, 0.8, 1.0),
    )
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
    light_obj = Quadrilateral(
        SA[123.0,554.0,147.0], SA[300.0,0.0,0.0], SA[0.0,0.0,265.0], light,
    )
    push!(objects, light_obj)

    # Moving sphere
    # center1     = SA[400.0, 400.0, 200.0]
    # center2     = center1 + SA[30.0,0.0,0.0]
    # sphere_mat  = Lambertian(SolidColor(RGB(0.7,0.3,0.1)))
    # sphere      = Sphere(center1,center2,0.0,0.01,50.0,sphere_mat)
    # push!(objects, sphere)

    # Glass sphere and metal spheres
    push!(
        objects,
        Sphere(
            SA[260.0,150.0,45.0], 50.0,
            Dielectric(1.5),
        )
    )
    push!(
        objects,
        Sphere(
            SA[0.0,150.0,145.0], 50.0,
            Metal(SolidColor(RGB(0.8,0.8,0.9)), 0.5)
        )
    )

    # Boundary
    boundary1 = Sphere(
        SA[360.0,150.0,145.0], 70.0,
        Dielectric(1.5),
    )
    boundary2 = ConstantMediumSphere(
        SA[0.0,0.0,0.0], 5000.0, 0.0001, SolidColor(RGB(1.0,1.0,1.0))
    )
    push!(objects, boundary1)
    push!(objects, ConstantMedium(boundary1, 0.2, SolidColor(RGB(0.2,0.4,0.9))))
    push!(objects, boundary2)

    # Earth
    earth_texture = ImageTexture(earth)
    earth_surface = Lambertian(earth_texture)
    push!(
        objects,
        Sphere(SA[400.0, 200.0, 400.0], 100.0, earth_surface)
    )

    # Noise
    pertexture = NoiseTexture(0.2)
    push!(
        objects,
        Sphere(
            SA[220.0,280.0,300.0], 80.0,
            Lambertian(pertexture),
        )
    )

    # Random spheres
    # objects2 = []
    white = Lambertian(SolidColor(RGB(0.73,0.73,0.73)))
    ns = 1000
    for i = 1:1000
        #push!(
        #    objects2,
        #    Sphere(165.0*@SVector(rand(3)), 10.0, white)
        #)
        push!(
            objects,
            Translate(
                RotateY(
                    Sphere(165.0*@SVector(rand(3)), 10.0, white),
                    15.0,
                ),
                SA[-100.0,270.0,395.0],
            )
        )
    end
    # objects2_bvhnode = BVHNode(0.0,0.0,objects2)
    # push!(
    #     objects,
    #     Translate(
    #         RotateY(objects2_bvhnode, 15.0),
    #         SA[-100.0,270.0,395.0],
    #     )
    # )


    return BVHWorld(
        BVHNode(0.0, 0.01, objects, SAH()),
        RGB(0.0, 0.0, 0.0),
    )
end
