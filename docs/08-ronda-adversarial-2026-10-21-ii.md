# 08 — Ronda adversarial del contrato de adopción (2026-10-21, II)

**Objeto:** los parches P1–P7 del cierre del issue #1 — punto 4 (escalera de precedencia), punto 6 (mecanismo de devolución de lecciones) y punto 7 (oferta conjunta con skevi). **Método:** revisor adversarial de contexto fresco (subagente independiente; no ve el razonamiento, solo la propuesta y el repo), solo lectura, veredictos por parche anclados a archivo + cita, hallazgos H sobre los parches y N nuevos; **re-verificación independiente de las refutaciones duras por la sesión** antes de parchear (las cuatro confirmadas: ADR-0013 §Decisión 2, handoff §Repo, `docs/03` §Estructura, cabecera de `verify-corpus.sh`). Estado base: `c0bc4f2` (lote ADR-0013, manifiesto de 27 archivos en verde). Anclas por texto, no por número de línea (lección H3 de esta misma ronda).

## Veredictos por parche

| Parche | Contenido | Veredicto | Corrección adoptada |
|---|---|---|---|
| P1 | Escalera en `plantillas/AGENTS.md` | DUDOSO (H1, H2, H3) | peldaño 5 condicional; reglas reescritas; ancla por texto |
| P2 | `AGENTS.md` raíz canario | DUDOSO (H4) | incluido en el manifiesto |
| P3 | `CONTRIBUTING.md` | SÓLIDO (H7) | precondición de repo público |
| P4 | Plantilla de issue + comando de manifiesto | DUDOSO (H4) | comando ampliado |
| P5 | Sección skevi en README | DUDOSO (H6) | cifras sin ancla eliminadas |
| P6 | README (pasos, tabla, inventario) | DUDOSO (N1) | inventario y filas recalculados |
| P7 | `docs/08` (este registro) | SÓLIDO (N3) | checklist mecánico aplicado |

## Hallazgos y resolución

- **H1 (refutado → corregido):** el peldaño 5 tal como se propuso («Método skevi: transversal») contradice la independencia declarada en ADR-0013 —que rechazó el mecanismo ADR-032 por «dependencia encubierta que contradice la independencia de ambos cuerpos»— y la separación que el propio P5 declara. **Corregido:** el peldaño 5 existe solo si el adoptante también adoptó skevi.
- **H2:** la escalera se invertía a sí misma (gana el peldaño más alto, pero «planos no pisables» bloqueaba 4→5), y el choque entre el peldaño 1 y las «Reglas duras» de la plantilla («No hagas merge. No despliegues.») quedaba sin regla. **Corregido:** debilitar un plano exige ADR local del adoptante antes de actuar; una instrucción del humano que choque con una regla dura se confirma explícitamente antes de actuar.
- **H3:** anclas posicionales frágiles — esta ronda misma lo demostró (cita de línea de README desplazada entre iteraciones; precedente: ADR-0013 corrigiendo la línea «0001–0012» del README). **Corregido:** citas por texto, no por número.
- **H4:** `AGENTS.md` raíz quedaría fuera del manifiesto (el comando solo cubría `README.md LICENSE docs fuente plantillas scripts`) y un punto de entrada del agente sin hash viola el régimen de ADR-0013. **Corregido:** comando ampliado a `README.md LICENSE AGENTS.md CONTRIBUTING.md .github docs fuente plantillas scripts`.
- **H5 (deuda preexistente, agravada por el lote):** la lista de copia del contrato (README «Siguientes pasos» #1 y ADR-0012 §Decisión) no incluía `README.md`/`LICENSE`: una copia literal del contrato fallaba `verify-corpus.sh` (fail-closed ante archivo faltante). **Corregido:** el contrato ahora dice «todo lo que cubre el manifiesto» y lista los nueve elementos; enmienda registrada aquí (práctica de ADR-0013).
- **H6:** «skevi mínimo ~400 líneas», «la combinación nunca se ha ejecutado» y las letras «D→A→C» carecen de ancla en este corpus (el análisis de origen no está en el repo; «~400» colisiona además con el límite de tamaño de PR de `docs/03`) — el patrón exacto que el README critica del spec recibido («cifras sin fuente»). **Corregido:** cifras y letras eliminadas; «skevi mínimo» se declara definida fuera de este corpus; la honestidad se formula como «no consta ejecución a la fecha».
- **H7:** CONTRIBUTING asumía issues abribles por terceros, pero el repo es **privado** (handoff §Repo; ADR-0013 §Procedencia). **Corregido:** precondición explícita y canal interno del dueño mientras sea privado.
- **N1:** inventario y tabla del README desfasados con el lote (+4 archivos). **Corregido:** recalculados — 28 archivos de documentación y plantillas + licencia + 2 scripts + plantilla de issue + manifiesto; 31 archivos con hash.
- **N2:** la escalera omitía los `AGENTS.md` locales del adoptante (`docs/03` §Estructura: «`AGENTS.md` locales en `apps/web`, `apps/native` y `packages/ai`»). **Corregido:** el peldaño 2 incluye raíz y locales.
- **N3:** checklist mecánico de cierre. **Aplicado:** manifiesto regenerado en el mismo commit, filas de tabla añadidas, handoff reescrito, anclas por texto.

## Estado tras la ronda

- **Issue #1 cerrado:** los 7 puntos atendidos — 1 (LICENSE), 2 (manifiesto), 3 (ADRs fantasma) y 5 (reclasificación de `verify-stack.sh`) en `c0bc4f2` (ADR-0013); 4 (precedencia + `AGENTS.md` canario), 6 (`CONTRIBUTING.md` + plantilla de issue) y 7 (sección skevi) en este lote.
- Manifiesto en 31 archivos; `verify-corpus.sh` en verde.
- Deuda nueva registrada: ninguna. El contrato de adopción queda congelado salvo lección de adoptante por el canal de `CONTRIBUTING.md`; el siguiente hito del playbook es la **primera adopción** (el manual se estrena con ella).
