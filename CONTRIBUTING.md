# CONTRIBUTING — Devolución de lecciones de adopción

El contrato de adopción (ADR-0012) dice «devuelve las lecciones upstream». Esta página dice por dónde (issue #1, punto 6; ronda registrada en `docs/08`).

> **Precondición:** este canal requiere repo público (o issues habilitados para terceros). Mientras el repo sea privado, las lecciones se recogen por el canal interno del dueño y se migran aquí al hacerlo público (procedencia: ADR-0013).

## Cómo se devuelve una lección

1. Abre un **issue** en este repo (no un PR) con la plantilla «Lección de adopción» (`.github/ISSUE_TEMPLATE/`).
2. Campos fijos: **contexto** (proyecto adoptante y fase) · **lección** (qué falló o qué mejoró) · **evidencia** (archivo, comando, salida) · **cambio propuesto al corpus** (archivo y parche).
3. Triaje interno: la lección va a `docs/NN` + ADR si toca el contrato; los cambios materiales exigen ronda adversarial registrada antes de cerrarse.

## Servicio honesto

- Maintainer único: best effort, **sin SLA**. Ningún issue tiene fecha de respuesta prometida.
- No se aceptan PRs directos al corpus de terceros: primero la lección, después el parche.

## Cómo actualiza su copia un adoptante

1. Contrasta la revisión de tu copia (`git rev-parse HEAD` o tu fecha de copia) contra el último commit de este repo.
2. Corre `scripts/verify-corpus.sh` en tu copia: comprueba que nadie la tocó localmente.
3. Re-copiar es responsabilidad del consumidor: compara con `diff -ru` y revisa tus ADRs locales antes de sobrescribir; tus decisiones locales nunca las sobrescribe el upstream.
