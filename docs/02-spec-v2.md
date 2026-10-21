# 02 — SPEC v2 · Frontend + Mobile Agent-Ready (propuesta)

> **Estado:** borrador para consenso · **Base:** spec recibido + `01-analisis-critico.md` · **Versiones verificadas:** 2026-10-17
> **Alcance (ADR-0012):** este spec lo ejecuta cada proyecto adoptante en su propio repositorio; frontExpert no construye producto.
> Este documento es el que se le entrega al agente. Es normativo: "DEBE", "NO DEBE" y "PUEDE" tienen el sentido de RFC 2119.

---

## 0. Principios (en orden de prioridad)

1. **Verificable antes que rápido.** Ninguna tarea se cierra sin una verificación automática que el agente pueda ejecutar.
2. **Documentación de la versión instalada antes que memoria del modelo.** El agente lee la documentación empaquetada con la versión exacta antes de escribir código de framework.
3. **Un camino por defecto por cada problema.** Si existe una alternativa, solo se usa con un ADR aprobado.
4. **Lo compartido es no visual.** Web y nativo comparten tipos, schemas, cliente de API, lógica headless, tokens y mapa de rutas. No comparten componentes visuales.
5. **Seguro por defecto.** No hay rutas de autorización alternativas, las tools que escriben requieren aprobación humana y los secretos nunca se versionan.
6. **Actualizable.** Versiones fijadas, actualización automática agrupada y un runbook de upgrade que el agente puede ejecutar.

## 1. Stack fijado

| Capa | Elección | Versión objetivo | Notas |
|---|---|---|---|
| Runtime | Node.js LTS | 24.x | `.nvmrc` + `engines` |
| Gestor de paquetes | **pnpm** | 12.x (verificado: 12.14.0) | `minimumReleaseAge` ≥ 1 día para frenar paquetes recién publicados |
| Monorepo | **Turborepo** | 2.x | Caché remoto en CI |
| Lenguaje | TypeScript `strict` | **6.0.x** fijado (lint y herramientas) + 7.0.x opcional solo para type-check rápido | Verificado: `typescript-eslint` exige `typescript >=4.8.4 <6.1.0`. En TS 7 la API solo existe bajo `typescript/unstable/*` y el binario se llama `tsc` (no `tsgo`). **Ojo:** `npm i typescript` ya instala 7.x, así que hay que fijar `typescript@~6.0.3`. |
| UI | React | **19.3.x** | Compiler 1.0 activo · `<ViewTransition>` y `<Activity>` estables |
| Web | Next.js App Router + Turbopack | **16.4.x** (16.4.0 del 6-oct-2026) | `proxy.ts` (antes middleware). Docs empaquetadas y `AGENTS.md` gestionado desde 16.3 |
| Estilos | Tailwind CSS (CSS-first, `@theme`) | **4.3.x** | Sin CSS-in-JS en runtime |
| Componentes web | shadcn/ui (código propio) | CLI `latest` al instalar | Se registra el origen en `UPSTREAM.md` |
| Validación | **Zod** | 4.x | Inputs, outputs de tools, responses y **env vars** |
| IA en producto | **Vercel AI SDK** | **7.x** | `ToolLoopAgent`, `WorkflowAgent`, `toolApproval` (`needsApproval` está deprecado) |
| Orquestación extra | Mastra | 1.x | **Solo con ADR-0004** (memoria/RAG gestionado) |
| Móvil | **Expo** (New Architecture) | **SDK 58** (29-sep-2026: RN 0.88.0, React 19.3.0, expo-router 58) | |
| Navegación móvil | Expo Router | según SDK | |
| Estilos móvil | NativeWind **o** Uniwind | **Decisión abierta (ADR-0009)** | Verificado: NativeWind v5 **no es estable** (solo `5.0.0-rc.0`, 13-sep-2026); `latest` es 4.2.7, de la línea Tailwind v3. Uniwind 1.12 soporta Tailwind ≥4. Se resuelve con un spike en la fase 1 |
| Datos móvil | TanStack Query | 5.x | Fetchers y query keys en `packages/core` |
| Build móvil | EAS Build + **EAS Update** (OTA) | | Canales `preview` y `production` |
| Tests unit/integración | Vitest | **5.x** (5.0.5, verificado 21-oct) | |
| Tests e2e web | Playwright (código en CI + MCP para exploración) | | |
| Tests e2e móvil | **Maestro** | | Flujos YAML, fáciles de escribir para un agente |
| Lint/format | ESLint (flat) + Prettier | ESLint **10.x** (10.13.0, verificado 21-oct) | ADR-0006 aceptado (21-oct); Biome solo con ADR futuro por rendimiento |
| Observabilidad | OpenTelemetry + Sentry (web y nativo) | | Telemetría del AI SDK activa |
| Actualizaciones | **Renovate** | | Agrupado por ecosistema (ver §8) |

> Las versiones se revalidan al inicio de cada fase. Si cambia una mayor, se abre un ADR.

## 2. Estructura del monorepo

```
.
├── AGENTS.md                 # Punto de entrada para cualquier agente (ver plantillas/)
├── CLAUDE.md                 # → importa AGENTS.md (y nada más)
├── apps/
│   ├── web/                  # Next.js 16 App Router
│   │   ├── app/
│   │   │   ├── providers.tsx # ÚNICO lugar para providers globales
│   │   │   ├── robots.ts     # Política de crawlers (desde packages/config)
│   │   │   ├── sitemap.ts
│   │   │   └── llms.txt/route.ts
│   │   ├── proxy.ts          # Solo headers, i18n y redirects. NO autorización.
│   │   └── e2e/              # Playwright
│   └── native/               # Expo SDK 58 + Expo Router
│       ├── src/app/
│       └── .maestro/         # Flujos e2e
├── packages/
│   ├── core/                 # Plataforma-agnóstico: sin DOM, sin RN, sin Next
│   │   ├── domain/           # Tipos y modelos de dominio
│   │   ├── schemas/          # Zod
│   │   ├── api/              # Cliente tipado (fetch puro) + query keys
│   │   ├── routes.ts         # Mapa de rutas compartido (nombre, params, web/mobile)
│   │   └── analytics.ts      # Catálogo tipado de eventos
│   ├── tokens/               # theme.css (@theme) + tokens.ts exportados
│   ├── ui/                   # shadcn (solo web) + UPSTREAM.md
│   ├── ui-native/            # Componentes nativos propios (se crea en la fase 5)
│   ├── ai/                   # modelRegistry, definiciones de tools, prompts versionados, evals
│   ├── config/               # tsconfig, eslint, ai-bots.ts, public-routes.ts, env schema
│   └── spec-lint/            # El spec ejecutable: reglas deterministas (§11)
├── experiments/              # Spikes con caducidad, fuera del build (§10)
├── docs/
│   ├── adr/                  # Decisiones (plantilla: plantillas/adr.md, formato MADR corto)
│   ├── handoff.md            # Estado entre sesiones (se reescribe al cerrar cada una, ver 03 §6)
│   ├── ideas.md              # Destino del scope creep
│   ├── spikes/               # Notas de salida de los spikes (§10)
│   └── runbooks/             # upgrade-next.md, upgrade-expo.md, release-mobile.md, rollback.md
└── .github/workflows/
```

**Reglas de dependencia, verificadas en CI con boundaries de Turborepo o `dependency-cruiser`:**

- `core` no importa nada del monorepo ni nada de `react-dom`, `react-native` o `next`.
- `ui` y `ui-native` importan `tokens` y `core`, nunca uno al otro.
- `apps/*` importan `packages/*`. Ningún paquete importa de `apps/*`.
- `ai` se usa solo en servidor (`server-only`).

## 3. Arquitectura de datos (un patrón por capa)

| Capa | Web | Nativo |
|---|---|---|
| Lectura | React Server Components llaman a `core/api` desde el servidor | TanStack Query con fetchers de `core/api` |
| Escritura | Server Actions + `useActionState`, con validación del mismo schema Zod | `useMutation` + el mismo schema Zod |
| Autorización | **Data Access Layer** en servidor (en cada acción y cada lectura), nunca solo en `proxy.ts` | El token se valida en el backend |
| Estado UI | Local (`useState`) o URL (search params) | Local |
| Estado global | Solo lo declarado en `providers.tsx` | Solo lo declarado en el root layout |

## 4. Agentes dentro del producto

- **Default:** AI SDK 7. `ToolLoopAgent` para chat con tools y `WorkflowAgent` para flujos durables.
- Las **tools** se definen en `packages/ai/tools/*` y cada una tiene: schema Zod de entrada y de salida, clasificación (`read` | `write` | `external`) y un test.
- **Aprobación humana:** se configura con **`toolApproval`** en `ToolLoopAgent`, `streamText` o `generateText`. `needsApproval` en `tool()` está **deprecado** en la documentación vigente, así que no se usa en código nuevo. Una función central `approvalPolicy(tool, ctx)`, en `packages/ai`, devuelve `'user-approval'` para toda tool `write` o `external`. Lo verifica un test que recorre el registro de tools.
- **Aprobación con autoridad del servidor.** El SDK recibe la `tool-approval-response` en el historial que manda el cliente, y ese historial **no es confiable**:
  1. El historial de la conversación se **carga desde la BD del servidor** y no del body del request. Del cliente solo se acepta el mensaje nuevo o la respuesta de aprobación.
  2. Cada `tool-approval-request` se **persiste** con `approvalId`, `toolCallId`, `userId`, nombre de la tool, **hash de los argumentos** y expiración (≤ 10 min).
  3. Una aprobación solo vale si el `approvalId` existe y está pendiente, si pertenece al usuario de la sesión, si no expiró y si el hash de los argumentos coincide. Es **de un solo uso** (se marca consumida en una transacción).
  4. Al ejecutarse, la tool **vuelve a autorizar** contra el Data Access Layer. La aprobación no reemplaza a los permisos.
  5. Si el request de aprobación cambia algo de estado, exige protección CSRF y la sesión válida.
  6. **Se activa `experimental_toolApprovalSecret`** (verificado en el código de `ai@7.0.143`): el SDK firma con HMAC-SHA256 cada solicitud sobre `approvalId`, `toolCallId`, `toolName` y el digest de los argumentos, y rechaza con `InvalidToolApprovalSignatureError` las aprobaciones sin firma o alteradas. **No cubre** usuario, expiración ni un solo uso, así que el registro de los pasos 2–3 sigue siendo obligatorio. Es una API `experimental_`: se revisa en cada upgrade.
- **Prompts versionados** en archivos (`packages/ai/prompts/*.md`) y no como strings sueltos.
- **Evals** (`packages/ai/evals`) con casos dorados y **casos adversariales** (prompt injection en contenido de tools). Corren en CI para los cambios en `packages/ai` y son requisito para cambiar de modelo o proveedor.
- **Controles:** rate limit por usuario, tope de pasos por loop, tope de costo por sesión, registro de cada tool call (sin PII) y defensa contra prompt injection (el contenido de tools y usuarios nunca se interpreta como instrucciones del sistema; las tools `external` siempre piden aprobación).
- **Métricas por request (obligatorias):** `requestId`, `userId` (seudonimizado), modelo, proveedor, tokens de entrada, salida y caché, **costo estimado en USD**, pasos del loop, tools llamadas, latencia (TTFB/TTFT/total) y resultado. Se emiten como atributos de OpenTelemetry (la telemetría del AI SDK más atributos propios). Hay un dashboard de costo por día, ruta y usuario, con alerta al superar el presupuesto.

## 5. Superficie pública agent-ready

| Elemento | Prioridad | Regla |
|---|---|---|
| **HTML semántico SSR/SSG** | Alta | El contenido principal se ve con JS deshabilitado (test en CI) |
| **Datos estructurados JSON-LD** | Alta | schema.org según el tipo de página |
| `robots.ts` + `sitemap.ts` | Alta | La política de bots sale de `packages/config/ai-bots.ts` |
| `llms.txt` | Baja | Se genera **solo desde un allowlist explícito de rutas públicas** (`packages/config/public-routes.ts`) y no recorriendo rutas ni el CMS. Un test falla si incluye `/admin`, `/api`, rutas con auth o borradores. Sin expectativa de impacto. |
| **WebMCP** (`document.modelContext`) | Experimental | Ver reglas abajo |
| Tratamiento diferenciado de bots | Opcional | Solo para rate-limit y analytics, con verificación criptográfica o de red (Web Bot Auth o la verificación del edge). **Nunca para autorizar.** |

**Reglas de WebMCP.** Sus tools se ejecutan en la página **con la sesión del usuario**, así que el riesgo es un agente manipulado actuando en su nombre (*confused deputy*):

- Feature detection y un módulo aislado `apps/web/lib/webmcp/`. Nada del producto depende de él.
- Se empieza **solo con tools de lectura**, con `readOnlyHint: true`.
- Toda tool que cambie estado lleva `consequentialHint: true` **y** una confirmación del usuario dentro de la propia UI de la página (`requestUserInteraction()` figura en el borrador del spec, pero no está garantizado en Chrome; no se depende de él). Además pasa por la misma API del servidor, con autorización en el DAL, rate limit y CSRF. **WebMCP nunca es un camino privilegiado.**
- La salida con contenido de usuarios o de terceros lleva `untrustedContentHint`.
- `exposedTo` se restringe a orígenes confiables (por defecto, el propio).
- Se respetan los límites de Chrome (verificados): nombre de tool y de parámetro ≤ 30 caracteres, descripción ≤ 500, descripción de parámetro ≤ 150 y salida ≤ 1.5K. Un test lo verifica.
- El rate limiting vive en el backend y aplica igual a llamadas desde WebMCP, la UI o la API.

**Lista vigente de tokens de crawlers de IA** (para `robots.txt`, revisión trimestral): `GPTBot`, `OAI-SearchBot`, `ChatGPT-User`, `ClaudeBot`, `Claude-User`, `Claude-SearchBot`, `PerplexityBot`, `Perplexity-User`, `Google-Extended` (solo como token de robots), `Applebot-Extended`.

## 6. Fases

> Regla transversal: cada tarea equivale a un PR pequeño que pasa CI. Si una fase rompe algo de la anterior, primero se escribe el ADR.

### Fase 0 · Decisiones (sin código de producto)
ADRs 0001–0008 (ver `docs/04-riesgos-y-decisiones.md`), `AGENTS.md` inicial y allowlist de MCP.
**Acepta si (enmendado por ADR-0011):** ADRs 0001, 0002, 0006 y 0010 aprobados por un humano, `AGENTS.md` y allowlist revisados. 0003, 0005 y 0007 quedan diferidos con plazo: **necesarios antes de abrir la fase 3** (preguntas 3, 4 y 7 de `04`); 0009 se resuelve dentro de la fase 1 con el spike y su default.

### Fase 1 · Fundación y loop de verificación
Monorepo pnpm + Turborepo. `apps/web` con landing SSG semántica. `apps/native` como **walking skeleton** (una pantalla). `packages/core`, `tokens`, `ui` y `config`. CI con lint, type-check, Vitest, Playwright smoke, axe, Lighthouse CI, build de ambas apps, gitleaks y boundaries.
**Acepta si:**
- [ ] `pnpm turbo run build lint typecheck test` en verde en CI desde un clon limpio.
- [ ] 3 componentes shadcn en `packages/ui` registrados en `UPSTREAM.md`.
- [ ] `core` tiene 1 tipo, 1 schema Zod y 1 cliente tipado, todos con tests, **y lo importan web y nativo**.
- [ ] Al cambiar un token en `packages/tokens/theme.css` cambian web y nativo (test visual o snapshot).
- [ ] Landing: `html-validate` sin errores, axe sin violaciones serias o críticas, `<h1>` y contenido visibles con JS deshabilitado.
- [ ] LCP < 2.5 s, INP < 200 ms, CLS < 0.1 (Lighthouse CI, mediana de 3 corridas, en el ambiente declarado en la configuración de CI).
- [ ] `robots.txt`, `sitemap.xml` y `llms.txt` responden 200.
- [ ] Ningún paquete CSS-in-JS en el lockfile (check en CI).
- [ ] gitleaks en pre-commit y en CI.

### Fase 2 · Interactividad
Formularios con `useActionState`, el mismo schema Zod en cliente y servidor, 4 o más rutas con layouts anidados, datos mock desde `core` y mapa de rutas en `core/routes.ts`.
**Acepta si:**
- [ ] El schema se define una sola vez y lo usan cliente y servidor (test que importa el mismo símbolo).
- [ ] Un test de Playwright envía un formulario inválido y luego uno válido.
- [ ] Cero errores de hidratación en la consola (Playwright falla si los hay).
- [ ] Todas las rutas web están declaradas en `core/routes.ts` (test).

### Fase 3 · Datos reales e IA de solo lectura
Backend en TypeScript (route handlers o servicio aparte, según ADR-0003). Autenticación (ADR-0005). Endpoint de chat con AI SDK 7, `ToolLoopAgent` con 2–3 tools `read` y UI con `useChat`. Telemetría.
**Acepta si:**
- [ ] TTFB del endpoint de stream < 200 ms p95 (sin contar el modelo). Se registra el TTFT del modelo.
- [ ] Las tools validan su entrada y su salida con Zod. Hay tests con un modelo mock.
- [ ] Si una tool falla, el usuario ve un mensaje amigable (test e2e con una tool que lanza error).
- [ ] Las evals base pasan con ≥ 90 % en el modelo por defecto.
- [ ] Autorización verificada en el DAL con un test de usuario sin permiso.

### Fase 4 · Agentes con efectos
Tools `write` y `external` con `toolApproval` y un **registro de aprobaciones en el servidor** (§4). UI de aprobación. Flujo durable de 2 pasos (`WorkflowAgent` o Mastra, según ADR-0004).
**Acepta si:**
- [ ] Un test recorre el registro de tools y falla si `approvalPolicy` no devuelve `'user-approval'` para alguna `write` o `external`.
- [ ] Un test e2e confirma que la tool no se ejecuta sin aprobación y sí con ella.
- [ ] Hay tests de integración que **rechazan**: un `approvalId` inventado, el de otro usuario, uno expirado, uno ya consumido (replay), uno con argumentos alterados tras aprobar y un historial falsificado en el body del request.
- [ ] El workflow se reanuda tras matar el proceso a mitad del flujo.
- [ ] Rate limit y tope de pasos activos y probados.

### Fase 5 · Móvil completo
`packages/ui-native`, pantallas de los flujos marcados `mobile: true`, TanStack Query, EAS Build y EAS Update y Maestro.
**Acepta si:**
- [ ] `packages/core` **sin cambios específicos de móvil** (el diff de la fase no toca `core`, o lo que lo toca es agnóstico).
- [ ] Cada ruta `mobile: true` existe en nativo (test sobre el mapa).
- [ ] EAS produce builds de iOS y Android en la nube. Hay un OTA publicado en `preview`.
- [ ] Los flujos críticos pasan en Maestro.
- [ ] Reporte de paridad generado por script: rutas y eventos de `core/analytics.ts` emitidos en cada plataforma.

### Fase 6 · Agent-ready experimental
WebMCP con 1–2 tools de lectura, JSON-LD completo y (opcional) tratamiento verificado de bots.
**Acepta si:**
- [ ] Test de Playwright en Chrome con WebMCP habilitado: la tool aparece registrada y su salida valida contra el schema.
- [ ] En navegadores sin WebMCP no hay errores (feature detection probada).
- [ ] Benchmark interno de tokens: agente con WebMCP frente a agente con DOM o screenshot, con el resultado documentado (sin metas preestablecidas).

### Criterio global
Cada fase cierra con CI en verde, una entrada en `CHANGELOG.md` (changesets), sus ADRs actualizados y **revisión humana** del PR de cierre. Si algo no cumple, no se avanza.

## 7. Anti-patrones (normativos)

1. **NO** crear un componente que ya exista en shadcn o en `packages/ui`. Primero se busca (CLI o MCP de shadcn) y luego se instala.
2. **NO** usar CSS-in-JS en runtime. Motivo: costo e incompatibilidad con RSC y streaming, y CSS que no se puede predecir.
3. **NO** usar valores arbitrarios de diseño (`#hex`, `px` mágicos, `bg-[...]`) fuera de `packages/tokens`. Lo hace cumplir el lint.
4. **NO** subir `'use client'` más arriba de lo necesario. Los límites cliente van en las hojas.
5. **NO** duplicar el acceso a datos: web usa RSC y actions, nativo usa TanStack Query, y ambos usan los fetchers de `core`.
6. **NO** cruzar una frontera sin Zod: inputs, tools, responses, env vars y `localStorage`/`AsyncStorage`.
7. **NO** basar la autorización en `proxy.ts`, en el User-Agent ni en cualquier header controlable por el cliente.
8. **NO** commitear secretos. gitleaks bloquea el commit.
9. **NO** reescribir archivos completos para cambios puntuales. Diff mínimo.
10. **NO** ignorar errores de hidratación ni warnings del React Compiler.
11. **NO** implementar fuera del alcance de la tarea. Las ideas van a `docs/ideas.md`.
12. **NO** crear contextos o providers fuera de `providers.tsx` o el root layout nativo.
13. **NO** usar `any`, `as unknown as`, `@ts-ignore` ni `eslint-disable` sin un comentario que explique por qué y un issue enlazado.
14. **NO** agregar dependencias sin justificarlas en el PR (tamaño, mantenimiento, alternativa nativa).
15. **NO** bajar umbrales de CI, borrar tests ni marcarlos `skip` para que un PR pase.
16. **NO** escribir código de framework de memoria: primero se consulta la documentación de la versión instalada.
17. **NO** compartir componentes visuales entre web y nativo.

## 8. Mantenimiento y actualización

- **Renovate**, con estos grupos: `next+react`, `expo-sdk` (siempre con `npx expo install --fix`, nunca versiones sueltas), `ai-sdk`, `tailwind+nativewind`, `devDependencies` (automerge si CI pasa) y `security` (inmediato).
- **Cadencia:** parches cada semana. Menores de Next y React cada mes. **Expo SDK: una mayor dentro de los 60 días siguientes al lanzamiento** (Expo publica unas 3 por año y solo da soporte a las recientes).
- **Runbooks ejecutables por un agente** en `docs/runbooks/` (`upgrade-next.md`, `upgrade-expo.md`). Cada uno incluye codemods oficiales (`npx @next/codemod`, `npx expo install --fix`), checklist y verificación.
- **Presupuesto de dependencias:** se revisa cada trimestre. Lo que no se usa, se elimina.

## 9. Ambientes, despliegue y rollback

| Ambiente | Web | Nativo | Datos | Quién despliega |
|---|---|---|---|---|
| **staging** | Deploy al hacer merge a `main` | Build interno (TestFlight / Internal testing) + canal `staging` (QR en el PR del merge) | Datos sintéticos o anonimizados | CI al hacer merge |
| **production** | Promoción manual desde staging | Store + canal `production` | Producción | **Humano** (aprobación en el environment de CI) |

- **Sin previews por PR (ADR-0010, 21-oct):** por presupuesto se elimina el deploy efímero por PR (web y canal `preview` de EAS). La verificación por PR queda en CI (builds y tests en el runner local); lo visual y con datos, en `staging` al merge. Se compensa con smoke e2e en CI y rollback < 5 min.
- **Rollback web:** se re-promueve el deploy anterior (instant rollback del hosting). Hay que poder hacerlo en < 5 min y está documentado en `docs/runbooks/rollback.md`.
- **Rollback móvil:** `eas update:rollback` (o republicar el update anterior) para cambios JS/OTA. Los cambios nativos requieren un build nuevo, por eso **todo cambio nativo pasa antes por TestFlight o Internal testing**. Las versiones nativas se controlan con `runtimeVersion` (política `fingerprint`).
- **Feature flags** para lo riesgoso y para los agentes nuevos del producto: se despliega apagado y se enciende por porcentaje.
- **Migraciones de BD** expand/contract (compatibles hacia atrás), para que un rollback de código no rompa datos.
- **Branch protection en `main`:** PR obligatorio, CI requerido, al menos 1 revisión humana, sin force-push. El token del agente **no tiene permiso** de push a `main` ni de aprobar PRs.
- **Secrets por ambiente** en el gestor del hosting o de CI. El agente nunca accede a los de producción.
- **Aislamiento de jobs disparados por PR.** El código de un PR lo escribe un agente y corre en el runner local: se trata como no confiable.
  1. Los jobs de PR corren en un **contenedor efímero** (Docker en el runner), sin secretos del host y sin secretos de ningún environment: solo claves dummy con tope de gasto y datos semilla sintéticos (environment `sandbox`).
  2. Los secretos de staging/producción se inyectan **solo** en jobs disparados por merge a `main` (staging) o promoción manual (producción), nunca por eventos de PR (ADR-0010).

## 10. Iteración en espiral: spikes y descarte

Los agentes generan, descartan y rehacen. El spec lo formaliza **sin añadir una fase**:

- **Spike** = experimento desechable para resolver una incógnita. Vive en una rama `spike/<tema>` o en `experiments/<tema>/` (excluido del build de producción y de la cobertura). Tiene una pregunta concreta, un **time-box** y una fecha de caducidad en su `README`.
- **Salida obligatoria de todo spike**: una nota en `docs/spikes/<fecha>-<tema>.md` con la pregunta, el hallazgo y la decisión (*adoptar → ADR + tarea limpia* o *descartar*). **El código del spike no se mergea tal cual**: si se adopta, se reimplementa como tarea normal.
- CI falla si existe un `experiments/*` con la fecha de caducidad vencida.
- **Descarte de decisiones**: un ADR nunca se borra. Se marca `superseded by ADR-00XX` y el nuevo ADR explica qué se elimina y el plan de retiro.
- **Retiro de código**: cuando se descarta una feature, se hace en un PR propio que elimina el código, sus tests, sus flags y sus dependencias. Un PR de retiro que deja código muerto no pasa `spec-lint` (exports sin uso, por ejemplo con `knip`).

## 11. `packages/spec-lint`: el spec ejecutable

Las reglas que se pueden verificar mecánicamente se juntan en **un solo paquete determinista**, que corre en pre-commit y en CI con `pnpm spec-lint`. Es determinista a propósito: **no es un agente.** Un LLM en el build sería no reproducible, costoso y manipulable con prompt injection desde el mismo código que revisa.

| Regla | Herramienta | Spec |
|---|---|---|
| Fronteras entre paquetes y dentro de `core` | dependency-cruiser | §2 |
| Ningún paquete CSS-in-JS en el lockfile | script | §7.2 |
| Sin valores de diseño arbitrarios fuera de `tokens` | regla ESLint propia | §7.3 |
| Sin autorización en `proxy.ts` (no importa el DAL ni lee cookies de sesión para decidir acceso) | regla ESLint propia | §7.7 |
| Las tools `write` y `external` tienen `approvalPolicy = 'user-approval'` y schema de salida | test sobre el registro de tools | §4 |
| No hay `needsApproval` en código nuevo | regla ESLint `no-restricted-syntax` | §4 |
| Las rutas de `llms.txt` y `sitemap` pertenecen al allowlist público | test | §5 |
| Límites de WebMCP (tamaños, hints) | test | §5 |
| Toda ruta de la app está en `core/routes.ts` | script | §6 F2 |
| Sin `eslint-disable` / `@ts-ignore` sin justificación ni issue | regla ESLint | §7.13 |
| Sin exports ni dependencias sin uso | knip | §10 |
| Spikes vencidos | script | §10 |
| Secretos | gitleaks | §7.8 |

Cada regla lleva en su mensaje de error **el enlace a la sección del spec que incumple**, para que el agente corrija leyendo la norma y no adivinando.

**`packages/core` por subpaths**, para evitar que se vuelva un god-package:

```jsonc
// packages/core/package.json
"exports": {
  "./domain":    "./src/domain/index.ts",
  "./schemas":   "./src/schemas/index.ts",
  "./api":       "./src/api/index.ts",
  "./routes":    "./src/routes.ts",
  "./analytics": "./src/analytics.ts"
}
// Sin export "." : nada de `import { x } from '@repo/core'`.
```

Dependencias internas permitidas: `domain` ← `schemas` ← `api`. `routes` y `analytics` no importan `api`. Un archivo nuevo en `core` que no encaje en estas carpetas exige un ADR.
