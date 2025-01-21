#import "Basic";
#import "Bucket_Array";
#import "Hash_Table";
#import "Entity";
#import "Camera";

World :: struct {
    entities : Bucket_Array(Entity, 128);
    entity_by_id : Table(u64, *Entity);
    next_id : u64;
}

new_world :: () -> World {
    return .{ };
}

add_entity :: (world: *World) -> *Entity {
    locator, entity := bucket_array_add(*world.entities, .{ id = world.next_id });
    entity.locator = locator;

    table_add(*world.entity_by_id, world.next_id, entity);
    world.next_id += 1;  

    return entity;
}

get_entity :: (world: *World, id: u64) -> *Entity {
    entity, success := table_find(*world.entity_by_id, id);
    return ifx success then entity else null;
}

remove_entity :: (entity: *Entity, world: *World) {
    success, _ := table_remove(*world.entity_by_id, entity.id);
    assert(success, "could not remove an entity from the id lookup.");

    // record history
    bucket_array_remove(*world.entities, entity.locator);
}

draw_world :: (cam: *Camera, world: *World) {
    for world.entities {
        draw_entity(cam, it);
    }
}