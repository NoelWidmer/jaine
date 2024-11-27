Vector2Gizmo :: struct {
    pos: Vector2;
    right: Vector2;
    up: Vector2;
    tri_x: Tri;
    tri_y: Tri;
    quad_xy: Quad;
    mode: Vector2GizmoMode;
}

Vector2GizmoMode :: enum u8 {
    None;
    X;
    Y; 
    XY;
}

new_vector2_gizmo :: (gizmo: *Vector2Gizmo, pos: Vector2, dir_x: Vector2) {
    dir_y := rotate_dir_90_deg_ccw(dir_x);

    tri_x : Tri = ---;
    {
        base := pos + dir_x * gizmo_length;
        offset := dir_y * gizmo_arrow_half_width;

        tri_x = .{
            base + dir_x * gizmo_arrow_height,
            base + offset,
            base - offset,
        };
    }

    tri_y : Tri = ---;
    {
        base := pos + dir_y * gizmo_length;
        offset := dir_x * gizmo_arrow_half_width;

        tri_y = .{
            base + dir_y * gizmo_arrow_height,
            base + offset,
            base - offset,
        };
    }

    quad_xy : Quad = ---;
    {
        v1_offset := gizmo_half_length - gizmo_interaction_half_size;
        v1 := pos + dir_x * v1_offset + dir_y * v1_offset;
        v2 := v1 + dir_x * gizmo_quad_length;
        v3_v4_offset := dir_y * gizmo_quad_length;

        quad_xy = .{ 
            v1, 
            v2, 
            v2 + v3_v4_offset, 
            v1 + v3_v4_offset
        };
    }

    <<gizmo = .{
        pos,
        dir_x, 
        dir_y,
        tri_x,
        tri_y,
        quad_xy, 
        gizmo.mode
    };
}

draw_vector2_gizmo :: (gizmo: Vector2Gizmo) {
    pos := gizmo.pos;

    // try cull
    {
        x := pos.x - right * gizmo_arrow_half_width;
        y := pos.y - up * gizmo_arrow_half_width
        size := gizmo_length + gizmo_arrow_height;
        aabb := get_rect(x, y, size, size);
        // TODO: check if can be culled, then return
    }

    draw_axis(pos, gizmo.right, gizmo.up);

    // x
    {
        color := ifx gizmo.mode == Vector2GizmoMode.X 
            then color_gizmo_interactive
            else color_gizmo_red;
        
        draw_tri_raw(gizmo.tri_x, color);
    }
    
    // y
    {
        color := ifx gizmo.mode == Vector2GizmoMode.Y
            then color_gizmo_interactive
            else color_gizmo_green;
            
        draw_tri_raw(gizmo.tri_y, color);
    }

    // xy
    {
        color := ifx gizmo.mode == Vector2GizmoMode.XY
            then color_gizmo_interactive
            else color_gizmo_blue;

        draw_quad_raw(gizmo.quad_xy, color);
    }
}

try_begin_gizmo_grab :: (gizmo: *Vector2Gizmo) -> bool {
    if is_inside_quad(pointer_world_pos, gizmo.quad_xy) {
        gizmo.mode = Vector2GizmoMode.XY;
        return true;
    }

    if is_inside_triangle(pointer_world_pos, gizmo.tri_x) {
        gizmo.mode = Vector2GizmoMode.X;
        return true;
    }

    if is_inside_triangle(pointer_world_pos, gizmo.tri_y) {
        gizmo.mode = Vector2GizmoMode.Y;
        return true;
    }

    return false;
}

try_drag_gizmo :: (gizmo: Vector2Gizmo) {
    if gizmo.mode == Vector2GizmoMode.None return;

    selected := get_selected();
    world_pos := selected.pos;

    if gizmo.mode == {
        case Vector2GizmoMode.X; selected.pos += project(pointer_delta, gizmo.right);
        case Vector2GizmoMode.Y; selected.pos += project(pointer_delta, gizmo.up);
        case Vector2GizmoMode.XY; selected.pos += pointer_delta;
    }
}

release_gizmo :: (gizmo: *Vector2Gizmo) {
    gizmo.mode = Vector2GizmoMode.None;
}

#scope_file

gizmo_quad_length :: gizmo_interaction_size;
gizmo_arrow_height :: gizmo_interaction_size;
gizmo_arrow_width :: gizmo_arrow_height * .75;
gizmo_arrow_half_width :: gizmo_arrow_width * .5;
