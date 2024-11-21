#import "GetRect";

selected : s64 = -1;

try_select_entity :: () -> bool {
    for entities {
        rect := get_entity_rect(it);

        if is_inside(pointer_world_pos.x, pointer_world_pos.y, rect) {
            if selected == it_index {
                selected = -1;
            } else {
                selected = it_index;
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
