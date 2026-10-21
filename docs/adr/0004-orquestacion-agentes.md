# ADR-0004 · Orquestación de agentes del producto

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-21

## Contexto

El spec base enumeraba cinco frameworks de agentes (AI SDK, Mastra, LangGraph.js, OpenAI Agents SDK, CopilotKit): para un agente lector, eso es ambigüedad (`01 §1.11`). AI SDK 7 aporta `ToolLoopAgent` y `WorkflowAgent` (durables), con lo que la durabilidad ya tiene camino por defecto.

## Decisión

**AI SDK 7** como único orquestador por defecto: `ToolLoopAgent` para chat con tools y `WorkflowAgent` para flujos durables. Mastra solo si se necesita memoria/RAG gestionado o su Studio de evals, y en ese caso con ADR propio. LangGraph.js reservado a grafos cíclicos complejos (también con ADR). CopilotKit fuera del núcleo.

## Consecuencias

- Un solo camino por defecto por problema (principio 3 del spec); los cambios de motor son decisiones, no derivas.
- Si `WorkflowAgent` se queda corto para un flujo concreto, se abre ADR antes de introducir Mastra: nunca dos frameworks conviviendo "por si acaso".
- Las evals y el `modelRegistry` (`packages/ai`) se diseñan contra una sola API de agentes.
