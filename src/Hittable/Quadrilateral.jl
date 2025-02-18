
struct Quadrilateral{T, M <: AbstractMaterial} <: HittableQuadrilateral
    q::SVector{3,T}
    u::SVector{3,T}
    v::SVector{3,T}
    w::SVector{3,T}
    normal::SVector{3,T}
    d::T
    mat ::M

    function Quadrilateral(
        q::AbstractVector{T},
        u::AbstractVector{T},
        v::AbstractVector{T},
        mat::M
    ) where {T, M <: AbstractMaterial}
        # Ensure we have static arrays
        _q = SA[q[1],q[2],q[3]]
        _u = SA[u[1],u[2],u[3]]
        _v = SA[v[1],v[2],v[3]]

        n       = cross(u,v)
        w       = n / dot(n,n)
        normal  = n / norm(n)
        d = dot(normal, _q)

        return new{T,M}(_q,_u,_v,w,normal,d,mat)
    end
end

function bounding_box(quad::Quadrilateral, time0, time_1)
    return FourPointAABB(
        quad.q,
        quad.q + quad.u,
        quad.q + quad.v,
        quad.q + quad.u + quad.v,
    )
end

function hit(ray::Ray, quad::Quadrilateral, t_min, t_max)
    denom = dot(quad.normal, ray.dir)

    # No hit if the ray is parallel to the plane
    if (abs(denom) < 1e-8)
        return false, HitRecord(SA[0.0,0.0,0.0], SA[0.0,0.0,0.0], -1.0, 0.0, 0.0, quad.mat, true)
    end

    # No hit if the hit point param t is outside of [t_min, t_max]
    t = (quad.d - dot(quad.normal, ray.orig)) / denom
    if t < t_min || t > t_max
        return false, HitRecord(SA[0.0,0.0,0.0], SA[0.0,0.0,0.0], -1.0, 0.0, 0.0, quad.mat, true)
    end

    # Determine if the hit point lies within the planar shape
    p = at(ray, t)
    planar_hitpt_vec = p - quad.q
    alpha  = dot(quad.w, cross(planar_hitpt_vec, quad.v))
    beta   = dot(quad.w, cross(quad.u, planar_hitpt_vec))
    if alpha < 0.0 || alpha > 1.0 || beta < 0.0 || beta > 1.0
        return false, HitRecord(SA[0.0,0.0,0.0], SA[0.0,0.0,0.0], -1.0, 0.0, 0.0, quad.mat, true)
    end

    front_face = denom < 0.0
    n = front_face ? quad.normal : -quad.normal
    rec = HitRecord(p, n, t, alpha, beta, quad.mat, front_face)
    return true, rec
end
