ThetaGizmo :: struct {
    pos: Vector2;
}

new_theta_gizmo :: (pos: Vector2) -> ThetaGizmo {
    return .{ pos };
}

draw_theta_gizmo :: (gizmo: ThetaGizmo) {
}

get_gizmo_mode :: (gizmo: ThetaGizmo) -> GizmoMode {
    return GizmoMode.None;
}
