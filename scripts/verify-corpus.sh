#!/usr/bin/env bash
# verify-corpus.sh — Integridad del corpus contra el manifiesto frontexpert/corpus-manifest/v1.
# Herramienta del playbook (no es código de producto — ADR-0012). Origen: ADR-0013, issue #1.
# Sin red, solo stdlib (shasum/sha256sum). Fail-closed: manifiesto ausente, archivo faltante
# o hash distinto → exit 1. Correr desde cualquier directorio; copiable sin edición.
# Este script ES parte del corpus: editarlo exige regenerar el manifiesto en el mismo commit.
# Regenerar manifiesto desde la raíz del repo:
#   find README.md LICENSE AGENTS.md CONTRIBUTING.md .github docs fuente plantillas scripts -type f -print0 | sort -z | xargs -0 shasum -a 256 > .frontexpert/corpus-manifest-v1.sha256
set -euo pipefail
cd "$(dirname "$0")/.."

manifest=".frontexpert/corpus-manifest-v1.sha256"
if [ ! -f "$manifest" ]; then
  echo "ERROR: falta $manifest — corpus sin integridad verificable (ADR-0013)." >&2
  exit 1
fi

if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 -c "$manifest"
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum -c "$manifest"
else
  echo "ERROR: ni shasum ni sha256sum disponibles en PATH." >&2
  exit 1
fi

echo "Integridad OK: $(grep -vcE '^[[:space:]]*(#|$)' "$manifest") archivos verificados contra $manifest."
