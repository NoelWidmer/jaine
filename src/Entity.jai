#import "GetRect";

entities : [..]Entity;

Entity :: struct {
    pos: Vector2;
    theta: float;
}

get_entity_size :: () -> Vector2 {
    return .{ xx strawberry.width, xx strawberry.height };
}

get_entity_up :: (entity: Entity) -> Vector2 {
    global_up :: Vector2.{ 0, 1 };
    if entity.theta == 0 return global_up;
    return rotate(global_up, entity.theta);
}

get_entity_right :: (entity: Entity) -> Vector2 {
    global_right :: Vector2.{ 1, 0 };
    if entity.theta == 0 return global_right;
    entity_up := get_entity_up(entity);
    return rotate_dir_90_deg_cw(entity_up);
}

get_entity_quad :: (entity: Entity) -> Quad {
    local_up := get_entity_up(entity);
    local_right := get_entity_right(entity);

    size := get_entity_size();
    size_half := size * .5;

    v1 := entity.pos - local_up * size_half.y - local_right * size_half.x;
    v2 := v1 + local_right * size.x;
    v3 := v2 + local_up * size.y;
    v4 := v1 + local_up * size.y;

    return .{ v1, v2, v3, v4 };
}

spawn_entity :: () {
    entity : Entity = .{
        pos = pointer_world_pos
    };

    array_add(*entities, entity);
}

despawn_entity :: (index: s64) {
    array_unordered_remove_by_index(*entities, index);
}

draw_entities :: () {
    color :: Vector4.{ 1, 1, 1, 1 };
    
    Simp.set_shader_for_images(*strawberry);

    for entities {
        if it.theta == 0 {
            size := get_entity_size();
            draw_rect(it.pos, size, color);
        } else {
                uv := Quad.{
                    .{ 0, 0 },
                    .{ 1, 0 },
                    .{ 1, 1 },
                    .{ 0, 1 }
                };

                quad := get_entity_quad(it);
                draw_quad_uv_raw(quad, uv, color);
            }
    }
}