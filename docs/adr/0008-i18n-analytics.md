# ADR-0008 · i18n y analytics

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-21

## Contexto

El spec base no decidía i18n ni analytics, y migrarlos tarde es caro (`01 §6`). El producto es español primero, con usuarios potenciales en México (LFPDPPP, pregunta abierta 7), y el spec exige un catálogo tipado de eventos (`core/analytics.ts`) para medir paridad web/nativo.

## Decisión

**next-intl** para i18n y un **catálogo tipado de eventos** en `packages/core/analytics.ts` con **PostHog** (o equivalente self-hostable si los requisitos de datos lo exigen al responder la pregunta 7). Los eventos se emiten solo desde el catálogo tipado; nunca strings sueltos.

## Consecuencias

- La paridad de eventos web/nativo (fase 5) se verifica contra el catálogo, que es la única fuente.
- El proveedor de analytics puede cambiarse sin tocar las pantallas: se reescriben los sinks del catálogo.
- La elección definitiva del proveedor queda condicionada a la respuesta regulatoria (pregunta 7); la arquitectura no cambia.
