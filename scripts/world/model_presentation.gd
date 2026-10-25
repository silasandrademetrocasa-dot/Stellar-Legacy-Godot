extends RefCounted
## Presentation transforms only. Imported geometry/materials remain untouched.

static func bounds(node: Node3D) -> AABB:
    var result := AABB()
    var found := false
    var stack: Array[Dictionary] = [{"node": node, "transform": Transform3D.IDENTITY}]
    while not stack.is_empty():
        var entry: Dictionary = stack.pop_back()
        var current: Node3D = entry["node"]
        var relative: Transform3D = entry["transform"]
        if current is MeshInstance3D and (current as MeshInstance3D).mesh != null:
            var box: AABB = relative * (current as MeshInstance3D).get_aabb()
            result = result.merge(box) if found else box
            found = true
        for child in current.get_children():
            if child is Node3D:
                stack.append({"node": child, "transform": relative * (child as Node3D).transform})
    return result

static func create_visual(model: Node3D, target_span: float) -> Node3D:
    # A centered outer pivot can turn without orbiting around the authored origin.
    var pivot := Node3D.new()
    pivot.name = "VisualPivot"
    var mount := Node3D.new()
    mount.name = "ModelMount"
    pivot.add_child(mount)
    mount.add_child(model)
    var box := bounds(mount)
    var span := maxf(box.size.x, box.size.z)
    if span > 0.001:
        var factor := target_span / span
        mount.scale = Vector3.ONE * factor
        mount.position = -box.get_center() * factor
    return pivot

static func relative_transform(node: Node3D, ancestor: Node3D) -> Transform3D:
    var result := Transform3D.IDENTITY
    var current: Node = node
    while current != null and current != ancestor:
        if current is Node3D:
            result = (current as Node3D).transform * result
        current = current.get_parent()
    return result
