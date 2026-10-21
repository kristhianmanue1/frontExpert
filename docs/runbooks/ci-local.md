# Runbook · CI local (GitHub + runner self-hosted)

> Decisión: `adr/0010`. El repo vive en GitHub; el CI corre en una caja propia con Docker.

## Registro del runner (una vez por caja)

1. GitHub → `AGTexperts/frontExpert` → **Settings → Actions → Runners → New self-hosted runner**.
2. Seguir los comandos que GitHub imprime (descarga, `config.sh` con labels: `self-hosted,linux,docker` en Linux, `self-hosted,macos` en Mac).
3. Instalar como servicio para que arranque con la máquina: `./svc.sh install && ./svc.sh start`.
4. Verificar en la UI de Runners que aparezca **Idle**.

**Reglas del runner:**

- Jobs de PR: siempre con `container:` en el workflow (efímeros, sin secretos del host). Environment `sandbox` únicamente.
- Secretos reales: como **environments** de GitHub (`staging`, `production`), nunca en el runner ni en el host.
- El token del agente no administra runners ni repos (scopes mínimos, sin merge ni admin).

## Protección de `main`

- **Pendiente de plan (verificado 21-oct):** branch protection y rulesets devuelven 403 en repos privados con plan Free. Al subir a GitHub Pro o crear la org: PR obligatorio, 1 revisión humana (descartada al subir cambios), sin force-push ni borrado, con `gh api repos/<owner>/frontExpert/branches/main/protection`.
- Mientras tanto el control es procedural: el agente nunca hace push a `main` (regla de `03 §3` y de `AGENTS.md`); los merges los hace el humano.
- Los **checks requeridos** se añaden en la fase 1 con el primer workflow (`lint`, `typecheck`, `test`, `spec-lint`, `build`): Settings → Branches → Require status checks. Hasta entonces, la revisión humana es el único gate.

## Cola y mantenimiento

- Un solo runner = cola; los builds móviles van a EAS, no al runner.
- Actualizar el runner cuando la UI lo pida (banner amarillo).
- Caja apagada = CI no corre: los PRs esperan; no hay timeout de facturación. Para la fase 1, evaluar la caja dedicada.
- Docker Desktop ya verificado en el Mac de desarrollo (28.5.1 + Compose).
