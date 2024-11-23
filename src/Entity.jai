#import "GetRect";

entities : [..]Entity;

entity_size :: Vector2.{ 20, 30 };
entity_size_half :: Vector2.{ 10, 15 };

Entity :: struct {
    pos: Vector2;
    theta: float;
}

get_entity_up :: (entity: Entity) -> Vector2 {
    global_up :: Vector2.{ 0, 1 };
    return rotate_around_origin(global_up, entity.theta);
}

get_entity_right :: (entity: Entity) -> Vector2 {
    entity_up := get_entity_up(entity);
    return rotate_dir_90_deg_cw(entity_up);
}

get_entity_quad :: (entity: Entity) -> Quad {
    local_up := get_entity_up(entity);
    local_right := get_entity_right(entity);

    v1 := entity.pos - local_up * entity_size_half.y - local_right * entity_size_half.x;
    v2 := v1 + local_right * entity_size.x;
    v3 := v2 + local_up * entity_size.y;
    v4 := v1 + local_up * entity_size.y;

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

    for entities {
        if it.theta == 0 
            then draw_rect(it.pos, entity_size, color);
            else {
                quad := get_entity_quad(it);
                draw_quad_raw(quad, color);
            }
    }
}