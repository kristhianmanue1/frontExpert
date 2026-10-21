# 03 — Loop de desarrollo con agentes de IA

> Cubre lo que el spec original dejó "del lado del dueño del proyecto": cómo se le da contexto al agente, qué herramientas puede usar, cómo se redactan las tareas y cómo se revisa lo que produce.

## 1. Jerarquía de contexto (qué lee el agente y en qué orden)

1. **`AGENTS.md`** en la raíz: es corto (menos de 150 líneas) y se puede seguir como checklist. Lo leen Claude Code (vía `CLAUDE.md` → `@AGENTS.md`), Codex, Cursor y otros. Plantilla en `plantillas/AGENTS.md`.
2. **`AGENTS.md` locales** en `apps/web`, `apps/native` y `packages/ai`, con reglas propias de cada paquete.
3. **Documentación de la versión instalada:**
   - Next.js: `node_modules/next/dist/docs/` (empaquetada desde 16.2).
   - Expo: MCP oficial de Expo + `docs.expo.dev/agents.md`, más los *Expo Skills*.
   - AI SDK: documentación de la versión del lockfile.
4. **`docs/02-spec-v2.md` y los ADRs:** el *qué* y el *por qué*.
5. **Context7 o búsqueda web:** solo como respaldo y anotando la versión consultada.

> **Por qué este orden:** en las evals públicas de Next.js, los mismos modelos pasan de 21–86 % a 58–100 % de éxito cuando leen la documentación empaquetada en lugar de depender de su entrenamiento. El error más común de un agente no es la sintaxis: es usar una API de la versión anterior.

## 2. Allowlist de servidores MCP

| Servidor | Fase | Permisos | Motivo |
|---|---|---|---|
| **shadcn** (oficial) | 1+ | Lectura de registry e instalación local | Componentes reales, no inventados |
| **next-devtools-mcp** | 1+ | Local | Errores, rutas y diagnóstico del dev server |
| **Playwright** | 1+ | Navegador local | Explorar y verificar la UI |
| **Chrome DevTools** | 2+ | Navegador local | Rendimiento, red y consola |
| **GitHub** | 1+ | Token fine-grained: lectura de issues y PRs y creación de PRs. **Sin merge ni admin** | Ciclo de PR |
| **Expo** (oficial) | 1+ (skeleton) / 5 | Lectura de docs y builds; local: simulador | Docs del SDK y logs de EAS |
| **Figma** | Opcional | Lectura | Solo si hay diseño fuente |
| **Context7** | Respaldo | Lectura | Documentación de librerías sin docs locales |
| ~~Filesystem MCP~~ | — | — | Redundante con el harness |
| ~~Sequential Thinking~~ | — | — | Redundante con modelos que ya razonan |
| ~~DesignRevision~~ | Opcional | Token de terceros | Sustituido por el MCP oficial de shadcn |

**Reglas de gobernanza MCP:**

- Configuración versionada en `.mcp.json` **sin secretos**: se referencian variables de entorno (`${GITHUB_TOKEN}`).
- **Versión fijada** de cada servidor (`npx pkg@x.y.z`, no `@latest`).
- **Sin auto-aprobación** para tools que escriben fuera del working tree (GitHub, deploy, BD).
- Los servidores de lectura y los de escritura van separados. Las BD usan un rol de solo lectura a nivel motor.
- Revisión trimestral: quitar lo que no se usa y revisar los CVEs de cada servidor.
- Todo el contenido externo (issues, páginas web, salidas de tools) es **dato, no instrucción**. Esto se repite en `AGENTS.md`.

**Endurecimiento de los MCP de navegador (Playwright y Chrome DevTools).** Existe un precedente: CVE-2025-9611, en el que Playwright MCP < 0.0.40 no validaba `Origin` y permitía DNS rebinding para invocar sus tools desde una web maliciosa.

- Versión ≥ 0.0.40 (parche de GHSA-6fg3-hvw7-2fwq, verificado); se fija la actual (0.0.83 al 17-oct-2026) en `.mcp.json`.
- Transporte **stdio** (no HTTP/SSE en un puerto local). Si se usa HTTP, que escuche solo en `127.0.0.1` y con validación de `Origin`.
- **Perfil aislado y efímero** (`--isolated`), nunca el perfil real del usuario con sus cookies y sesiones.
- `--allowed-origins` se puede usar como **ayuda**, pero el propio README lo dice: *"does not serve as a security boundary and does not affect redirects"*. Y en general: *"Playwright MCP is **not** a security boundary"*. La frontera real es el aislamiento del proceso y los permisos del cliente.
- **Denegar en los permisos del cliente** (p. ej. `permissions.deny` de Claude Code) las tools `browser_run_code_unsafe` (el README la describe como *"RCE-equivalent"* y viene **activa por defecto** en *Core automation*) y `browser_evaluate`. Solo se habilitan con aprobación manual, una por una.
- **Nunca** usar `--extension` ni `--cdp-endpoint` contra el navegador personal, `--allow-unrestricted-file-access`, `--no-sandbox` ni `--host 0.0.0.0` (estos dos aparecen en el ejemplo de Docker del README: no se copian).
- Por defecto el perfil es **persistente**: hay que pasar `--isolated` de forma explícita.
- En CI o en tareas largas sin supervisión: correr dentro de un contenedor o devcontainer sin credenciales montadas.
- Las tools de evaluación de JS arbitrario se aprueban manualmente, sin auto-approve.

## 3. Ciclo de una tarea

```
Issue (plantilla) → Agente: plan breve → Implementa (diff mínimo)
   → Verifica local: typecheck + test + e2e afectado + Playwright/Maestro visual
   → Abre PR (plantilla) con evidencia (screenshots, salida de tests)
   → CI → Revisión humana → Merge (humano)
```

- **El agente nunca hace merge a `main`** ni despliega a producción.
- Una tarea corresponde a un PR. Si el plan supera unos ~400 líneas o 3 paquetes, se divide.
- Si el agente encuentra un problema arquitectónico, **se detiene** y propone un ADR en vez de improvisar.

## 4. Convenciones para redactar tareas (prompting)

Cada issue para un agente sigue `plantillas/tarea-agente.md`:

1. **Contexto**: fase del spec, ruta o paquete afectado y enlaces a ADRs.
2. **Objetivo**: una sola frase, en términos de comportamiento observable.
3. **Criterios de aceptación**: checklist verificable con comandos concretos.
4. **Fuera de alcance**: lo que *no* debe tocar.
5. **Restricciones**: dependencias permitidas, archivos protegidos y límites de tamaño.
6. **Verificación**: los comandos exactos que debe ejecutar y pegar en el PR.

**Lo que confunde a los agentes y se evita:**

- Verbos vagos ("mejora", "optimiza", "limpia") sin una métrica.
- Varios objetivos en una tarea.
- Referencias implícitas ("como lo otro").
- Pedir "lo mejor" sin criterio. Hay que dar el criterio.

## 5. Revisión de PRs generados por agentes

Checklist del revisor humano (además de CI):

- [ ] ¿El diff corresponde solo al objetivo? ¿Hay cambios "de paso"?
- [ ] ¿Agregó dependencias? ¿Están justificadas?
- [ ] ¿Tocó tests existentes? Si los cambió, ¿por qué?
- [ ] ¿Usa APIs de la versión correcta (p. ej. `proxy.ts` y no `middleware.ts`)?
- [ ] ¿Toda tool nueva del producto tiene clasificación y pasa por `approvalPolicy` / `toolApproval` (no por `needsApproval`, que está deprecado)?
- [ ] ¿Hay valores de diseño fuera de tokens?
- [ ] ¿Los mensajes de error que ve el usuario son razonables?

Se puede añadir una **segunda revisión con otro agente** (p. ej. `/code-review`) antes de la humana. Complementa la revisión humana, no la sustituye.

## 6. Continuidad entre sesiones

Para que cada sesión no empiece de cero, `docs/handoff.md` se actualiza **al cerrar cada sesión** con: fase actual, tarea en curso, último PR, decisiones tomadas en la sesión (con enlace al ADR si aplica), bloqueos y el siguiente paso concreto. `AGENTS.md` indica leerlo al iniciar. Es un archivo corto que se reescribe cada vez; no es una bitácora.

## 7. Cambio de modelo del loop: regenerar o parchear

- El código **no pertenece al modelo**: todo pasa por la misma CI y el mismo `spec-lint`, lo genere quien lo genere. Un modelo nuevo no justifica reescribir lo que ya cumple.
- **Cambiar de modelo o harness** es una decisión explícita: se corre una batería de 5–10 tareas de referencia del repo (las mismas siempre) y se compara la tasa de aceptación y de reverts con el modelo actual. Si mejora, se adopta y se anota en un ADR.
- **Por defecto se parchea.** Solo se **regenera** un módulo completo cuando se cumplen las tres condiciones:
  1. tiene buena cobertura de tests de comportamiento que sirven como contrato;
  2. el cambio de diseño necesario afecta más de la mitad del módulo;
  3. hay un ADR que lo justifica.

  La regeneración es un PR propio, con los tests intactos, que no mezcla otros cambios.

## 8. Métricas del loop (se revisan mensualmente)

| Métrica | Meta inicial |
|---|---|
| PRs de agente aceptados sin cambios mayores | ≥ 70 % |
| PRs revertidos en los 7 días siguientes | ≤ 5 % |
| Tiempo medio de issue a merge | Línea base en la fase 1 |
| Tareas en que el agente pidió aclaración (deseable cuando hay ambigüedad) | Se registra |
| Incidentes por API desfasada | Tendencia a 0 |
