extends RefCounted
## G0.24: escala tática dos NPCs em unidades de tela (nao altera hit points ou alcance).
## Normaliza modelos de dimensoes diferentes sem simplificar GLBs.
const LIGHT_SPAN := 3.05
const MEDIUM_SPAN := 3.72
const HEAVY_SPAN := 4.42
const BOSS_SPAN := 5.65

static func span(npc_id: String) -> float:
    var k: String = npc_id.to_lower()
    if k.contains("colossar") or k.contains("boss") or k.contains("prime"):
        return BOSS_SPAN
    if k.contains("dreadnox") or k.contains("ceifador") or k.contains("guardiao") or k.contains("kharon"):
        return HEAVY_SPAN
    if k.contains("scout") or k.contains("scavenger") or k.contains("batedor"):
        return LIGHT_SPAN
    return MEDIUM_SPAN
