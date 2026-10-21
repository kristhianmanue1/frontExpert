# 07 — Segunda ronda adversarial (revisor de contexto fresco, 2026-10-21)

**Objeto revisado:** los hallazgos H1–H9 y propuestas P1–P8 del análisis propio del preproyecto (no el spec base). **Método:** subagente independiente en contexto fresco (no ve el razonamiento, solo la lista de afirmaciones), solo lectura, cada veredicto anclado a archivo + sección + cita, y las ausencias verificadas con grep. Los hallazgos nuevos N1–N3 se re-verificaron de forma independiente antes de parchear. Ancla de estado: commit `5727ea5`, tag `docs-v0.1` (corpus tal como se revisó; SHA-256 de los trece archivos en el registro de la sesión).

**Escala:** ✅ confirmado · ⚠️ matizado (cierto, pero mal calibrado o ya cubierto en parte) · ❌ refutado.

## Veredictos

| ID | Afirmación | Veredicto | Evidencia clave | Efecto |
|---|---|---|---|---|
| H1 | El proyecto no es un repo git | ✅ | `git status` → *not a git repository*; el corpus presupone git+PR (`03 §3`, `02 §9`) | P1 aplicado: commit base + tags `docs-v0.1`/`docs-v0.2` |
| H2 | Previews por PR sin aislamiento de secretos | ✅ | `02 §9`: deploy "por PR… CI, automático"; grep de sandbox/dummy/tope = 0 | P2 aplicado a `02 §9`, extendido al canal EAS móvil; riesgo R16 añadido |
| H3 | La ruta crítica son decisiones humanas | ⚠️ | 7 preguntas (`04`) y ADRs sin cerrar confirmados. **Matiz:** la puerta de fase 0 (`02 §6`) exige los ocho ADRs | P3 rework: incluye 0004/0008; arrancar sin los ocho exige **enmendar la puerta**, no agotar plazo |
| H4 | Sin política de flaky tests | ✅ | grep flaky/cuarentena = 0; el anti-patrón 15 agrava (prohíbe el `skip` sin salida legítima) | P4 aplicado a `03 §8` |
| H5 | Spike ADR-0009 sin time-box/default | ⚠️ | `02 §10` ya exige time-box genérico para todo spike; solo falta el default | Severidad a medio-bajo; P5 aplicado (default fijado en `04`) |
| H6 | Tabla de ADRs desordenada + sin plantilla | ✅ | `04`: fila 0009 antes que 0008; `plantillas/` sin adr.md | P6 aplicado: reordenado + `plantillas/adr.md` |
| H7 | Persistencia del registro de aprobaciones no declarada en ADR-0003 | ⚠️ | R12 ya declara el fondo; faltaba solo en la fila del ADR | Severidad a bajo; P7 aplicado (nota en la fila 0003) |
| H8 | `llms.txt` con estatus dual | ✅ | `01 §3.1` ("no como criterio de calidad") vs `02 §6` fase 1 (criterio de aceptación) | Alineado `01 §3.1`: el criterio de fase 1 es solo de existencia |
| H9 | Vitest/TanStack/ESLint sin verificar en `06` | ✅ | grep en `06`; también el CLI de shadcn ("latest") y la major ambigua de Vitest | Pendiente para `scripts/verify-stack.sh` (fase 0) |

**Balance de propuestas:** ninguna refutada. P1, P4–P8 confirmadas; P2 corregida (faltaba el canal EAS móvil); P3 ampliada (0004 y 0008 también cierran baratos, con recomendación ya escrita en `04`).

## Hallazgos nuevos (re-verificados de forma independiente)

| ID | Sev | Hallazgo | Evidencia | Parche |
|---|---|---|---|---|
| N1 | 🟠 | `01 §1.15` seguía afirmando "v5 estable" sin corregir; dejaba falsa la frase de `06` ("todas las rectificaciones aplicadas en `01`") | `01 §1.15` vs `01 §1.6`, `06 §A`, ADR-0009 | Corregido en `01 §1.15` |
| N2 | 🟡 | El árbol de `02 §2` omitía `docs/handoff.md` (exigido por `03 §6` y la plantilla de AGENTS.md) y `docs/spikes/` (`02 §10`); runbooks sin `rollback.md` (`02 §9`) | grep handoff/spikes en `02` | Árbol completado en `02 §2` |
| N3 | 🟡 | INP < 200 ms prometido en `01 §8` nunca llegó al gate de fase 1 (solo LCP/CLS) | grep INP = única aparición en el corpus | INP añadido al gate de `02 §6` |
| N4 | 🟢 | `FUENTES.md` no trazaba las versiones corregidas (16.3 → 16.4.2; SDK 58) ni el método primario de `06`; R11 fuera de orden en `04` | `FUENTES.md` §Frameworks/§Móvil; `04` registro de riesgos | FUENTES actualizada + sección de verificación primaria; R11 reordenado |

## Parches aplicados en esta ronda

| Archivo | Cambio |
|---|---|
| `docs/01-analisis-critico.md` | §1.15 corregido (N1) · §3.1 `llms.txt` alineado (H8) |
| `docs/02-spec-v2.md` | §2 árbol con `handoff.md`, `spikes/` y `rollback.md` (N2) · §6 gate con INP y ambiente declarado (N3, P4) · §9 aislamiento de previews web + EAS móvil (P2) |
| `docs/03-loop-agentes.md` | §8 política de flaky/cuarentena + Lighthouse CI en ambiente declarado (P4) |
| `docs/04-riesgos-y-decisiones.md` | Orden 0008→0009 y R11 (P6, N4) · nota de persistencia transaccional en ADR-0003 (P7) · time-box de 2 días + default en ADR-0009 (P5) · riesgo R16 nuevo (previews por PR) |
| `docs/FUENTES.md` | Next 16.4.2 y Expo SDK 58 trazados · nueva sección de verificación primaria (N4) |
| `plantillas/AGENTS.md` | Convención de idiomas: docs/comunicación en español, código/commits/lint en inglés (P8) |
| `plantillas/adr.md` | Nuevo: plantilla MADR corto, modelo `adr/0002` (P6) |
| `README.md` | Fila de esta ronda en el resumen y en la tabla de contenido |

## Estado del repositorio tras la ronda

- El corpus pasó a control de versiones: `5727ea5` = estado revisado (tag `docs-v0.1`); este lote de parches es el segundo commit (tag `docs-v0.2`). **Sin remoto todavía**: crearlo, proteger `main` (PR obligatorio, CI requerido, 1 revisión humana) y dar acceso al agente sin push a `main` sigue siendo tarea humana.
- Quedan fuera de este lote, por ser decisiones humanas: cerrar los ADRs 0001–0008 (0004 y 0008 con recomendación lista en `04`), responder las 7 preguntas abiertas, reclamar los 25 hallazgos individuales de la primera ronda (`05`) y crear el remoto. Para arrancar la fase 1 sin los ocho ADRs, primero se enmienda la puerta de fase 0 (`02 §6`) con un ADR.

SHA-256 del corpus parcheado en el tag `docs-v0.2` (excluido este archivo; los cambios posteriores —ADR-0010, recorte de previews— viven en su propio commit):

```
c3482645890e231f1a219718474afa1a5111c168a49feb902e9446c50ba796a9  README.md
d3f88293fda93e82b50f99241c75f279555b7c46bad9eac56df603d1a0a27566  docs/01-analisis-critico.md
3f262e89171fce39bb1210f943657cbff082dcc0807cec0bb066261841b48945  docs/02-spec-v2.md
a96cb9a275f833c6f04453670ec8d96dbdaf434b625a944ea019aa6277801a21  docs/03-loop-agentes.md
12906ea878bf9e1854935440b92450fad494639589001de80c99fc0e62966e81  docs/04-riesgos-y-decisiones.md
2082d3e351a8452d16fa0faa4ce753f5d57d911b6fa7d556f8c94d5a2d55447a  docs/FUENTES.md
eb7933a4fd303504505d317ae87df9069e396fdba97c3013146941c3d12b3065  plantillas/AGENTS.md
b35e053e973628dbd74cc7b605b03c8449aaa1fd4f39edb6130d56f02de8f99e  plantillas/adr.md
```
