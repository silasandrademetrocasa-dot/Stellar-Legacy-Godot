#!/usr/bin/env python3
"""Validate the owner's stage IDs, tracking states and calendar-free planning contract."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {'PENDENTE', 'EM DESENVOLVIMENTO', 'PRONTO PARA TESTES', 'AGUARDANDO APROVAÇÃO', 'APROVADO', 'BLOQUEADO'}
roadmap = (ROOT / 'docs/ROADMAP.md').read_text()
status = (ROOT / 'docs/PROJECT_STATUS.md').read_text()
ids = re.findall(r'^## ETAPA (\d{2}) — ', roadmap, re.M)
expected = [f'{i:02d}' for i in range(12)]
if ids != expected:
    raise SystemExit(f'Expected ordered stages {expected}, found {ids}')
rows = re.findall(r'^\| (\d{2}) \| ([^|]+) \| ([^|]+) \|', status, re.M)
if [row[0] for row in rows] != expected:
    raise SystemExit('Tracking must contain each stage exactly once')
for stage, name, state in rows:
    if state.strip() not in ALLOWED:
        raise SystemExit(f'Invalid state for {stage}: {state}')
for name in ['docs/ROADMAP.md', 'docs/PROJECT_STATUS.md', 'docs/PLANO_MIGRACAO.md']:
    text = (ROOT / name).read_text()
    if re.search(r'\b(?:semanas?|weeks?|deadlines?)\b|\b20\d{2}[-/]\d{2}[-/]\d{2}\b|\b\d+\s+(?:dias?|meses|anos)\b', text, re.I):
        raise SystemExit('Calendar-bound milestone found in ' + name)
for block in re.split(r'^## ETAPA \d{2} — .+$', roadmap, flags=re.M)[1:]:
    for criterion in ['**Objetivo:**', '**Entregas:**', '**Conclusão:**', '**Dependências:**']:
        if criterion not in block:
            raise SystemExit('Stage missing ' + criterion)
print('PROJECT PLAN: stages 00-11, allowed states, deliverables and calendar-free criteria passed')
