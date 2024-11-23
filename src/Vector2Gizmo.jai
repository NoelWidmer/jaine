Vector2Gizmo :: struct {
    pos: Vector2;
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
            base + dir_x * gizmo_interaction_size,
            base + offset,
            base - offset,
        };
    }

    tri_y : Tri = ---;
    {
        base := pos + dir_y * gizmo_length;
        offset := dir_x * gizmo_arrow_half_width;

        tri_y = .{
            base + dir_y * gizmo_interaction_size,
            base + offset,
            base - offset,
        };
    }

    quad_xy : Quad = ---;
    {
        v1_offset := gizmo_half_length - gizmo_interaction_half_size;
        v1 := pos + dir_x * v1_offset + dir_y * v1_offset;

        v2 := Vector2.{ v1.x + gizmo_interaction_size, v1.y };

        v3_v4_offset := dir_y * gizmo_interaction_size;

        quad_xy = .{ 
            v1, 
            v2, 
            v2 + v3_v4_offset, 
            v1 + v3_v4_offset
        };
    }

    <<gizmo = .{
        pos,
        tri_x,
        tri_y,
        quad_xy, 
        gizmo.mode
    };
}

draw_vector2_gizmo :: (gizmo: Vector2Gizmo) {
    pos := gizmo.pos;

    // x
    {
        color : Vector4 = .{ 1, 0, 0, 1 };
        
        draw_rect(
            .{ pos.x - .25 + gizmo_half_length, pos.y }, 
            .{ gizmo_length + .5, 1 }, 
            color);
        
        draw_tri_raw(gizmo.tri_x, color);
    }
    
    // y
    {
        color : Vector4 = .{ 0, 1, 0, 1 };

        draw_rect(
            .{ pos.x, pos.y + .25 + gizmo_half_length }, 
            .{ 1, gizmo_length - .5 }, 
            color);
            
        draw_tri_raw(gizmo.tri_y, color);
    }

    // xy
    draw_quad_raw(gizmo.quad_xy, .{ 0, 0, 1, .25 });
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
        case Vector2GizmoMode.X; selected.pos = .{ world_pos.x + pointer_delta.x, world_pos.y };
        case Vector2GizmoMode.Y; selected.pos = .{ world_pos.x, world_pos.y + pointer_delta.y };
        case Vector2GizmoMode.XY; selected.pos += pointer_delta;
    }
}

release_gizmo :: (gizmo: *Vector2Gizmo) {
    gizmo.mode = Vector2GizmoMode.None;
}

gizmo_length :: 100;
gizmo_interaction_size :: gizmo_length * .2;

#scope_file

gizmo_half_length :: gizmo_length * .5;

gizmo_interaction_half_size :: gizmo_interaction_size * .5;

gizmo_arrow_width :: gizmo_interaction_size * .75;
gizmo_arrow_half_width :: gizmo_arrow_width * .5;
