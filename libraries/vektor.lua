-- libraries/vektor.lua
local vektor = {}

-- Ermittelt 3 Orthogonale Vektoren zu einer quaternion
function vektor.erhalteVektorraum(q)
    local qx,qy,qz,qw = q.x and q.x or 0, q.y and q.y or 0, q.z and q.z or 0, q.w and q.w or 0
    local l = math.sqrt(qx^2 + qy^2 + qz^2 + qw^2)
    if l == 0 then return vector.new(1,0,0), vector.new(0,1,0), vector.new(0,0,1) end
    local x,y,z,w = q.x / l, q.y / l, q.z / l, q.w / l
    -- Hauptdiagonale,    -- symmetrischen
    local d1 = x^2 + y^2; local s1 = x*y + w*z
    local d2 = y^2 + z^2; local s2 = x*z - w*y
    local d3 = x^2 + z^2; local s3 = y*z + w*x
    local Rx = vector.new(1 - 2*d1, 2*s1, 2*s2)
    local Ry = vector.new(2*s1, 1 - 2*d2, 2*s3)
    local Rz = vector.new(2*s2, 2*s3, 1 - 2*d3)
    local function norm(vec) if vec:length() > 0 then return vec / vec:length() else return vec end end
    return norm(Rx), norm(Ry), norm(Rz)
end

local function sign(x) return (x<0 and -1 or 1) end

-- ermittelt den Winkel zwischen zwei Vektoren
function vektor.gerichteterWinkel(vec1,vec2)
    local dot = vec1:dot(vec2)
    local cross = vec1:cross(vec2)
    local mag = vec1:length() * vec2:length()
    if mag == 0 then return 0 end
    return math.deg(math.atan2(cross:length(),dot))
end

function vektor.orientierterWinkel(vec1, vec2, up)
    local mag = vec1:length() * vec2:length()
    if mag == 0 then return 0 end

    local sinWinkel = vec1:cross(vec2):dot(up) / (mag * up:length())
    local cosWinkel = vec1:dot(vec2) / mag
    local winkel = math.deg(math.acos(cosWinkel)) * sign(sinWinkel) * sign(cosWinkel)
	-- print(math.floor(180 - winkel))
    return (180 - winkel)
end

return vektor
