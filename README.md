# frontExpert — Preproyecto

**Objetivo:** definir el stack frontend (web, iOS y Android) más **mantenible y actualizable** para que lo desarrollen **agentes de IA** bajo supervisión humana.
**Estado:** preproyecto: análisis crítico del spec recibido y propuesta v2 para consenso. Todavía no hay código.
**Fecha:** 2026-10-17 (versiones verificadas en esa fecha; docs actualizados el 21-oct con ADR-0010).

## Resumen ejecutivo

El spec recibido **acierta en la dirección**: React + TypeScript, Next.js para web, Expo para móvil, shadcn como código propio, tokens, Zod, AI SDK y fases incrementales. **No debe ejecutarse tal cual**:

| Severidad | Hallazgo |
|---|---|
| 🔴 Crítico | Propone **saltarse la autenticación según el User-Agent** de los bots de IA. Es falsificable, puede contar como cloaking y además usa nombres de bots equivocados → `docs/adr/0002` |
| 🟠 Alto | **Versiones y APIs desfasadas**: `middleware` ahora es `proxy.ts` (Next 16), ViewTransition es estable en React **19.3** (no 19.2), la versión actual es AI SDK **7**, Next **16.4** y Expo **SDK 58**. NativeWind v5 **no** es estable (verificado en npm, ver `docs/06`) |
| 🟠 Alto | La **verificación automática llega tarde** (Playwright en la fase 4) y el **móvil llega tarde** (fase 5), con riesgo de contaminar `core` |
| 🟡 Medio | Hay cifras sin fuente ("27× menos tokens" de WebMCP; lo publicado es ~68–89 %). `llms.txt` está sobrevalorado: el 97 % no recibe peticiones |
| 🟡 Medio | MCPs redundantes (Filesystem, Sequential Thinking) y uno de terceros (DesignRevision) cuando existe el **oficial de shadcn**. Falta el **MCP oficial de Expo** y la documentación de la versión instalada de Next |
| 🟡 Medio | Faltan pruebas móviles, CI, autenticación, observabilidad, evals de IA, i18n, política de upgrades y seguridad de los agentes del producto |
| 🟠 Alto | *(tras la ronda adversarial)* `needsApproval` está **deprecado** y su reemplazo es `toolApproval`. La aprobación llega en el historial que envía el cliente, así que hay que validarla contra un registro del servidor. Faltaban además ambientes con rollback, costo por request, un mecanismo de spikes y descarte, y `spec-lint` → `docs/05` |
| 🟠 Alto | *(2ª ronda adversarial, 21-oct)* Los **jobs de PR** corrían código escrito por el agente sin aislamiento de secretos: ahora contenedor efímero sin secretos del host, y los de staging/producción se inyectan solo por merge a `main`; previews por PR recortados por presupuesto (ADR-0010) → `docs/07`, `02 §9` |
| 🟢 | Varios criterios de aceptación no se pueden verificar. Se reemplazaron por métricas medibles en CI |

## Contenido

| Archivo | Para qué |
|---|---|
| `fuente/spec-base-recibido.md` | El spec original, sin cambios (trazabilidad) |
| `docs/01-analisis-critico.md` | Revisión punto por punto: ✅ ⚠️ ❌, evidencia y propuesta |
| `docs/02-spec-v2.md` | **Spec corregido**, listo para entregar al agente: stack fijado, estructura, fases, criterios y anti-patrones |
| `docs/03-loop-agentes.md` | Contexto para agentes, allowlist de MCP, ciclo de tarea, redacción de tareas, revisión de PRs y métricas |
| `docs/04-riesgos-y-decisiones.md` | ADRs pendientes de la fase 0, registro de riesgos y preguntas abiertas |
| `docs/05-evaluacion-ronda-adversarial.md` | Evaluación de la ronda externa de 5 revisores: qué se adoptó, qué estaba mal calibrado y el hallazgo `toolApproval` |
| `docs/06-verificacion-empirica.md` | **Verificación contra npm, el código publicado y GitHub Advisory**: qué se confirmó, qué se refutó (incluidos errores propios) y cómo repetirlo |
| `docs/07-ronda-adversarial-2026-10-21.md` | 2ª ronda adversarial (revisor de contexto fresco): veredictos H1–H9/P1–P8, hallazgos nuevos N1–N4 y parches aplicados |
| `docs/adr/0002-politica-bots-ia.md` | ADR del hallazgo crítico |
| `plantillas/AGENTS.md` | Plantilla del archivo raíz para agentes |
| `plantillas/tarea-agente.md` | Plantilla de issue para tareas de agente |
| `docs/FUENTES.md` | Fuentes consultadas |

## Siguientes pasos

1. **Fase 0 cerrada (21-oct, ADR-0011):** aceptados 0001, 0002, 0004, 0006, 0008, 0010; 0003/0005/0007 diferidos con plazo **antes de fase 3** (preguntas 3, 4 y 7); 0009 se resuelve en el spike de fase 1.
2. **Paso siguiente:** registrar el runner local (`docs/runbooks/ci-local.md`) + primer workflow mínimo.
3. Arrancar la fase 1: scaffold + loop de verificación + walking skeleton nativo.
4. **Antes de fase 2:** definición corta de producto (pantallas y alcance del asistente) — el spec define el *cómo*; el *qué* le toca al dueño.
