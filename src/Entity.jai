#import "GetRect";

entities : [..]Entity;

entity_size :: Vector2.{ 20, 30 };
entity_size_half :: Vector2.{ 10, 15 };

Entity :: struct {
    pos: Vector2;
    theta: float;
}

get_entity_rect :: (entity: Entity) -> Rect {
    p := entity.pos;

    return get_rect(
        p.x - entity_size_half.x, 
        p.y - entity_size_half.y, 
        entity_size.x, 
        entity_size.y);
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
                global_up :: Vector2.{ 0, 1 };

                local_up := rotate_around_origin(global_up, it.theta);
                local_right := rotate_dir_90_deg_ccw(local_up);

                v1 := it.pos - local_up * entity_size_half.y - local_right * entity_size_half.x;
                v2 := v1 + local_right * entity_size.x;
                v3 := v2 + local_up * entity_size.y;
                v4 := v1 + local_up * entity_size.y;

                draw_quad_raw(.{ v1, v2, v3, v4 }, color);
            }
    }
}