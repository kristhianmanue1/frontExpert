# Handoff — frontExpert (preproyecto)

> Estado entre sesiones (se reescribe al cerrar cada una; ver `03 §6`). No es bitácora.

- **Actualizado:** 2026-10-21 (cierre de sesión).
- **Fase:** 0 de 6 — **cerrada** (enmendada por ADR-0011). Lista para abrir la fase 1.
- **Decisiones firmadas:** ADRs 0001 (stack), 0002 (bots), 0004 (orquestación), 0006 (lint), 0008 (i18n/analytics), 0010 (CI local), 0011 (puerta fase 0). Diferidas con plazo: 0003/0005/0007 (**antes de fase 3**, preguntas 3, 4 y 7). 0009: spike en fase 1 (default: NativeWind 4 + tokens generados).
- **Repo:** `github.com/kristhianmanue1/frontExpert` (privado), `main` sincronizado. Protección de rama **diferida** (GitHub Free): control procedural — **resolver antes del primer PR de agente** (los primeros PRs los abre/fusiona el humano).
- **Última verificación:** `scripts/verify-stack.sh` 21-oct — sin cambios de major; NativeWind v5 sigue en RC; Vitest corregido a 5.x; CVEs sin movimiento.
- **En curso:** nada abierto.
- **Siguiente paso:** (2) registrar el runner local (`docs/runbooks/ci-local.md`) + primer workflow mínimo; (3) scaffold de fase 1 por tareas de agente (`plantillas/tarea-agente.md`). Antes de fase 2: definición corta de producto (pantallas y alcance del asistente) — pendiente del dueño.
- **Reglas activas:** commit/push autorizados por el dueño; merge a `main` solo humano; CI local (ADR-0010); previews recortados a staging-on-merge; jobs de PR en contenedor `sandbox` sin secretos.
