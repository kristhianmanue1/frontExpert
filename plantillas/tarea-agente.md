# Tarea para agente — plantilla de issue

**Fase del spec:** <!-- 1..6 -->
**Paquetes afectados:** <!-- apps/web, packages/core, ... -->
**ADRs relacionados:** <!-- docs/adr/000X -->

## Objetivo (una frase, comportamiento observable)
<!-- Ej: "El formulario de contacto muestra errores por campo al enviar datos inválidos y guarda el mensaje si son válidos." -->

## Criterios de aceptación
- [ ] <!-- verificable, con comando o test -->
- [ ] 
- [ ] 

## Fuera de alcance
- <!-- lo que NO debe tocar -->

## Restricciones
- Dependencias nuevas permitidas: <!-- ninguna / lista -->
- Archivos protegidos: <!-- ... -->
- Tamaño esperado: <!-- < 200 líneas -->

## Verificación (pega la salida en el PR)
```bash
pnpm turbo run typecheck lint test --filter=...
pnpm --filter web exec playwright test <spec>
```
