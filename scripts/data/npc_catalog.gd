extends RefCounted
## Catálogo de nomes exibidos — extraído de public/data.js na WEB V64.
## Chaves técnicas são apenas caminhos de recursos. NUNCA IDs do Supabase.

const NAMES := {
    "streuner": "Scavenger",
    "recruitStreuner": "Scavenger Scout",
    "aiderStreuner": "Scavenger Support",
    "bossStreuner": "Scavenger Prime",
    "lordakia": "Vrax",
    "bossLordakia": "Vrax Prime",
    "saimon": "Zyron",
    "bossSaimon": "Zyron Prime",
    "mordon": "Kharon",
    "bossMordon": "Kharon Prime",
    "devolarium": "Dreadnox",
    "bossDevolarium": "Dreadnox Prime",
    "sibelon": "Colossar",
    "bossSibelon": "Colossar Prime",
    "riftScout": "Batedor da Fenda",
    "bossRiftScout": "Batedor da Fenda Prime",
    "voidCorsair": "Corsário do Vazio",
    "bossVoidCorsair": "Corsário do Vazio Prime",
    "nexusWarden": "Guardião Nexus",
    "bossNexusWarden": "Guardião Nexus Prime",
    "astralReaper": "Ceifador Astral",
    "bossAstralReaper": "Ceifador Astral Prime",
}

static func display_name(model_key: String) -> String:
    return str(NAMES.get(model_key, "Inimigo não catalogado"))
