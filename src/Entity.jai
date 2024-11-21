#import "GetRect";

entities : [..]Entity;

entity_size :: Vector2.{ 20, 20 };
entity_size_half :: Vector2.{ 10, 10 };

Entity :: struct {
    pos: Vector2;
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
    for entities {
        draw_rect(it.pos, entity_size, .{ 1, 1, 1, 1 });
    }
}