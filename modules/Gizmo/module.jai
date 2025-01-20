#import "Camera";
#import "History";
#import "Mathe";
#import "Math";
#import "Viewport";
#import "draw";
#import "Tagged_Union";

#load "./PositionalGizmo.jai";
#load "./RotationalGizmo.jai";

Gizmo :: union { 
  vector2: PositionalGizmo; 
  theta: RotationalGizmo;
}

gizmo_length :: 100;
gizmo_interaction_size :: gizmo_length * .2;

color_gizmo_red :: Vector4.{ 1, 0, 0, 1 };
color_gizmo_green :: Vector4.{ 0, 1, 0, 1 };
color_gizmo_blue :: Vector4.{ 0, 0, 1, 1 };

color_gizmo_interactive :: Vector4.{ 1, 1, 0, 1 };

draw_gizmo_axis :: (cam: *Camera, pos: Vector2, up: Vector2, right: Vector2) {
    // x
    draw_world_vector(
        cam,
        pos, 
        right * gizmo_length, 
        1,
        color_gizmo_red);

    // y
    draw_world_vector(
        cam,
        pos - up * .5, 
        up * (gizmo_length + .5), 
        1,
        color_gizmo_green);
}