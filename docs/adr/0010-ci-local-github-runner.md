# ADR-0010 · Infraestructura de CI: GitHub + runner self-hosted local

- **Estado:** aceptado · **Fecha:** 2026-10-21

## Contexto

Los créditos de GitHub se agotaron, así que el CI no puede correr en runners hospedados por GitHub. El corpus depende de PRs, protección de rama con checks requeridos, revisión humana obligatoria como gate técnico (`02 §9`, `03 §3`) y el MCP de GitHub (`03 §2`): la opción de CI debe preservar esos controles. Alternativas evaluadas en la sesión del 21-oct: (A) GitHub + runner self-hosted, (B) Forgejo/Gitea interno, (C) bare git + hooks. Presupuesto ajustado obliga además a recortar los deploys efímeros por PR.

## Decisión

- **Opción A: el repo vive en GitHub (`AGTexperts/frontExpert`, privado) y el CI corre en una caja propia con Docker.** Los runners self-hosted no consumen minutes de GitHub, ni en repos privados.
- **Jobs de PR en contenedor efímero** (environment `sandbox`), sin secretos del host; los secretos de staging/producción solo en jobs disparados por merge a `main` o promoción manual (extensión de `02 §9` y del riesgo R16).
- **Previews por PR eliminados** (web y canal `preview` de EAS): la verificación por PR queda en CI; lo visual y con datos, en `staging` al merge. Reduce también la presión sobre ADR-0007.
- **Móvil:** EAS Build en la nube para releases; `eas build --local` en la caja para iterar si la cuota libre aprieta. Maestro/iOS en CI solo cuando exista un runner macOS.
- Runbook: `docs/runbooks/ci-local.md`.

## Consecuencias

- Se conservan intactos PRs, protección de rama, la revisión humana como control técnico, el MCP de GitHub y Renovate hosted.
- La caja debe estar encendida para que el CI corra: se arranca en el Mac de desarrollo y se migra a una caja dedicada (Mac mini o Linux) cuando la fase 1 lo pida; un solo runner implica cola.
- Los checks requeridos se activan con el primer workflow (fase 1); hasta entonces la protección cubre revisión y no-force-push.
- Se pierde la inspección visual por PR; se compensa con smoke e2e en CI y rollback < 5 min (R15).
- El runner local además da el "ambiente declarado en la configuración de CI" que exige el gate de Lighthouse CI (`02 §6`).
