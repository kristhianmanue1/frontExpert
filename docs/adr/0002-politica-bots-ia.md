# ADR-0002 · Política de bots de IA

- **Estado:** aceptado (sesión 21-oct) · **Fecha:** 2026-10-17

## Contexto
El spec recibido propone que un middleware detecte por User-Agent a los bots de IA (GPTBot, ClaudeBot, etc.) y les entregue "contenido limpio **sin pasar por auth de sesión**".

## Problema
1. **El User-Agent no autentica nada.** Cualquier cliente puede enviar `User-Agent: ClaudeBot`. La regla convierte un header falsificable en un bypass de autenticación.
2. En Next 16 el middleware ahora es `proxy.ts`, y en 2026 se publicó un CVE de bypass del proxy (CVE-2026-64642). Poner la autorización en esa capa ya era desaconsejado.
3. Servir contenido distinto según el UA puede considerarse **cloaking** según las políticas de spam de Google.
4. La lista incluía nombres que no son User-Agents (`Google-Extended` es un token de robots.txt) o que están deprecados (`Claude-Web`).

## Decisión
- El contenido **público** se sirve igual a humanos y bots, en HTML semántico SSR/SSG.
- El contenido **privado** nunca se sirve sin sesión, sin importar el User-Agent.
- El acceso de crawlers se controla con **`robots.txt`**, generado desde `packages/config/ai-bots.ts` y revisado cada trimestre.
- Si se necesita distinguir bots (rate-limit, analytics, bloqueo de scrapers), se hace con **verificación real** (verificación de bots del edge, rDNS + rangos publicados o Web Bot Auth / RFC 9421) y nunca para conceder acceso.
- Si en el futuro se quiere ofrecer contenido privado a agentes, se diseña una **API con credenciales propias** (OAuth o API key), no un bypass.

## Consecuencias
- Se elimina un vector de fuga de datos.
- Se elimina el riesgo de penalización SEO.
- Se pierde la idea de "contenido limpio para bots". Se compensa con HTML semántico, JSON-LD y, como experimento, WebMCP.
