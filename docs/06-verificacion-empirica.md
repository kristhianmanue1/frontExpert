# 06 — Verificación empírica (2026-10-17)

**Método:** se descartó como prueba suficiente lo que dicen los resúmenes web, porque el modelo que resume páginas puede alucinar. Cada afirmación se verificó contra la **fuente primaria ejecutable**:

- **Registro de npm** (`npm view`): versiones, dist-tags, fechas y peers.
- **Código publicado**: `npm pack` del paquete y lectura de `dist/*.d.ts` y `dist/*.js`.
- **GitHub Advisory Database** (`gh api /advisories`): CVEs y versiones parcheadas.
- **README oficial empaquetado** (Playwright MCP) y la **documentación empaquetada** de Next.js.
- **Chrome Developers**: se pidieron citas textuales.

Los paquetes se descargaron al scratchpad de la sesión, fuera del proyecto, y no se instaló nada en el repo.

**Leyenda:** ✅ confirmado · ❌ refutado (y corregido) · 🔄 matizado.

---

## A. Versiones (`npm view`)

| Paquete | Lo que decían los docs | **Real** | Resultado |
|---|---|---|---|
| `next` | 16.3.x | **16.4.2** (16.4.0: 2026-10-06) | ❌ → corregido |
| `react` | 19.3.x | **19.3.1** (19.3.0: 2026-09-09) | ✅ |
| `ai` | 7.x | **7.0.143** (7.0.0: 2026-06-25) | ✅ |
| `expo` | SDK 57 / RN 0.86 | **SDK 58** (2026-09-29) → `react-native 0.88.0`, `react 19.3.0`, `expo-router ~58.0.23` (según `bundledNativeModules.json`) | ❌ → corregido |
| `nativewind` | **"v5 estable desde el 25-jun-2026"** | `latest` = **4.2.7**; v5 solo como **`5.0.0-rc.0`** (2026-09-13), con peer `react-native-css 3.1.0-rc.0` | ❌ **Refutado** → ADR-0009 |
| `tailwindcss` | 4.3.x | 4.3.3 | ✅ |
| `typescript` | "6.x + `tsgo` 7.x" | `latest` = **7.0.2** · `typescript-eslint@8.71.2` exige `typescript >=4.8.4 <6.1.0` · el binario de TS 7 es **`tsc`** · la API solo existe en `typescript/unstable/*` | 🔄 corregido: fijar `typescript@~6.0.3` |
| `zod` | 4.x | 4.6.7 | ✅ |
| `@mastra/core` | 1.x | 1.78.0 | ✅ |
| `pnpm` | 10.x | **12.14.0** | ❌ → corregido |
| `turbo` | 2.x | 2.11.9 | ✅ |
| `@playwright/mcp` | ≥ parche del CVE | 0.0.83 | ✅ |

> **Lección:** la afirmación de que NativeWind v5 era estable salió de un resultado de búsqueda y era **falsa**. Fue el único error con impacto de arquitectura, porque la idea de "mismos tokens Tailwind v4 en web y nativo" dependía de ella. Ahora es una decisión abierta (ADR-0009) que se resuelve con un spike en la fase 1: NativeWind 5 RC, Uniwind 1.12 (Tailwind ≥4) o NativeWind 4 con tokens generados desde una fuente única.

## B. Aprobación de tools en el AI SDK (código de `ai@7.0.143` y `@ai-sdk/provider-utils@5.0.62`)

| Afirmación | Evidencia en el código | Resultado |
|---|---|---|
| `needsApproval` está deprecado | `provider-utils/dist/index.d.ts:2154`: `@deprecated Tool approval is handled on a generateText / streamText level now.` | ✅ |
| Su reemplazo es `toolApproval` | `toolApproval?: ToolApprovalConfiguration` en `generateText`, `streamText` y `ToolLoopAgent`; *"takes precedence over tool-defined approval settings"*. Estados: `'not-applicable' \| 'approved' \| 'denied' \| 'user-approval'` | ✅ |
| "El servidor no revalida las aprobaciones" (resumen web) | **Falso.** `validateApprovedToolApprovals()`: *"Re-validates approved tool approvals reconstructed from client-supplied message history before they are executed. Checks HMAC signature (when configured), input schema, and approval policy."* | ❌ refutado |
| Existe protección contra aprobaciones falsificadas | `experimental_toolApprovalSecret`: *"the server signs each approval request at issuance and verifies the signature when the approval is replayed, preventing client-forged approvals."* HMAC-SHA256 sobre `["ai-sdk-tool-approval-v1", approvalId, toolCallId, toolName, inputDigest]`. Sin firma o con firma inválida lanza `InvalidToolApprovalSignatureError`. | ✅ hallazgo nuevo |
| ¿Cubre replay, usuario y expiración? | El payload firmado **no incluye** usuario, sesión, timestamp ni nonce de un solo uso. | ✅ el registro de aprobaciones en el servidor sigue siendo necesario |

**Consecuencia para el C2 de la ronda adversarial:** su conclusión ("la aprobación tiene que vivir en el servidor") es correcta, pero el SDK **ya hace parte** del trabajo. La combinación adoptada en el spec v2 §4 es: `toolApproval` + `experimental_toolApprovalSecret` (falsificación y alteración de argumentos) + registro propio (replay, usuario y expiración) + historial cargado desde la BD.

## C. Playwright MCP (README de `@playwright/mcp@0.0.83` + GitHub Advisory)

| Afirmación | Evidencia | Resultado |
|---|---|---|
| CVE-2025-9611 por DNS rebinding, parcheado en 0.0.40 | `GHSA-6fg3-hvw7-2fwq`, severidad high, `< 0.0.40`, parcheado en `0.0.40` | ✅ |
| **"Vector de RCE"** (ronda adversarial; yo lo había calificado de "exagerado") | Tool `browser_run_code_unsafe`: *"executes arbitrary JavaScript in the Playwright server process and is **RCE-equivalent**"*, dentro de **Core automation** (activa por defecto) | ✅ **Confirmado. Me rectifico.** |
| `--allowed-origins` como control de seguridad (yo lo recomendé) | README: *"Important: **does not serve as a security boundary** and does not affect redirects."* | ❌ refutado → corregido en `03` |
| Seguridad general | README: *"Playwright MCP is **not** a security boundary."* El perfil por defecto es **persistente**; `--isolated` hay que pedirlo. El ejemplo de Docker usa `--no-sandbox --host 0.0.0.0`. | ✅ incorporado en `03` |

## D. Next.js (paquete `next@16.4.2`)

| Afirmación | Evidencia | Resultado |
|---|---|---|
| Documentación empaquetada en `node_modules/next/dist/docs` | 474 archivos `.md`, entre ellos `01-app/01-getting-started/16-proxy.md` y `01-app/02-guides/ai-agents.md` | ✅ |
| `AGENTS.md` gestionado | `ai-agents.md`: *"Next.js 16.3 and later include bundled documentation and support managed agent instructions. Next.js 16.2 includes the bundled documentation but does not generate instructions automatically."* | ✅ (precisión: el `AGENTS.md` gestionado es desde 16.3) |
| Docs empaquetadas > Skills | Misma guía: *"100% pass rate with bundled documentation, compared with up to 79% for Skill-based approaches"* | ✅ (es una afirmación de Vercel, no independiente) |
| CVE-2026-64642, bypass de proxy | `GHSA-6gpp-xcg3-4w24`, high, `>= 16.0.0, < 16.2.11`, parcheado en 16.2.11 | ✅ |

## E. WebMCP (Chrome Developers, citas textuales)

| Afirmación | Resultado |
|---|---|
| `readOnlyHint`, `consequentialHint`, `untrustedContentHint` y `exposedTo` | ✅ textual |
| Límites: descripción 500, parámetro 150, salida 1.5K | ✅, y además **nombre de tool y de parámetro ≤ 30** (nuevo, agregado al spec) |
| `requestUserInteraction()` | 🔄 la página dice *"spec draft includes"*: está en el borrador, no garantizado en Chrome. El spec ya no depende de él. |

## F. Lo que NO se pudo verificar empíricamente

| Afirmación | Por qué | Cómo tratarla |
|---|---|---|
| `llms.txt`: "97 % sin peticiones" y las cifras de GPTBot y ClaudeBot | Son estudios de terceros sin datos crudos accesibles | Se mantiene como **indicio** y no como hecho. La decisión (prioridad baja) no depende de la cifra exacta. |
| WebMCP: 68–89 % menos tokens | Benchmarks de terceros | Fase 6: benchmark propio |
| Evals de Next.js (71 → 100 %, etc.) | Publicadas por Vercel, que es parte interesada | Útil como dirección; replicarlo con tareas propias (`03 §7`) |
| Los **25 hallazgos** de la ronda adversarial | Solo se recibió el resumen | Pedirlos completos con evidencia |
| Políticas de cloaking y crawlers de Anthropic | Son documentos de política, no código | Fuentes oficiales citadas en `FUENTES.md` |

---

## Resumen de rectificaciones propias

1. **NativeWind v5 "estable"** → falso; es RC. La decisión pasa a ADR-0009.
2. **Next 16.3, Expo 57/RN 0.86, pnpm 10** → la realidad es 16.4, 58/0.88 y 12.
3. **"`tsgo`"** → el binario de TS 7 es `tsc`. Además, `typescript-eslint` obliga a quedarse en TS < 6.1.
4. **C4 "RCE exagerado"** → incorrecto; el propio README lo llama RCE-equivalent.
5. **`--allowed-origins` como allowlist de seguridad** → el README dice que no lo es.
6. **"El SDK no valida las aprobaciones"** → sí revalida y además ofrece firma HMAC experimental.

Todas están aplicadas en `01`, `02`, `03`, `04`, `05`, `README` y `plantillas/AGENTS.md`.

## Cómo repetir esta verificación

```bash
npm view next react ai expo nativewind tailwindcss typescript zod @mastra/core @playwright/mcp turbo pnpm version
npm view nativewind dist-tags --json
npm view typescript-eslint peerDependencies --json
gh api "/advisories?cve_id=CVE-2025-9611" --jq '.[].vulnerabilities'
gh api "/advisories?cve_id=CVE-2026-64642" --jq '.[].vulnerabilities'
# En un directorio vacío:
npm pack ai@7 && tar xzf ai-*.tgz && grep -n "toolApprovalSecret" package/dist/index.d.ts
npm pack @playwright/mcp && tar xzf playwright-mcp-*.tgz && grep -n "RCE-equivalent\|security boundary" package/README.md
```

> Se recomienda convertir este bloque en `scripts/verify-stack.sh` en la fase 0 y correrlo antes de cada fase. Es la versión mínima del `spec-lint` de versiones.
