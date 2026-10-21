# ADR-0001 · Stack base y versiones fijadas

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-21

## Contexto

El spec base llegaba con versiones no verificadas y varias desfasadas (`01 §1`); la verificación empírica del 17-oct (`06 §A`) fijó las reales contra el registro de npm. El riesgo R1 (agente usando APIs de versiones anteriores) y el R10 (TS 7 sin API programática) dependen de esta decisión.

## Decisión

La tabla de `02-spec-v2.md §1` queda fijada tal cual: Node 24 LTS, pnpm 12, Turborepo 2, TypeScript `~6.0.3` para lint y herramientas (7 solo para type-check opcional), React 19.3, Next 16.4, Tailwind 4.3, Zod 4, AI SDK 7, Expo SDK 58, Vitest, Playwright, Maestro, Renovate. Las versiones se revalidan con `scripts/verify-stack.sh` al abrir cada fase; **un cambio de major exige ADR nuevo** (NativeWind queda fuera: ADR-0009).

## Consecuencias

- El agente siempre parte de documentación de la versión exacta instalada, no de su memoria.
- R1 y R10 quedan mitigados de forma verificable.
- El mantenimiento de versiones deja de ser una negociación por PR: manda la tabla y el script.
