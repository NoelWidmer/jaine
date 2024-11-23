rotate_dir_90_deg_cw :: (dir: Vector2) -> Vector2 {
    return .{ dir.y, -dir.x };
}

rotate_dir_90_deg_ccw :: (dir: Vector2) -> Vector2 {
    return .{ -dir.y, dir.x };
}

Tri :: struct {
    v1: Vector2;
    v2: Vector2;
    v3: Vector2;
}

Quad :: struct {
    v1: Vector2;
    v2: Vector2;
    v3: Vector2;
    v4: Vector2;
}

is_inside_quad :: (point: Vector2, quad: Quad) -> bool {
    if !is_inside_side(point, quad.v1, quad.v2) then return false;
    if !is_inside_side(point, quad.v3, quad.v4) then return false;
    if !is_inside_side(point, quad.v2, quad.v3) then return false;
    return is_inside_side(point, quad.v4, quad.v1);
}

is_inside_triangle :: (point: Vector2, tri: Tri) -> bool {
    if !is_inside_side(point, tri.v1, tri.v2) then return false;
    if !is_inside_side(point, tri.v2, tri.v3) then return false;
    return is_inside_side(point, tri.v3, tri.v1);
}

rotate_around_pivot :: (point: Vector2, pivot: Vector2, angle: float) -> Vector2 {
    rotated := rotate_around_origin(point - pivot, angle);
    return rotated + pivot;
}

rotate_around_origin :: (point: Vector2, angle: float) -> Vector2 {
    angle_rad := angle * deg2rad;

    s := sin(angle_rad);
    c := cos(angle_rad);

    return .{ 
        point.x * c - point.y * s, 
        point.x * s + point.y * c 
    };
}

angle :: (u: Vector2, v: Vector2) -> float {    
    d := dot(u, v);
    magU := length(u);
    magV := length(v);

    if magU == 0 || magV == 0 then return 0;

    cosTheta := d / (magU * magV);

    if cosTheta > 1 then cosTheta = 1;
    if cosTheta < -1 then cosTheta = -1;

    return acos(cosTheta) * rad2deg;
}

project :: (v: Vector2, dir: Vector2) -> Vector2 {
    v_dot_dir := dot(v, dir);
    dir_dot_dir := dot(dir, dir);
    return (v_dot_dir / dir_dot_dir) * dir;
}

deg2rad :: PI / 180;
rad2deg :: 180 / PI;

#scope_file

is_inside_side :: (point: Vector2, v1: Vector2, v2: Vector2) -> bool {
    a := v2 - v1;
    b := point - v1;
    return dot(a, b) > 0;
}