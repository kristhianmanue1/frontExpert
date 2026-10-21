# Handoff — frontExpert (playbook)

> Estado entre sesiones (se reescribe al cerrar cada una; ver `03 §6`). No es bitácora.

- **Actualizado:** 2026-10-21 (cierre de sesión, tras ADR-0012).
- **Modelo:** **playbook puro** (ADR-0012) — este repo NO construye producto; produce el "cómo" que otros proyectos adoptan. La fase 1 la ejecuta el primer adoptante, en su propio repo.
- **Fase 0:** cerrada (ADR-0011). ADRs de referencia firmados: 0001, 0002, 0004, 0006, 0008, 0010, 0011, 0012. Diferidos (se resuelven en cada adopción): 0003/0005/0007 (antes de fase 3 del adoptante), 0009 (spike de fase 1 del adoptante, default: NativeWind 4 + tokens generados).
- **Repo:** `github.com/kristhianmanue1/frontExpert` (privado), `main` sincronizado. Protección de rama diferida (GitHub Free): procedural; sin PRs de agente en este repo, el riesgo es bajo.
- **Última verificación:** `scripts/verify-stack.sh` 21-oct — sin cambios de major; NativeWind v5 sigue en RC; Vitest corregido a 5.x.
- **En curso:** nada abierto.
- **Siguiente paso:** preparar la **primera adopción** — identificar el proyecto adoptante, entregarle el paquete (docs + plantillas + verify-stack) y acompañar su fase 1 (el manual aún no ha sido ejecutado: la primera adopción lo estrena y lo corrige). Opcional: mini-CI de docs en este repo (runner + markdown lint).
- **Reglas activas:** commit/push autorizados por el dueño; merge a `main` solo humano; decisiones de producto, herramientas y hosting = del adoptante, no de este repo.
