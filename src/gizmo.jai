gizmo_length :: 100;
gizmo_half_length :: gizmo_length * .5;
gizmo_interaction_size :: gizmo_length * .2;
gizmo_interaction_half_size :: gizmo_interaction_size * .5;

color_gizmo_red :: Vector4.{ 1, 0, 0, 1 };
color_gizmo_green :: Vector4.{ 0, 1, 0, 1 };
color_gizmo_blue :: Vector4.{ 0, 0, 1, 1 };

color_gizmo_interactive :: Vector4.{ 1, 1, 0, 1 };

draw_axis :: (pos: Vector2, right: Vector2, up: Vector2) {
    draw_vector(
        pos - right * .5, 
        right * (gizmo_length + .5), 
        1,
        color_gizmo_red);

    draw_vector(
        pos + up * .5, 
        up * (gizmo_length - .5), 
        1,
        color_gizmo_green);
}