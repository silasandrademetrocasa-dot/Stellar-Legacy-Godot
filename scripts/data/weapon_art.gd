extends RefCounted
## G0.22: 8 mesh archetypes from original user package; prices, combat balance
## and gameplay IDs are preserved. GLBs are always HQ with embedded textures.
const MODELS = {
    "ARC-1": "res://assets/pixel/catalog/equipment/sl_arma_arc_hq.png",
    "ARC-2": "res://assets/pixel/catalog/equipment/sl_laser_pulse_hq.png",
    "ARC-3": "res://assets/pixel/catalog/equipment/sl_laser_beam_hq.png",
    "ARC-4": "res://assets/pixel/catalog/equipment/sl_canhao_plasma_hq.png",
    "ARC-P1": "res://assets/pixel/catalog/equipment/sl_lanca_particulas_hq.png",
    "ARC-Q": "res://assets/pixel/catalog/equipment/sl_canhao_gauss_hq.png",
    "VORTEX-X": "res://assets/pixel/catalog/equipment/sl_canhao_ion_hq.png",
    "CATACLISMO": "res://assets/pixel/catalog/equipment/sl_desintegrador_hq.png",
}
static func model_for(name: String) -> String:
    return str(MODELS.get(name, ""))
