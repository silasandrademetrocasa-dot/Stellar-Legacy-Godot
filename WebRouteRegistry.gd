extends Node
## Autoload singleton: WebRouteRegistry
## Loads route IDs mapped from the existing Web DOM IDs.
signal route_requested(route: String, web_id: String)
var routes: Dictionary = {}
var menu_groups: Dictionary = {}

func _ready() -> void:
    var file := FileAccess.open("res://routes.json", FileAccess.READ)
    if file == null:
        push_error("Missing res://routes.json")
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        routes = parsed.get("web_id_to_godot_route", {})
        menu_groups = parsed.get("menus", {})

func navigate_web_id(web_id: String) -> void:
    if not routes.has(web_id):
        push_warning("Unknown web route: " + web_id)
        return
    route_requested.emit(str(routes[web_id]["route"]), web_id)

func get_menu(menu_id: String) -> Array:
    return menu_groups.get(menu_id, [])
