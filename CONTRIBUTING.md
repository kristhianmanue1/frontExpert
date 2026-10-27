# CONTRIBUTING — Devolución de lecciones de adopción

El contrato de adopción (ADR-0012) dice «devuelve las lecciones upstream». Esta página dice por dónde (issue #1, punto 6; ronda registrada en `docs/08`).

> **Precondición — cumplida:** el repo es **público** desde el 21-oct-2026; los terceros ya pueden abrir issues de lección. (Historia: mientras fue privado, las lecciones se recogían por el canal interno del dueño; procedencia: ADR-0013.)

## Cómo se devuelve una lección

1. Abre un **issue** en este repo (no un PR) con la plantilla «Lección de adopción» (`.github/ISSUE_TEMPLATE/`).
2. Campos fijos: **contexto** (proyecto adoptante y fase) · **lección** (qué falló o qué mejoró) · **evidencia** (archivo, comando, salida) · **cambio propuesto al corpus** (archivo y parche).
3. Triaje interno: la lección va a `docs/NN` + ADR si toca el contrato; los cambios materiales exigen ronda adversarial registrada antes de cerrarse.

## Servicio honesto

- Maintainer único: best effort, **sin SLA**. Ningún issue tiene fecha de respuesta prometida.
- No se aceptan PRs directos al corpus de terceros: primero la lección, después el parche.

## El manifiesto del adoptante (ADR-0014)

La verificación del adoptante es contra su **propio manifiesto**, no contra el canario upstream (que describe este playbook, no tu derivado):

1. Genera tu manifiesto como **último paso** de la adopción (y tras cada enmienda): formato `shasum -c` sobre una lista explícita de rutas.
2. **Fuera** de la lista (cambian siempre): `README.md`, `AGENTS.md`, `docs/handoff.md` (nace de `plantillas/handoff.md`) y tus ADRs enmendados o nuevos. **Dentro, con digest propio:** tu `LICENSE` (compatibilidad Apache-2.0) y el resto del corpus copiado.
3. **Depósito documentado obligatorio:** la lista y el comando de regeneración viven en la cabecera de tu copia de `verify-corpus.sh` o en tu propio CONTRIBUTING — la regla «cambio a ruta listada ⇒ regenerar en el mismo commit» solo es auditable si el comando está escrito.

## Cómo actualiza su copia un adoptante

1. Contrasta la revisión de tu copia (`git rev-parse HEAD` o tu fecha de copia) contra el último commit de este repo.
2. Corre `verify-corpus.sh` **contra tu manifiesto** (por argumento o `CORPUS_MANIFEST`; ADR-0014): comprueba que nadie tocó tu derivado localmente.
3. Re-copiar es responsabilidad del consumidor: compara con `diff -ru` y revisa tus ADRs locales antes de sobrescribir; tus decisiones locales nunca las sobrescribe el upstream.
