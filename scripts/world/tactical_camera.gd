extends RefCounted
## G0.23: enquadramento estabilizado a partir do video de referencia.
## Projecao ortografica = sem aumento repentino de tamanho por perspectiva.
const CAMERA_OFFSET := Vector3(0.0, 69.0, 32.0)
const CAMERA_SIZE := 36.0
const FOLLOW_SPEED := 5.0

static func configure(camera: Camera3D, target: Vector3) -> void:
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = CAMERA_SIZE
    camera.near = 0.1
    camera.far = 1300.0
    camera.global_position = target + CAMERA_OFFSET
    camera.look_at(target, Vector3.UP)

static func follow(camera: Camera3D, target: Vector3, delta: float) -> void:
    var desired: Vector3 = target + CAMERA_OFFSET
    camera.global_position = camera.global_position.lerp(desired, minf(delta * FOLLOW_SPEED, 1.0))
    camera.look_at(target, Vector3.UP)
