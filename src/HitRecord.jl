
# Define struct for recording a "hit", i.e., the contact
# of a Ray with a Hittable
struct HitRecord{T <: AbstractArray, 
                 U <: AbstractFloat, 
                 M <: AbstractMaterial}
    p       ::T
    normal  ::T
    t       ::U

    # Material hit
    mat     ::M

    # Bool to indicate if we hit fromt face of object
    front_face::Bool
end
