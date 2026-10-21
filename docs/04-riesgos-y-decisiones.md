# 04 — Riesgos y decisiones pendientes (ADRs de la fase 0)

## Decisiones que hay que tomar antes de escribir código

| ADR | Decisión | Recomendación | Alternativas | Quién decide |
|---|---|---|---|---|
| **0001** | Stack base y versiones fijadas | Tal como está en `02-spec-v2.md §1` | — | Tech lead |
| **0002** | Política de bots de IA | `robots.txt` + contenido público igual para todos y **sin bypass de auth**. Verificación en el edge solo para rate-limit | Web Bot Auth propio | Tech lead + seguridad |
| **0003** | Backend | TypeScript: route handlers de Next para empezar; servicio separado (Hono o Fastify) si nativo y web necesitan una API estable versionada | FastAPI (solo con dependencia Python obligatoria, con tipos generados desde OpenAPI) | Tech lead |
| **0004** | Orquestación de agentes | AI SDK 7 (`ToolLoopAgent` + `WorkflowAgent`) | Mastra 1.x si hace falta memoria/RAG gestionado o su Studio de evals; LangGraph.js solo con grafos cíclicos complejos | Tech lead + IA |
| **0005** | Autenticación | Better Auth (self-hosted, TS, web + Expo) **o** Clerk (gestionado). Decidir por requisitos de datos y costo | Auth.js, Supabase Auth | Producto + seguridad |
| **0006** | Lint/format | ESLint flat + Prettier (por compatibilidad con plugins de React Compiler y Tailwind) | Biome (más rápido, menos plugins) | Tech lead |
| **0007** | Hosting web | Vercel (menor fricción con Next) **o** self-host con Build Adapters API (estable desde 16.2) | Cloudflare, AWS | Producto + infra |
| **0009** | Tailwind en nativo | Spike en la fase 1: NativeWind 5 rc frente a Uniwind 1.x (ambos Tailwind v4) frente a NativeWind 4 estable (Tailwind v3, con tokens generados desde una fuente única). Se decide por estabilidad y paridad de tokens | — | Tech lead |
| **0008** | i18n y analytics | `next-intl` + catálogo tipado de eventos en `core/analytics.ts` (PostHog o similar) | — | Producto |

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
| R12 | Aprobación de tools falsificada o reutilizada vía historial del cliente | Media | **Alto** | Historial cargado desde la BD, `approvalId` persistido, de un solo uso, ligado al usuario y al hash de argumentos (spec §4) |
| R13 | MCP de navegador usado vía DNS rebinding o con el perfil real del usuario | Media | Alto | stdio, `--isolated`, allowlist de orígenes, versión parcheada (CVE-2025-9611) |
| R14 | Spikes y código experimental que se vuelven producción | Alta | Medio | `experiments/` con caducidad verificada en CI, reimplementación obligatoria (spec §10) |
| R15 | Despliegue sin vuelta atrás (sobre todo nativo) | Media | Alto | Ambientes preview/staging/prod, rollback < 5 min, `runtimeVersion` fingerprint, flags (spec §9) |
| R11 | Dependencia de servicios freemium de terceros (MCPs, SaaS) | Media | Medio | Preferir oficiales y open source; ningún criterio de aceptación depende de un SaaS opcional |

## Preguntas abiertas para el equipo o el cliente

1. ¿Qué tan prioritario es el móvil? ¿Lanzamiento simultáneo o posterior a la web? (Afecta la fase 5 y si el skeleton es suficiente.)
2. ¿Hay contenido privado que deba ser indexable por IA? (Si la respuesta es sí, se necesita un modelo de licenciamiento o API explícito, no un bypass.)
3. ¿Qué proveedores de LLM están permitidos contractualmente y qué datos se les pueden enviar?
4. ¿Hosting: Vercel aceptable o se requiere self-host o nube específica?
5. ¿Existe sistema de diseño en Figma o se parte de shadcn por defecto?
6. ¿Qué agentes de desarrollo usará el equipo (Claude Code, Codex, Cursor)? Afecta la configuración, no la arquitectura.
7. ¿Requisitos regulatorios (LFPDPPP, accesibilidad WCAG 2.2 AA obligatoria, datos de salud o financieros)?
