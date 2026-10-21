# 01 — Análisis crítico del spec recibido

**Fecha de verificación:** 2026-10-17. Las versiones y el estado de cada estándar se revisaron contra fuentes primarias o reportes recientes (ver `docs/FUENTES.md`). Hay que volver a verificarlas al iniciar cada fase.

**Escala:** ✅ se sostiene · ⚠️ válido, pero hay que corregirlo o acotarlo · ❌ incorrecto o riesgoso: cambiarlo antes de ejecutar.

---

## Veredicto general

La **dirección es correcta**: React con TypeScript, monorepo, código de UI propio (shadcn), tokens, Zod en las fronteras, AI SDK para los agentes del producto, Expo para móvil y fases incrementales con commits pequeños. Es la apuesta más conservadora y mantenible disponible hoy para un equipo que trabaja con agentes de IA.

Aun así, el documento **no está listo para entregárselo tal cual a un agente**:

1. Tiene **un fallo de seguridad de diseño**: saltarse la autenticación según el User-Agent.
2. Tiene **versiones y APIs desfasadas o mal atribuidas**. Un agente las seguiría al pie de la letra.
3. Usa **cifras sin respaldo** ("27× menos tokens") y **criterios de aceptación que no se pueden verificar**.
4. Le faltan piezas que un proyecto mantenible necesita: **estrategia de pruebas, CI, autenticación, observabilidad, política de actualización de dependencias, i18n y evals de los agentes del producto**.
5. Introduce **contradicciones internas**: dice "solo TypeScript" pero propone FastAPI; dice "tres paquetes" pero lista cuatro; justifica una regla de React con "el modelo de compilación Svelte-like".
6. Pone el **loop de verificación (Playwright) en la fase 4**, cuando debería existir desde la fase 1. Con agentes, primero se construye la verificación.

---

## 1. Stack base, punto por punto

| # | Afirmación del spec | Veredicto | Evidencia (oct-2026) | Propuesta |
|---|---|---|---|---|
| 1.1 | TypeScript estricto en todo el monorepo | ✅ | TS 7.0 (compilador nativo en Go) es GA desde el 8-jul-2026, pero **no tiene API programática estable** hasta 7.1, así que typescript-eslint y ts-morph no funcionan sobre él. | `strict` + `noUncheckedIndexedAccess`. Usar **TS 6.0.x para lint y herramientas** (typescript-eslint exige <6.1) y TS 7 solo para type-check rápido. *(Corregido en `06`: el binario de TS 7 es `tsc`, no `tsgo`.)* |
| 1.2 | "React 19.2 … View Transitions disponibles" | ⚠️ | 19.2 (oct-2025) trajo `<Activity>` y `useEffectEvent`. `<ViewTransition>` quedó **estable en React 19.3 (9-sep-2026)**; en 19.2 era canary. React Compiler 1.0 es estable desde el 7-oct-2025. | Fijar **React 19.3.x**. Compiler activo con `eslint-plugin-react-hooks` (reglas del compiler). |
| 1.3 | "Next.js 16 … Middleware" | ⚠️ | En Next 16 `middleware.ts` **pasó a llamarse `proxy.ts`**. La versión actual es **16.4** (6-oct-2026; *corregido en `06`*). Hubo un **CVE-2026-64642 de bypass de proxy/middleware** con Turbopack + i18n (corregido en 16.2.11). | Fijar `next@16.4.x`. Usar `proxy.ts` y **nunca** basar la autorización solo en el proxy (ver 1.4). |
| 1.4 | Bots de IA "verificados" por User-Agent "reciben contenido limpio **sin pasar por auth de sesión**" | ❌ **Crítico** | El User-Agent se falsifica sin esfuerzo: cualquiera envía `ClaudeBot` y entra. Verificar de verdad exige rDNS o rangos de IP publicados, o **Web Bot Auth (RFC 9421, firmas HTTP)**. Servir contenido distinto según el UA también puede contar como **cloaking** según las políticas de Google. | Regla nueva: **lo público es público para todos y lo privado nunca se sirve a bots.** No existe un bypass de auth. Si se quiere tratar distinto a los bots (rate-limit, analytics, bloqueo), se verifica en el edge (Vercel BotID, Cloudflare Verified Bots o Web Bot Auth) y **nunca** se usa para autorizar. |
| 1.5 | Lista de UAs: `Claude-Web`, `claude-user`, `Google-Extended` | ❌ | `Claude-Web` y `anthropic-ai` están **deprecados**. Los vigentes de Anthropic son `ClaudeBot`, `Claude-User` y `Claude-SearchBot`. **`Google-Extended` no es un User-Agent**: es un token de `robots.txt`, nunca llega en una petición. | Mover el control de bots a **`robots.txt`**, que es lo que estos crawlers respetan, con una lista mantenida en `packages/config/ai-bots.ts` y revisada cada trimestre. |
| 1.6 | Tailwind con tokens como CSS variables, sin CSS-in-JS | ✅ | Tailwind **v4.3** usa configuración CSS-first con `@theme`. ~~NativeWind v5 estable~~ **Corregido en `06`: NativeWind v5 sigue en RC**; `latest` es 4.2.7 (Tailwind v3). Ver ADR-0009. | Crear `packages/tokens` con un `theme.css` (`@theme`) que consuman web y nativo. Es la pieza que hace realidad "mismos tokens". |
| 1.7 | shadcn copiado en `packages/ui` | ✅ | El CLI de shadcn soporta monorepos y resuelve rutas e imports. | Mantenerlo. Registrar en `packages/ui/UPSTREAM.md` la versión y el commit del registry de cada componente, para poder hacer diffs contra upstream. |
| 1.8 | Vercel AI SDK "6 o superior", ToolLoopAgent, `createAgentUIStreamResponse`, `needsApproval` | ⚠️ | Las APIs existen (v6, dic-2025). **La versión actual es v7**, que agrega `WorkflowAgent` (agentes durables), telemetría renovada y contexto tipado en las tools. | Fijar **AI SDK 7**. Antes de añadir Mastra, evaluar si `WorkflowAgent` cubre la durabilidad (ADR-0004). **Actualización:** `needsApproval` está deprecado y su reemplazo es `toolApproval`, y la aprobación debe validarse contra un registro del servidor (ver `05-evaluacion-ronda-adversarial.md`). |
| 1.9 | "Provider-agnostic, intercambiables en una línea" | ⚠️ | El cambio es de una línea **en el código**, pero el comportamiento cambia: tool-calling, structured outputs, razonamiento, límites y costos. | Envolverlo en un `modelRegistry` en `packages/ai` y exigir **evals que pasen por proveedor** antes de cambiarlo. |
| 1.10 | Mastra para agentes, memoria, RAG y workflows | ✅/⚠️ | Mastra 1.0 es estable (21-ene-2026, Apache-2.0). Se solapa en parte con AI SDK 7 `WorkflowAgent`. | Usarlo solo si hace falta memoria y RAG gestionados o el Studio de evals. No meter dos frameworks de orquestación sin un ADR. |
| 1.11 | LangGraph.js / OpenAI Agents SDK / CopilotKit | ⚠️ | Son opciones razonables, pero el spec enumera **cinco frameworks de agentes**. Para un agente que lee el spec, eso es ambigüedad. | Dejar uno por defecto (AI SDK) y que cualquier otro requiera un ADR. Sacar CopilotKit del núcleo. |
| 1.12 | Monorepo Turborepo, "tres paquetes" | ⚠️ | Lista cuatro (web, ui, core, native). Faltan `tokens`, `config` (tsconfig, eslint) y `ai`. No define gestor de paquetes. | **pnpm** con workspaces + Turborepo. Estructura en `docs/02-spec-v2.md`. |
| 1.13 | Expo + New Architecture | ✅ | Expo SDK 55 eliminó la Legacy Architecture. **Actual: SDK 58 (29-sep-2026), RN 0.88** *(corregido en `06`)*. SDK 56 dejó estable Expo UI (SwiftUI/Compose) y Router sin React Navigation. | Fijar SDK 58. |
| 1.14 | "Expo Router con file-based routing **idéntico** al web" | ❌ | Next App Router y Expo Router **no son idénticos**: RSC, `route.ts`, `proxy`, server actions y metadata no existen igual en Expo, y la navegación nativa (stacks, tabs, modales) no tiene equivalente directo en web. | Compartir un **mapa de rutas tipado** (`packages/core/routes.ts`) con nombres y parámetros. Cada app lo implementa a su manera. La paridad se mide sobre ese mapa. |
| 1.15 | NativeWind para Tailwind en nativo | ✅ | v5 estable, requiere `react-native-css`, no aplica a Next.js (no hace falta allí). | Validar en la fase 1 con una pantalla que consuma `packages/tokens`. |
| 1.16 | Compartir solo la capa no visual | ✅ | Es una buena decisión: evita que los compromisos de react-native-web degraden la web, que es la superficie SEO y agent-ready. | Compartir también **hooks headless** (lógica de formularios y de chat) y **tokens**. |

## 2. Loop de desarrollo con MCP

| # | Spec | Veredicto | Evidencia | Propuesta |
|---|---|---|---|---|
| 2.1 | **DesignRevision** MCP para shadcn | ⚠️ | Es un servicio **de terceros**, con token, y su modelo freemium puede cambiar. **shadcn tiene MCP oficial** (`shadcn mcp init`), que incluye registries múltiples. | Usar el **MCP oficial de shadcn**. DesignRevision queda como opcional y no como criterio de aceptación. |
| 2.2 | Context7 para documentación | ⚠️ | Desde 16.2, **Next.js empaqueta su documentación en `node_modules/next/dist/docs`** con un `AGENTS.md` que apunta a ella. En las evals oficiales (nextjs.org/evals) eso sube el éxito de los agentes de forma drástica (p. ej. un modelo pasa de 71 % a 100 %). Es documentación **de la versión exacta instalada**. | Prioridad: **1) documentación empaquetada con la versión, 2) `next-devtools-mcp` y el MCP de Expo, 3) Context7 como respaldo.** |
| 2.3 | Playwright MCP | ✅ | | Además del MCP para explorar, que existan **tests de Playwright como código en CI**. El MCP no sustituye la suite. |
| 2.4 | Chrome DevTools MCP | ✅ | Se solapa en parte con Playwright. | Playwright para pruebas y DevTools para depurar rendimiento, red y consola. |
| 2.5 | Figma MCP | ✅ | | Solo si hay diseño en Figma. Configurar Code Connect para mapearlo a `packages/ui`. |
| 2.6 | GitHub MCP | ✅/⚠️ | Hubo ataques reales de **prompt injection mediante issues** contra el MCP de GitHub (2025). | Darle un token con **scopes mínimos**. El agente no hace merge. |
| 2.7 | Filesystem MCP | ❌ (redundante) | Claude Code, Codex y Cursor ya tienen acceso nativo al sistema de archivos con permisos propios. Añadirlo **duplica superficie de ataque y contexto**. | Eliminarlo. |
| 2.8 | Sequential Thinking | ❌ (redundante) | Los modelos actuales razonan de forma nativa, y el servidor consume contexto. | Eliminarlo. Para planificar, usar el modo plan del harness y documentos de diseño en `docs/`. |
| 2.9 | Falta: **MCP oficial de Expo** | ➕ | Da docs de Expo, logs de EAS Build y, en local (SDK 54+), screenshots e interacción con el simulador. Disponible en plan Free desde may-2026. | Agregarlo en la fase 5, o en la 1 si el móvil arranca temprano. |
| 2.10 | Falta: **gobernanza de MCP** | ➕ | Más de 30 CVEs en servidores MCP en ene–feb 2026. Tool poisoning con 84 % de éxito cuando hay auto-aprobación. | Allowlist de servidores con **versión fijada**, separar lectura de escritura, sin auto-approve en tools que escriben y una revisión trimestral. Ver `docs/03-loop-agentes.md`. |

## 3. Agent-ready del sitio

| # | Spec | Veredicto | Evidencia | Propuesta |
|---|---|---|---|---|
| 3.1 | `llms.txt` | ⚠️ (bajo impacto) | Estudios de 2026: el **97 % de los `llms.txt` recibe cero peticiones**. GPTBot leyó `llms.txt` 7 veces frente a 3 990 lecturas de `robots.txt` en 12 semanas, y no se encontró correlación con las citas. | Mantenerlo porque cuesta casi nada, pero como **tarea de 30 minutos** y no como pilar ni como criterio de calidad. |
| 3.2 | HTML semántico desde el primer request | ✅ **Lo más valioso** | Es lo que los crawlers sí consumen. También mejora la accesibilidad. | Volverlo un criterio duro: contenido principal visible con JS deshabilitado, verificado en CI. Añadir datos estructurados (JSON-LD de schema.org). |
| 3.3 | WebMCP en `document.modelContext` | ⚠️ Experimental | La API **sí se movió a `document.modelContext`** (borrador de jul-2026; `navigator.modelContext` está deprecado desde Chrome 150). Sigue siendo **borrador de Community Group del W3C**, con origin trial en Chrome 149–156. | Implementarla detrás de feature detection, como mejora progresiva y aislada en un módulo. Ningún criterio de aceptación debe depender de que "un agente externo la descubra". |
| 3.4 | "27 veces menos tokens" | ❌ Sin fuente | No hay evidencia del 27×. La cifra que circula es **~89 %** (unas 9×) frente a agentes que usan screenshots, y salió de un cálculo teórico. Mediciones independientes dan **~68 %**. | Quitar la cifra. Si hace falta justificar WebMCP, medirlo con un benchmark propio en la fase 6. |

## 4. Seguridad

| Spec | Veredicto | Propuesta |
|---|---|---|
| Credenciales de MCP solo en env o secret manager | ✅ | Añadir **gitleaks o secretlint en pre-commit y CI**, más secret scanning del repositorio. |
| BD en solo lectura | ✅ | Usar un rol de BD de solo lectura **a nivel motor**, no solo de configuración. |
| **Falta:** seguridad de los agentes *del producto* | ➕ | Prompt injection por contenido de usuario o de tools, límites de costo por usuario, rate limiting, registro de cada tool call, aprobación (`toolApproval`, validada en el servidor) también en tools que **exfiltran** (envían datos fuera) y no solo en las que mutan. |
| **Falta:** privacidad | ➕ | Si hay usuarios en México: LFPDPPP (ley vigente desde mar-2025), aviso de privacidad y política de qué datos se mandan a cada proveedor de LLM. |
| **Falta:** cadena de suministro | ➕ | Lockfile obligatorio, `pnpm` con `minimumReleaseAge` para paquetes recién publicados, Renovate con agrupación y CI que verifique integridad. |

## 5. Criterio de elección de framework

> "Se elige por volumen de datos de entrenamiento y estabilidad de convenciones. React gana."

⚠️ **La conclusión es correcta, pero el argumento principal es débil.**

- **Lo que más pesa en la precisión del agente no es el volumen de entrenamiento, sino la documentación de la versión exacta en contexto.** Las evals de Next.js lo muestran: los mismos modelos mejoran mucho cuando leen la documentación empaquetada en lugar de depender de lo que aprendieron. Los datos de entrenamiento incluso juegan en contra en los cambios recientes (`middleware`→`proxy`, App Router frente a Pages): el agente "recuerda" la versión vieja.
- **El argumento fuerte para React es otro: es el único ecosistema que cubre web y nativo (React Native/Expo) con el mismo lenguaje, el mismo modelo mental y paquetes compartidos.** Svelte no tiene un equivalente maduro para iOS y Android, así que con Svelte la apuesta móvil se cae.
- Sobre Svelte: el MCP oficial existe y es buena idea, pero no cambia la decisión mientras el móvil sea requisito.

## 6. Fases

| Problema | Propuesta |
|---|---|
| Playwright, CI y tests llegan en la **fase 4** | El loop de verificación va en la **fase 0/1**. Sin una forma automática de verificar, el agente no puede cerrar tareas solo. |
| El móvil llega en la **fase 5** | Hay riesgo de que `packages/core` acumule supuestos de web (`window`, `FormData`, APIs de Next) y luego "sin modificaciones" sea imposible. Proponemos un **walking skeleton de `apps/native` desde la fase 1** (una pantalla con tokens y un tipo de core) y que CI compile ambas apps desde el día uno. |
| Fase 3: "Next.js API routes **o FastAPI**" | Contradice "solo TypeScript" y duplica tipos y validación. Default: **TypeScript end-to-end**. FastAPI solo con un ADR que lo justifique (p. ej. una librería de ML que solo existe en Python), y en ese caso se generan los tipos desde OpenAPI. |
| Faltan autenticación, i18n y analytics | Se agregan como decisiones tempranas (ADR), porque migrarlas después es caro. |
| La fase 6 mezcla "auditoría de accesibilidad y performance" con cosas experimentales | Accesibilidad y performance son **transversales con presupuesto en CI desde la fase 1**. La fase 6 queda solo para lo agent-ready experimental. |

## 7. Anti-patrones: revisión

| Anti-patrón | Veredicto | Ajuste |
|---|---|---|
| No inventar componentes si shadcn ya los tiene | ✅ | Cambiar "DesignRevision" por "CLI o MCP oficial de shadcn". |
| No CSS-in-JS en runtime | ✅ en la regla, ❌ en el argumento | "Rompe el modelo de compilación **Svelte-like**" no tiene sentido en un proyecto React. El argumento correcto: incompatibilidad o costo con RSC y streaming, peso de runtime y CSS no predecible. |
| No hardcodear tokens | ✅ | Hacerlo cumplir con lint: `eslint-plugin-tailwindcss` o una regla propia que prohíba valores arbitrarios (`bg-[#...]`, `p-[13px]`) fuera de `packages/tokens`. |
| "No meter `useState` en un Server Component" | ⚠️ | Eso ya es un error de compilación. La regla útil es otra: **los límites `'use client'` van en las hojas** del árbol, y el fetching se hace en el servidor. |
| "Si usa TanStack Query…" | ⚠️ | El spec nunca decide si usa TanStack Query. Decisión propuesta: **web = RSC + server actions; nativo = TanStack Query**. Los *fetchers* y las *query keys* viven en `packages/core`. |
| Validar todo con Zod | ✅ | Usar Zod 4 y aclarar que también aplica a las **variables de entorno** (`@t3-oss/env-nextjs` o un schema propio). |
| No commitear secretos | ✅ | Hacerlo automático (gitleaks) en lugar de confiar en la disciplina. |
| Diff mínimo | ✅ | Bien, pero "50 líneas para cambiar una" no es medible. Usar el **tamaño del PR como señal en CI** (advertencia por encima de ~400 líneas). |
| Errores de hidratación como bloqueantes | ✅ | Que Playwright falle si aparece `Hydration failed` en consola. |
| No hacer scope creep | ✅ | Excelente. Proponer un `docs/ideas.md` como destino formal de las ideas. |
| "No magia implícita; preferir props a contextos" | ⚠️ | Llevado al extremo genera prop drilling. Ajuste: **se permiten providers, pero solo los declarados en un único `app/providers.tsx` y documentados.** Nada de contextos creados ad hoc en componentes de feature. |
| **Faltan** | ➕ | No usar `any` ni `as` para silenciar tipos. No desactivar reglas de lint sin comentario y justificación. No añadir dependencias sin justificarlas en el PR. No escribir tests que solo prueben mocks. No bajar umbrales de CI para que un PR pase. |

## 8. Criterios de aceptación: revisión

| Criterio original | Problema | Reemplazo verificable |
|---|---|---|
| "3 componentes instalados vía DesignRevision" | Mide la herramienta usada, no el resultado. | 3 componentes en `packages/ui`, registrados en `UPSTREAM.md`, con historia o test visual. |
| "HTML semántico verificable con un validador" | ¿Qué validador? | `html-validate` + **axe-core sin violaciones serias o críticas** + test con JS deshabilitado que encuentra el `<h1>` y el contenido principal. |
| "Diff ≤ 20 líneas fuera de su archivo" | Arbitrario y fácil de manipular. | Advertencia por tamaño de PR y regla de dependencias entre paquetes (`dependency-cruiser` o boundaries de Turborepo). |
| "Primer chunk < 1 s" | Depende del proveedor, el modelo y la región. | **TTFB del stream propio (excluyendo al modelo) < 200 ms p95** + time-to-first-token del modelo registrado en telemetría con un umbral por modelo. |
| "Sin re-renders innecesarios, medible con React DevTools" | Manual, no automatizable. | React Compiler activo sin bailouts en `packages/ui` y `features/chat` (reporte del compiler) + un test de rendimiento con React Profiler o *react-scan* en CI. |
| "Mastra persiste un workflow entre reinicios" | Bien, pero acoplado a Mastra. | "El workflow de 2 pasos se reanuda tras matar el proceso", sin importar el motor (Mastra o `WorkflowAgent`). |
| "Expo Router replica la estructura de rutas" | Imposible en sentido literal (ver 1.14). | Cobertura del mapa de rutas compartido: cada ruta marcada `mobile: true` existe en nativo. |
| "Lighthouse a11y > 90, perf > 80" | Lighthouse de laboratorio es volátil, y 80 es bajo. | **Core Web Vitals:** LCP < 2.5 s, INP < 200 ms, CLS < 0.1 (Lighthouse CI, mediana de 3 corridas) + axe sin violaciones serias. |
| "Un agente externo descubre y ejecuta la tool WebMCP" | Depende de un navegador en origin trial. | Test de Playwright en Chrome con el flag activo: la tool se registra, aparece en la lista y su ejecución valida contra el schema. |
| "Responde a un agente de búsqueda con citas correctas" | No es controlable ni reproducible. | Eliminarlo como criterio. Se monitorea como métrica de negocio. |

---

## Conclusión

**Se recomienda adoptar el spec con las correcciones de `docs/02-spec-v2.md`.** Las tres que bloquean el inicio son:

1. **Eliminar el bypass de autenticación por User-Agent** (1.4 y 1.5).
2. **Fijar versiones reales** y apuntar al agente a la documentación de la versión instalada (1.2, 1.3, 1.8, 1.13 y 2.2).
3. **Mover la verificación automática (tests, CI, presupuestos) a la fase 1** y arrancar el walking skeleton móvil temprano (sección 6).
