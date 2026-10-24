extends RefCounted
## Stellar Legacy: somente nomes novos. Chaves de arquivo baseadas nos nossos NPCs.
const NAMES := {
    "scavenger": "Scavenger",
    "scavenger_scout": "Scavenger Scout",
    "scavenger_support": "Scavenger Support",
    "scavenger_prime": "Scavenger Prime",
    "vrax": "Vrax",
    "vrax_prime": "Vrax Prime",
    "kharon": "Kharon",
    "kharon_prime": "Kharon Prime",
    "zyron": "Zyron",
    "zyron_prime": "Zyron Prime",
    "colossar": "Colossar",
    "colossar_prime": "Colossar Prime",
    "dreadnox": "Dreadnox",
    "dreadnox_prime": "Dreadnox Prime",
    "batedor_fenda": "Batedor da Fenda",
    "corsario_vazio": "Corsário do Vazio",
    "ceifador_astral": "Ceifador Astral",
    "ceifador_astral_prime": "Ceifador Astral Prime",
    "guardiao_nexus": "Guardião Nexus",
}

static func display_name(model_key: String) -> String:
    return str(NAMES.get(model_key, "Inimigo sem nome"))
