# 05 — Evaluación de la ronda adversarial externa (5 revisores, 25 hallazgos)

**Fecha:** 2026-10-17 · **Objeto revisado:** el **spec original**, no el v2 de este preproyecto.
**Qué se tuvo a la vista:** solo el resumen de la ronda (5 críticos, 12 altos y observaciones de evolución). Los 25 hallazgos individuales no se recibieron, así que no se pueden auditar uno por uno.

**Escala:** ✅ confirmado · ⚠️ válido, pero mal enunciado o exagerado · 🔁 ya cubierto en el v2 · ❌ no se sostiene.

---

## Hallazgo nuevo que la ronda no vio (lo más importante de esta revisión)

Al verificar el punto de `needsApproval` contra la **documentación vigente del AI SDK**:

- **`needsApproval` está deprecado.** La documentación actual dice: *"The older `needsApproval` property on `tool()` definitions is deprecated. Existing code still works, but new code should move approval logic to `toolApproval`."* La aprobación ahora se configura con `toolApproval` en `generateText`, `streamText` o `ToolLoopAgent`, ya sea con una función o con un mapa por tool (`'user-approval' | 'approved' | 'denied' | 'not-applicable'`).
- **El flujo confía en el historial que manda el cliente.** El servidor emite una parte `tool-approval-request` con un `approvalId`, y el cliente responde agregando `{ type: 'tool-approval-response', approvalId, approved: true }` a los mensajes. ~~La documentación no indica que el servidor valide el `approvalId`~~ **Corregido tras revisar el código (`06`):** el SDK sí revalida en el servidor el schema y la política, y ofrece una firma HMAC experimental (`experimental_toolApprovalSecret`) contra aprobaciones falsificadas o alteradas. No cubre replay, usuario ni expiración.

➡️ Tanto el spec original como nuestro v2 decían "`needsApproval` obligatorio". **Estaba desactualizado y era insuficiente.** Se corrige en `02-spec-v2.md §4`.

---

## Evaluación punto por punto

### Los 5 "críticos"

| # | Afirmación | Veredicto | Comprobación | Acción |
|---|---|---|---|---|
| C1 | El middleware de bots por User-Agent es falsificable | ✅ 🔁 | Coincide con nuestro hallazgo 1.4 y el ADR-0002. | Ninguna nueva. |
| C2 | "`needsApproval` en el cliente es solo UX; un prompt injection lo bypasea; la aprobación tiene que vivir en el servidor" | ⚠️ **La conclusión es correcta, el mecanismo descrito no** | `needsApproval` no vive en el cliente: se declara en el servidor y el servidor pausa la ejecución. El problema real es que **la respuesta de aprobación llega en el historial que envía el cliente** y no se valida contra un registro del servidor. **Un prompt injection por sí solo no puede aprobar**, porque el modelo no genera partes `tool-approval-response`. El vector es otro: un cliente manipulado (XSS, extensión maliciosa, request fabricado), el **replay** de una aprobación vieja o un **historial alterado** donde cambian los argumentos de la tool después de aprobada. | **Adoptado y precisado:** ver "Aprobación con autoridad del servidor" en el spec v2 §4. |
| C3 | WebMCP sin rate limiting ni auth de tools abre superficie de ataque | ⚠️ | Las tools de WebMCP se ejecutan **en la página, con la sesión del usuario**. No necesitan "auth propia"; el riesgo es de **confused deputy**: un agente con prompt injection usa la sesión del usuario. La guía de Chrome pide `readOnlyHint`, `consequentialHint`, `untrustedContentHint`, `exposedTo` (solo orígenes confiables), `requestUserInteraction()` para confirmar y límites de tamaño (500 caracteres por descripción, 1.5K por salida). El **rate limiting va en el backend**, donde ya debía estar. | **Adoptado:** reglas de WebMCP en el spec v2 §5. |
| C4 | "Playwright MCP en navegador real es vector de RCE si el sandbox no está aislado" | ✅ **Confirmado (rectificado en `06`)**: la tool `browser_run_code_unsafe` viene activa por defecto y el README la llama *"RCE-equivalent"*. Mi veredicto original ("exagerado") era incorrecto | Existe **CVE-2025-9611**: Playwright MCP < 0.0.40 no validaba el header `Origin` y permitía **DNS rebinding** para invocar sus tools desde una web maliciosa (CVSS 7.2). Además, si el agente navega webs no confiables con el **perfil real del usuario**, se expone a prompt injection con sus cookies. ~~No encontré evidencia de RCE directo.~~ Sí la hay: ver `06`. | **Adoptado:** endurecimiento de Playwright MCP en `03-loop-agentes.md`. |
| C5 | `llms.txt` generado automáticamente puede filtrar información interna | ⚠️ Válido, pero no es crítico | Es cierto si se genera recorriendo todas las rutas o el contenido del CMS. El v2 decía "desde las mismas fuentes que el sitemap", que tiene el mismo riesgo. | **Adoptado:** se genera **desde un allowlist explícito de rutas públicas** con un test que falla si incluye rutas `/admin`, `/api` o privadas. Severidad: media. |

### Los 12 "altos" (agrupados)

| Afirmación | Veredicto | Comprobación | Acción |
|---|---|---|---|
| No hay CI definido, así que "commit que pasa CI" es vacío | ✅ para el original · 🔁 en el v2 | El v2 fase 1 define lint, typecheck, Vitest, Playwright, axe, Lighthouse CI, build de ambas apps, gitleaks y boundaries. | Ninguna nueva. |
| El agente abre PR y no hace push a `main` | ✅ 🔁 | Ya está en `03-loop-agentes.md §3` y en `AGENTS.md`. | Se agrega **branch protection** como control técnico, no solo como regla escrita. |
| Faltan ambientes staging y prod con rollback | ✅ **Hueco real del v2** | El v2 solo tenía canales de EAS Update. | **Adoptado:** nuevo §9 "Ambientes y rollback" en el spec v2. |
| Falta observabilidad de tokens y costo por request | ⚠️ Parcial en el v2 | El v2 tenía telemetría y topes por sesión, pero no la métrica por request. | **Adoptado:** métricas obligatorias por request en §4. |

### Observaciones de evolución

| Afirmación | Veredicto | Comentario | Acción |
|---|---|---|---|
| Las fases asumen crecimiento lineal; los agentes iteran en espiral, y falta una fase de descarte formal | ✅ **Buena observación** | Tiene razón: el v2 no tenía dónde poner un experimento ni cómo tirarlo. Pero no hace falta una "fase": basta un **mecanismo transversal**. | **Adoptado:** *spikes* con fecha de caducidad y ADR `superseded` (spec v2 §10). |
| No se define qué pasa cuando un modelo nuevo genera código incompatible: ¿regenerar o parchear? | ⚠️ | El código no es "del modelo": pasa por la misma CI, sea cual sea el modelo. La pregunta útil es **cuándo se cambia el modelo del loop** y **cuándo conviene regenerar un módulo**. | **Adoptado:** política en `03-loop-agentes.md §7`. |
| `packages/core` tiende a volverse un god-package | ⚠️ 🔁 parcial | El v2 ya tenía subcarpetas (`domain`, `schemas`, `api`, `routes`, `analytics`), pero sin una regla que las haga cumplir. | **Adoptado:** `exports` por subpath + regla de dependencias interna (`domain` no importa `api`, etc.). |
| Corrección más barata: un "agente linter" custom que falle el build si se viola el spec | ⚠️ **Buena idea con el nombre equivocado** | Las reglas dispersas del v2 (boundaries, lint de tokens, check de CSS-in-JS, test de aprobaciones) sí conviene **unificarlas en un paquete**. Pero tiene que ser **determinista** (ESLint, dependency-cruiser, scripts), **no un agente**: un LLM en el build es no determinista, caro y se puede manipular con prompt injection desde el código que revisa. | **Adoptado como `packages/spec-lint`** (spec v2 §11). Opcionalmente, un agente revisor *además*, solo como advertencia. |
| Definir el formato exacto de tareas y prompts para que cada sesión no parta de cero | ✅ 🔁 | Ya está en `plantillas/tarea-agente.md` y `03-loop-agentes.md §4`. | Se agrega un **handoff de sesión** (`docs/handoff.md`) para el estado entre sesiones. |

---

## Balance

| | Cantidad |
|---|---|
| Ya cubiertos por el v2 | 5 (C1, CI, PR, formato de tareas y parte de god-package) |
| Válidos y nuevos para el v2 | 7 (C2 precisado, C3, C4, C5, ambientes/rollback, costo por request, espiral/descarte) |
| Válidos con reformulación | 2 (política de cambio de modelo, linter determinista en lugar de agente) |
| Hallazgo propio derivado de la verificación | 1 (**`needsApproval` deprecado → `toolApproval`**) |

**Conclusión:** la ronda aporta valor real, sobre todo en aprobaciones, ambientes, espiral y spec-lint. Pero **dos de sus cinco "críticos" estaban mal calibrados** (C2 en el mecanismo y C5 en la severidad; C4 resultó correcto tras verificar el código, ver `06`) y **no detectó que la API que estaba criticando ya estaba deprecada**. Antes de citar sus severidades conviene pedir los 25 hallazgos completos con evidencia.
