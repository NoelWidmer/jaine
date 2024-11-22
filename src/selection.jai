#import "GetRect";

get_selected :: () -> *Entity {
    if selected == -1 then return null;
    return *entities[selected];
}

try_select_entity :: () -> bool {
    for entities {
        rect := get_entity_rect(it);

        if is_inside(pointer_world_pos.x, pointer_world_pos.y, rect) {
            if selected == it_index {
                selected = -1;
            } else {
                selected = it_index;
                invalidate_gizmo();
            }

            return true;
        }
    }

    return false;
}

delete_selected_entity :: (ev: Event) {
    if ev.key_pressed || selected == -1 then return;
    despawn_entity(selected);
    selected = -1;
}

draw_selection_gizmo :: () {
    if selected == -1 return;

    invalidate_gizmo();
    draw_gizmo(gizmo);
}

overlaps_gizmo :: () -> bool {
    if selected == -1 return false;
    return overlaps_asd(gizmo);
}

#scope_file

selected : s64 = -1;
gizmo : Vector2Gizmo;

invalidate_gizmo :: () {
    entity := entities[selected];
    gizmo = new_gizmo(entity.pos, .{ 1, 0 });
}
