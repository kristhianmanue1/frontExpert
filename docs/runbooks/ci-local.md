# Runbook · CI local (GitHub + runner self-hosted)

> Decisión: `adr/0010`. El repo vive en GitHub; el CI corre en una caja propia con Docker. **Aplica al repo del proyecto adoptante; en frontExpert es opcional (ADR-0012).**

## Registro del runner (una vez por caja)

1. GitHub → `kristhianmanue1/frontExpert` (pasará a `AGTexperts` cuando exista la org y se transfiera) → **Settings → Actions → Runners → New self-hosted runner**.
2. Seguir los comandos que GitHub imprime (descarga, `config.sh` con labels: `self-hosted,linux,docker` en Linux, `self-hosted,macos` en Mac).
3. Instalar como servicio para que arranque con la máquina: `./svc.sh install && ./svc.sh start`.
4. Verificar en la UI de Runners que aparezca **Idle**.

**Reglas del runner:**

- Jobs de PR: siempre con `container:` en el workflow (efímeros, sin secretos del host). Environment `sandbox` únicamente.
- Secretos reales: como **environments** de GitHub (`staging`, `production`), nunca en el runner ni en el host.
- El token del agente no administra runners ni repos (scopes mínimos, sin merge ni admin).

## Variante host macOS — runner efímero contenedorizado (ADR-0014)

La regla `container:` de arriba no es ejecutable en un host macOS: el runner macOS nativo no soporta `container:` y un runner en Docker que lance `container:` necesita el socket de Docker — root de facto sobre el host. La variante, estrenada en la primera adopción (issue #2, lección 5: 6 corridas, 6 runners distintos, verde tras merge), invierte la forma: **el runner mismo es el contenedor efímero**.

**Contrato mínimo:**

- Imagen Linux fijada por digest sobre `ghcr.io/actions/actions-runner` (arm64 en Apple Silicon; la arquitectura sigue al host, no es requisito), herramientas horneadas: Node verificado por sha256, pnpm por corepack, Chromium de Playwright. Usuario `runner` sin sudo ni grupo docker.
- Registro sin `svc.sh`: un bucle en el host pide un **token de un solo uso** con `gh api` y lo pasa por **stdin** a `docker run --rm -i` — sin volúmenes, sin `--privileged`, sin socket. Registro `--ephemeral`: **un job por contenedor** y desaparece.
- Labels del **contenido** (Linux), no del host: `self-hosted,linux,docker`.
- Environments y secretos: **sin cambios** — environment `sandbox` para jobs de PR; secretos reales solo por merge a `main` (reglas de arriba).

**Verificación de entrada (una vez por gate, control positivo):** un test roto debe hacer fallar `ci`; un archivo sobre el límite debe hacer fallar el gate de skevi.

**Advertencias:** el aislamiento es **de privilegios, no de red** (el job tiene red de salida); un repo **público** debe restringir los PR de forks antes de servir cualquier runner self-hosted.

**Nota de sondeo:** no existe forma de esperar un run de GitHub sin consultar la API (`gh run watch` hace polling por debajo); con regla «sin polling», decláralo como desviación acotada.

## Protección de `main`

- **Pendiente de plan (verificado 21-oct):** branch protection y rulesets devuelven 403 en repos privados con plan Free. Al subir a GitHub Pro o crear la org: PR obligatorio, 1 revisión humana (descartada al subir cambios), sin force-push ni borrado, con `gh api repos/<owner>/frontExpert/branches/main/protection`.
- Mientras tanto el control es procedural: el agente nunca hace push a `main` (regla de `03 §3` y de `AGENTS.md`); los merges los hace el humano.
- Los **checks requeridos** se añaden en la fase 1 con el primer workflow (`lint`, `typecheck`, `test`, `spec-lint`, `build`): Settings → Branches → Require status checks. Hasta entonces, la revisión humana es el único gate.

## Cola y mantenimiento

- Un solo runner = cola; los builds móviles van a EAS, no al runner.
- Actualizar el runner cuando la UI lo pida (banner amarillo).
- Caja apagada = CI no corre: los PRs esperan; no hay timeout de facturación. Para la fase 1, evaluar la caja dedicada.
- Docker Desktop ya verificado en el Mac de desarrollo (28.5.1 + Compose).
