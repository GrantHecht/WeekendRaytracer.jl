
# Define struct for recording a "hit", i.e., the contact
# of a Ray with a Hittable
struct HitRecord{T <: AbstractArray, 
                 U <: AbstractFloat, 
                 M <: AbstractMaterial}
    # Hit point
    p       ::T

    # Normal to surface at hit point
    normal  ::T

    # Distance from Ray origin to hit point
    t       ::U

    # Surface coordinates of hit point
    u       ::U
    v       ::U

    # Material hit
    # We need to call scatter on the material, so we're gonne need the 
    # material itself to dispatch on the scatter method. Consider not 
    # passing hit record back with hit call 
    mat     ::M

    # Bool to indicate if we hit fromt face of object
    front_face::Bool
end
