# ADR-0006 · Lint y formato

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-21

## Contexto

`04` dejaba abierta la elección entre ESLint flat + Prettier y Biome. Las reglas propias de `spec-lint` (`02 §11`: fronteras, valores de diseño, `needsApproval`, `proxy.ts` sin autorización) necesitan una plataforma de plugins estable; el React Compiler y Tailwind tienen plugins de ESLint maduros.

## Decisión

**ESLint (flat config) + Prettier.** Las reglas deterministas del spec viven como configuración y plugins de ESLint dentro de `packages/spec-lint`; Prettier se mantiene separado del lint (sin `eslint-plugin-prettier`). Biome queda como alternativa solo con un ADR futuro que lo justifique por rendimiento.

## Consecuencias

- `spec-lint` hereda todo el ecosistema de reglas (React Compiler, Tailwind, `no-restricted-syntax` para APIs deprecadas).
- Velocidad de lint menor que Biome: aceptada a cambio de no duplicar reglas a mano.
- El gate de CI (`lint`) y el pre-commit comparten la misma configuración versionada en `packages/config`.
