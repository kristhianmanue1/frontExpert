# 04 — Riesgos y decisiones pendientes (ADRs de la fase 0)

## Decisiones que hay que tomar antes de escribir código

| ADR | Decisión | Recomendación | Alternativas | Quién decide |
|---|---|---|---|---|
| **0001** | Stack base y versiones fijadas | **Decidida (21-oct):** la tabla de `02 §1`, revalidada con `scripts/verify-stack.sh` al abrir cada fase. Ver `adr/0001` | — | Tech lead ✓ (sesión 21-oct) |
| **0002** | Política de bots de IA | `robots.txt` + contenido público igual para todos y **sin bypass de auth**. Verificación en el edge solo para rate-limit | Web Bot Auth propio | Tech lead + seguridad |
| **0003** | Backend | TypeScript: route handlers de Next para empezar; servicio separado (Hono o Fastify) si nativo y web necesitan una API estable versionada. **Nota:** debe resolver la persistencia transaccional que exige el registro de aprobaciones y el historial cargado desde BD (spec §4, riesgo R12) | FastAPI (solo con dependencia Python obligatoria, con tipos generados desde OpenAPI) | Tech lead |
| **0004** | Orquestación de agentes | **Decidida (21-oct):** AI SDK 7 (`ToolLoopAgent` + `WorkflowAgent`); Mastra/LangGraph solo con ADR propio. Ver `adr/0004` | Mastra 1.x si hace falta memoria/RAG gestionado o su Studio de evals; LangGraph.js solo con grafos cíclicos complejos | Tech lead + IA ✓ (sesión 21-oct) |
| **0005** | Autenticación | Better Auth (self-hosted, TS, web + Expo) **o** Clerk (gestionado). Decidir por requisitos de datos y costo | Auth.js, Supabase Auth | Producto + seguridad |
| **0006** | Lint/format | **Decidida (21-oct):** ESLint flat + Prettier; las reglas de `spec-lint` viven como plugins ESLint. Ver `adr/0006` | Biome (solo con ADR si el rendimiento lo exige) | Tech lead ✓ (sesión 21-oct) |
| **0007** | Hosting web | Vercel (menor fricción con Next) **o** self-host con Build Adapters API (estable desde 16.2) | Cloudflare, AWS | Producto + infra |
| **0008** | i18n y analytics | **Decidida (21-oct):** `next-intl` + catálogo tipado (`core/analytics.ts`) con PostHog o similar self-hostable. Ver `adr/0008` | — | Producto ✓ (sesión 21-oct) |
| **0009** | Tailwind en nativo | Spike en la fase 1, **time-box de 2 días**: NativeWind 5 rc frente a Uniwind 1.x (ambos Tailwind v4) frente a NativeWind 4 estable (Tailwind v3). Se decide por estabilidad y paridad de tokens. **Default si expira sin ganador claro:** NativeWind 4 con tokens generados desde `packages/tokens/theme.css` — se preserva la fuente única aunque baje la major de Tailwind en nativo (el time-box genérico ya lo exige §10; aquí queda el default que faltaba) | — | Tech lead |
| **0010** | Infraestructura de CI | **Decidida (21-oct):** GitHub + runner self-hosted local (Docker; jobs de PR contenedorizados y sin secretos). Previews por PR eliminados: staging al merge. Ver `adr/0010` | Forgejo/Gitea interno (self-host total); bare git + hooks (mínimo, sin gates de revisión) | Tech lead ✓ (sesión 21-oct) |

## Registro de riesgos

| # | Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|---|
| R1 | El agente usa APIs de una versión anterior (training data) | Alta | Medio | Docs empaquetadas, `AGENTS.md`, lint de APIs deprecadas, revisión humana |
| R2 | Bypass de autorización vía headers (UA, proxy) | Media | **Alto** | ADR-0002, DAL obligatorio, tests de autorización, parches de seguridad de Next con prioridad |
| R3 | MCP malicioso o comprometido (tool poisoning) | Media | Alto | Allowlist con versiones fijadas, sin auto-approve en escritura, revisión trimestral |
| R4 | WebMCP cambia o no se estandariza | Alta | Bajo | Módulo aislado + feature detection; nada depende de él |
| R5 | `packages/core` se contamina con supuestos de web | Media | Alto | Walking skeleton nativo desde la fase 1 + regla de boundaries en CI |
| R6 | Expo SDK queda atrás y se acumulan upgrades | Media | Medio | Política de 60 días + runbook + Renovate agrupado |
| R7 | Costos de LLM sin control en producción | Media | Alto | Tope por sesión y usuario, telemetría, alertas |
| R8 | Prompt injection en agentes del producto | Alta | Alto | Clasificación de tools, `toolApproval` en write/external con registro de aprobaciones en el servidor (un solo uso, hash de argumentos), contenido de tools tratado como dato, evals adversariales |
| R9 | Cambio de proveedor de LLM rompe comportamiento | Media | Medio | `modelRegistry` + evals por proveedor |
| R10 | TS 7 sin API programática rompe la toolchain | Alta (hoy) | Bajo | Fijar `typescript@~6.0.3` (typescript-eslint exige <6.1). TS 7 (`tsc` nativo) solo para type-check opcional. Revisar cuando typescript-eslint soporte 7 |
| R11 | Dependencia de servicios freemium de terceros (MCPs, SaaS) | Media | Medio | Preferir oficiales y open source; ningún criterio de aceptación depende de un SaaS opcional |
| R12 | Aprobación de tools falsificada o reutilizada vía historial del cliente | Media | **Alto** | Historial cargado desde la BD, `approvalId` persistido, de un solo uso, ligado al usuario y al hash de argumentos (spec §4) |
| R13 | MCP de navegador usado vía DNS rebinding o con el perfil real del usuario | Media | Alto | stdio, `--isolated`, allowlist de orígenes, versión parcheada (CVE-2025-9611) |
| R14 | Spikes y código experimental que se vuelven producción | Alta | Medio | `experiments/` con caducidad verificada en CI, reimplementación obligatoria (spec §10) |
| R15 | Despliegue sin vuelta atrás (sobre todo nativo) | Media | Alto | Ambientes staging/prod (previews por PR recortados, ADR-0010), rollback < 5 min, `runtimeVersion` fingerprint, flags (spec §9) |
| R16 | Código de un PR de agente corre en CI/preview y exfiltra credenciales | Media | Alto | Jobs de PR en contenedor efímero sin secretos (environment `sandbox`), secretos de staging/prod solo por merge a `main`, test de environment en CI (spec §9, ADR-0010) |

## Preguntas abiertas para el equipo o el cliente

1. ¿Qué tan prioritario es el móvil? ¿Lanzamiento simultáneo o posterior a la web? (Afecta la fase 5 y si el skeleton es suficiente.)
2. ¿Hay contenido privado que deba ser indexable por IA? (Si la respuesta es sí, se necesita un modelo de licenciamiento o API explícito, no un bypass.)
3. ¿Qué proveedores de LLM están permitidos contractualmente y qué datos se les pueden enviar?
4. ¿Hosting: Vercel aceptable o se requiere self-host o nube específica?
5. ¿Existe sistema de diseño en Figma o se parte de shadcn por defecto?
6. ¿Qué agentes de desarrollo usará el equipo (Claude Code, Codex, Cursor)? Afecta la configuración, no la arquitectura.
7. ¿Requisitos regulatorios (LFPDPPP, accesibilidad WCAG 2.2 AA obligatoria, datos de salud o financieros)?
8. **¿GitHub Pro (~USD 4/mes), org con plan, o control procedural hasta fase 1?** La protección de `main` (PR + 1 revisión, sin force-push) está paywalleada en repos privados del plan Free (403 verificado, ADR-0010). El repo vive mientras tanto en `kristhianmanue1/frontExpert` (privado); cuando exista la org, `gh repo transfer` lo mueve completo. **Diferida (21-oct, orden del dueño):** control procedural mientras tanto; nada del plan depende de esta respuesta.
