# ADR-0011 · Enmienda a la puerta de la fase 0

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-21

## Contexto

La puerta original (`02 §6` fase 0) exigía los ADRs 0001–0008 aprobados antes de escribir código. El análisis del 21-oct mostró que tres de ellos (0003 backend, 0005 auth, 0007 hosting) no son consumidos por ninguna tarea de la fase 1: son dependencias de la fase 3. Mantener la puerta original retrasaba el arranque sin proteger nada; abrirla sin más dejaría esas decisiones "algún día".

## Decisión

- La fase 0 queda **cerrada** con: ADRs 0001, 0002, 0006 y 0010 aprobados, `AGENTS.md` y allowlist de MCP revisados.
- 0003, 0005 y 0007 quedan diferidos con **plazo explícito: necesarios antes de abrir la fase 3** (condicionados a las preguntas 3, 4 y 7 de `04`).
- 0009 se resuelve dentro de la fase 1 (spike con time-box de 2 días y default).
- Las preguntas abiertas de `04` llevan fecha de necesidad y default escrito, revocable cuando llegue la respuesta real.

## Consecuencias

- La fase 1 arranca de inmediato sin recortar verificación: no toca backend, autenticación ni hosting.
- Las decisiones diferidas tienen fecha límite real (fase 3), no "algún día".
- Si la fase 3 se acerca sin respuestas, se reabre este ADR en lugar de improvisar.
