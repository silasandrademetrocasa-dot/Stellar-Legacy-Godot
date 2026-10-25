extends Node3D
## Execute a cena demo_reles.tscn para experimentar os estados sem alterar main.tscn.
const LV1: PackedScene = preload("res://scenes/relays/rele_lv1.tscn")
const LV2: PackedScene = preload("res://scenes/relays/rele_lv2.tscn")
const LV3: PackedScene = preload("res://scenes/relays/rele_lv3.tscn")
var active_relay: Node3D
var current_level: int = 1
var orbit: float = 0.0
@onready var camera: Camera3D = $Camera3D
@onready var info: Label = $CanvasLayer/Controls
func _ready() -> void:
    var world: WorldEnvironment = WorldEnvironment.new()
    var env: Environment = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.008,0.014,0.04)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.25,0.34,0.48)
    env.ambient_light_energy = 0.7
    world.environment = env
    add_child(world)
    var sun: DirectionalLight3D = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55,-35,0)
    sun.light_energy = 0.9
    add_child(sun)
    _switch_level(1)
func _switch_level(level: int) -> void:
    if active_relay != null:
        active_relay.queue_free()
    var sources: Array[PackedScene] = [LV1,LV2,LV3]
    current_level = level
    active_relay = sources[level-1].instantiate() as Node3D
    add_child(active_relay)
    _refresh_label()
func _refresh_label() -> void:
    info.text = "STELLAR LEGACY — RELES LV%d\n1/2/3: Niveis | Q: Repouso | W: Combate | E: Escudo quebrado | R: Evolucao | T: Evoluir de nivel" % current_level
func _process(delta: float) -> void:
    orbit += delta*0.13
    camera.position = Vector3(11.0*sin(orbit),7.3,11.0*cos(orbit))
    camera.look_at(Vector3(0,2.0,0),Vector3.UP)
func _unhandled_input(event: InputEvent) -> void:
    if not (event is InputEventKey): return
    var k: InputEventKey = event as InputEventKey
    if not k.pressed or k.echo: return
    match k.keycode:
        KEY_1: _switch_level(1)
        KEY_2: _switch_level(2)
        KEY_3: _switch_level(3)
        KEY_Q: active_relay.call("set_state",0)
        KEY_W: active_relay.call("set_state",1)
        KEY_E: active_relay.call("set_state",2)
        KEY_R: active_relay.call("set_state",3)
        KEY_T: active_relay.call("promote_to_next_level")
