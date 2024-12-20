PositionalGizmo :: struct {
    pos: Vector2;
    right: Vector2;
    up: Vector2;
    tri_x: Tri;
    tri_y: Tri;
    quad_xy: Quad;
    mode: PositionalGizmoMode;
    pending: Vector2;
}

PositionalGizmoMode :: enum u8 {
    None;
    X;
    Y; 
    XY;
}

new_positional_gizmo :: (gizmo: *PositionalGizmo, pos: Vector2, dir_x: Vector2) {
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
        v1_offset := gizmo_length * .5 - gizmo_interaction_size * .5;
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
        gizmo.mode, 
        gizmo.pending
    };
}

draw_positional_gizmo :: (gizmo: PositionalGizmo) {
    pos := gizmo.pos;

    draw_gizmo_axis(pos, gizmo.up, gizmo.right);

    // x
    {
        color := ifx gizmo.mode == PositionalGizmoMode.X 
            then color_gizmo_interactive
            else color_gizmo_red;
        
        draw_world_tri(gizmo.tri_x, color);
    }
    
    // y
    {
        color := ifx gizmo.mode == PositionalGizmoMode.Y
            then color_gizmo_interactive
            else color_gizmo_green;
            
        draw_world_tri(gizmo.tri_y, color);
    }

    // xy
    {
        color := ifx gizmo.mode == PositionalGizmoMode.XY
            then color_gizmo_interactive
            else color_gizmo_blue;

        draw_world_quad(gizmo.quad_xy, color);
    }
}

try_begin_gizmo_grab :: (gizmo: *PositionalGizmo) -> bool {
    if is_inside_quad(pointer_world_pos, gizmo.quad_xy) {
        gizmo.mode = PositionalGizmoMode.XY;
        return true;
    }

    if is_inside_triangle(pointer_world_pos, gizmo.tri_x) {
        gizmo.mode = PositionalGizmoMode.X;
        return true;
    }

    if is_inside_triangle(pointer_world_pos, gizmo.tri_y) {
        gizmo.mode = PositionalGizmoMode.Y;
        return true;
    }

    return false;
}

try_drag_gizmo :: (gizmo: *PositionalGizmo) {
    if gizmo.mode == PositionalGizmoMode.None return;

    selected := get_selected();
    world_pos := selected.pos;

    delta_pos : Vector2;
    if gizmo.mode == {
        case PositionalGizmoMode.X; delta_pos = project(pointer_delta, gizmo.right);
        case PositionalGizmoMode.Y; delta_pos = project(pointer_delta, gizmo.up);
        case PositionalGizmoMode.XY; delta_pos = pointer_delta;
    }

    gizmo.pending += delta_pos;
    selected.pos += delta_pos;
}

release_gizmo :: (gizmo: *PositionalGizmo) {
    gizmo.mode = PositionalGizmoMode.None;

    if gizmo.pending != .{ 0, 0 } {
        entity := get_selected();

        event : HistoricalEvent;
        set(*event, PositionalHistoryEvent.{ entity.id, gizmo.pending });
        record(*history, event);

        gizmo.pending = .{ 0, 0 };
    }
}

#scope_file

gizmo_quad_length :: gizmo_interaction_size;
gizmo_arrow_height :: gizmo_interaction_size;
gizmo_arrow_width :: gizmo_arrow_height * .75;
gizmo_arrow_half_width :: gizmo_arrow_width * .5;
