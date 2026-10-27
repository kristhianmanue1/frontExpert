# ADR-0012 · Alcance: playbook adoptable, no producto

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-21

## Contexto

El corpus admitía dos lecturas: el README hablaba de "definir el stack", pero las fases 1–6 del spec (builds, staging, TestFlight) leían como construcción de producto dentro de este repo. El dueño aclaró el alcance el 21-oct: frontExpert produce **el "cómo"** para que otros proyectos lo adopten; nunca construye la web ni la app.

## Decisión

- **frontExpert es un playbook puro:** este repo no contiene ni contendrá código de producto (ni `apps/` ni `packages/` de aplicación). Su entregable: spec, ADRs de referencia, plantillas, scripts de verificación y runbooks.
- Las **fases 1–6 de `02` son la guía que ejecuta cada proyecto adoptante**, en su propio repositorio.
- **Contrato de adopción:** el adoptante (1) copia el corpus —todo lo que cubre el manifiesto: `docs/`, `plantillas/`, `scripts/`, `.frontexpert/`, `README.md`, `LICENSE`, `AGENTS.md`, `CONTRIBUTING.md`, `.github/`— (contrato **v2**: lista enmendada por ADR-0013, la ronda de `docs/08` y ADR-0014 — `docs/handoff.md` no se copia: el adoptante crea el suyo desde `plantillas/handoff.md`; la verificación del adoptante es contra **su propio manifiesto**, generado como último paso de la adopción; en modo conjunto con skevi los scripts viven en `scripts/frontexpert/` —), (2) responde las 8 preguntas de `04` con sus propias respuestas —las de la tabla son defaults de referencia, revocables— y confirma o sustituye los ADRs, y (3) devuelve upstream las lecciones (contradicciones, parches, ADRs nuevos; mecanismo: `CONTRIBUTING.md`) para que el manual mejore con cada adopción.
- El runner local y el mini-CI de documentación (lint de markdown + `verify-stack.sh`) quedan como **opcionales** para este repo; nada del playbook depende de ellos.

## Consecuencias

- El manual llega a su primer adoptante **sin haberse ejecutado**: se mitiga acompañando de cerca la primera adopción y capturando cada contradicción como parche upstream.
- Los ADRs firmados aquí —8 archivos: 0001, 0002, 0004, 0006, 0008, 0010, 0011 y 0012— pasan a ser **defaults de referencia** con validez probada; el adoptante los hereda salvo decisión propia. (Los vacantes 0003/0005/0007/0009 siguen abiertos en `04`; corrección de inventario: ADR-0013.)
- La opción A (walking skeleton congelado aquí, "implementación de referencia") queda registrada como alternativa y puede reactivarse si la primera adopción tropieza demasiado.
