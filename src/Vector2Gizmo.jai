Vector2Gizmo :: struct {
    pos: Vector2;
    tri_x: Tri;
    tri_y: Tri;
    quad_xy: Quad;
}

new_gizmo :: (pos: Vector2, dir_x: Vector2) -> Vector2Gizmo {
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
        v1_offset := gizmo_half_length - gizmo_arrow_half_height;
        v1 := pos + dir_x * v1_offset + dir_y * v1_offset;

        v2 := Vector2.{ v1.x + gizmo_arrow_height, v1.y };

        v3_v4_offset := dir_y * gizmo_arrow_height;

        quad_xy = .{ 
            v1, 
            v2, 
            v2 + v3_v4_offset, 
            v1 + v3_v4_offset
        };
    }

    return .{
        pos,
        tri_x,
        tri_y,
        quad_xy
    };
}

draw_gizmo :: (gizmo: Vector2Gizmo) {
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

overlaps_asd :: (gizmo: Vector2Gizmo) -> bool {
    return is_inside_quad(pointer_world_pos, gizmo.quad_xy);
}

#scope_file

gizmo_length :: 100;
gizmo_half_length :: gizmo_length * .5;

gizmo_arrow_height :: gizmo_length * .2;
gizmo_arrow_half_height :: gizmo_arrow_height * .5;

gizmo_arrow_width :: gizmo_arrow_height * .75;
gizmo_arrow_half_width :: gizmo_arrow_width * .5;
