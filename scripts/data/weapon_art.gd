extends RefCounted
## G0.22: 8 mesh archetypes from original user package; prices, combat balance
## and gameplay IDs are preserved. GLBs are always HQ with embedded textures.
const MODELS = {
    "ARC-1": "res://assets/weapons/SL_ARMA_ARC_HQ.glb",
    "ARC-2": "res://assets/weapons/SL_LASER_PULSE_HQ.glb",
    "ARC-3": "res://assets/weapons/SL_LASER_BEAM_HQ.glb",
    "ARC-4": "res://assets/weapons/SL_CANHAO_PLASMA_HQ.glb",
    "ARC-P1": "res://assets/weapons/SL_LANCA_PARTICULAS_HQ.glb",
    "ARC-Q": "res://assets/weapons/SL_CANHAO_GAUSS_HQ.glb",
    "VORTEX-X": "res://assets/weapons/SL_CANHAO_ION_HQ.glb",
    "CATACLISMO": "res://assets/weapons/SL_DESINTEGRADOR_HQ.glb",
}
static func model_for(name: String) -> String:
    return str(MODELS.get(name, ""))
