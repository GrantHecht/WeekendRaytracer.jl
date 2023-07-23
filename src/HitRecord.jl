
# Define struct for recording a "hit", i.e., the contact
# of a Ray with a Hittable
mutable struct HitRecord{T <: AbstractArray, 
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

# Define function to set face normal
function set_face_normal!(rec::HitRecord{T,U}, ray::Ray, outward_normal) where {T <: SArray, U}
    rec.front_face  = dot(ray.dir, outward_normal) < 0
    rec.normal      = ref.front_face ? T(outward_normal...) : T(-outward_normal...)
end
function set_face_normal!(rec::HitRecord, ray::Ray, outward_normal)
    rec.front_face  = dot(ray.dir, outward_normal) < 0
    rec.normal     .= rec.front_face ? outward_normal : -outward_normal
end