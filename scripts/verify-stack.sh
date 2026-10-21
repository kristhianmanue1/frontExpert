#!/usr/bin/env bash
# verify-stack.sh — Verificación de versiones del stack contra fuentes primarias.
# Herramienta del playbook (no es código de producto — ADR-0012).
# Origen: docs/06-verificacion-empirica.md §Cómo repetir. Correr antes de abrir cada fase.
# Solo consulta (npm registry, GitHub Advisory); no instala nada en el repo.
# Es observación, no gate de CI (ADR-0013): reporta vigencia para comparar contra docs/06 §A.
# Ojo: con `set -e`, sale !=0 si falta red o si los greps del bloque "Código publicado" dejan
# de encontrar sus cadenas — eso también es señal, pero no lo convierte en gate de versiones.
set -euo pipefail

echo "== npm registry: versiones vigentes =="
for pkg in next react ai expo nativewind tailwindcss typescript zod @mastra/core @playwright/mcp turbo pnpm vitest @tanstack/react-query eslint shadcn; do
  printf '%-26s %s\n' "$pkg" "$(npm view "$pkg" version)"
done

echo
echo "== nativewind dist-tags (¿v5 ya es estable?) =="
npm view nativewind dist-tags --json

echo
echo "== typescript-eslint: peers (¿sigue exigiendo TS <6.1?) =="
npm view typescript-eslint peerDependencies --json

echo
echo "== GitHub Advisory DB =="
gh api "/advisories?cve_id=CVE-2025-9611" --jq '.[].vulnerabilities' # Playwright MCP: DNS rebinding
gh api "/advisories?cve_id=CVE-2026-64642" --jq '.[].vulnerabilities' # Next.js: bypass de proxy

echo
echo "== Código publicado (tarballs, en temp) =="
tmp="$(mktemp -d)"
cd "$tmp"
npm pack ai@7 --silent >/dev/null && tar xzf ai-*.tgz && grep -n "toolApprovalSecret" package/dist/index.d.ts | head -2
npm pack @playwright/mcp --silent >/dev/null && tar xzf playwright-mcp-*.tgz && grep -n "RCE-equivalent\|not a security boundary" package/README.md | head -3
cd - >/dev/null && rm -rf "$tmp"

echo
echo "Hecho. Comparar contra docs/06 §A y 02 §1: si cambia una major, abrir ADR (spec §1)."
