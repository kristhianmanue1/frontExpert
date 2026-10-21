# Spec base recibido (copia literal para trazabilidad)

> Documento tal como se recibió el 2026-10-17. **No editar.** Las correcciones están en `docs/01-analisis-critico.md` y la propuesta en `docs/02-spec-v2.md`.
> Nota: el original contiene restos de conversación con un chatbot ("¿Quieres que le agregue…?", "Adelante.") y números escritos con letra ("diecinueve punto dos"). Eso ya indica que no pasó por revisión técnica.

---

SPEC BASE — FRONTEND AGENT-READY STACK 2026

Lenguaje: TypeScript estricto en todo el monorepo. Sin JavaScript suelto.

Framework UI: React diecinueve punto dos. Server Components estabilizados, React Compiler activo, View Transitions disponibles.

Meta-framework web: Next.js dieciséis con Turbopack como bundler estable por defecto. App Router. Middleware para detección de user-agents de bots de IA verificados: GPTBot, OAI-SearchBot, ChatGPT-User, ClaudeBot, Claude-Web, claude-user, PerplexityBot, Google-Extended. Esos reciben contenido limpio sin pasar por auth de sesión.

Estilos: Tailwind CSS con design tokens como CSS variables. Sin CSS-in-JS en runtime.

Componentes: shadcn punto ui. No es dependencia, es código copiado al repo en packages/ui, versionado y modificable por el agente.

Agentes en el front: Vercel AI SDK versión seis o superior. Abstracción ToolLoopAgent, streaming con createAgentUIStreamResponse, hooks de React para UI. Tool calling con needsApproval para acciones que requieren confirmación humana. Provider-agnostic: OpenAI, Anthropic, Google, Bedrock, intercambiables en una línea.

Backend de agentes, si se necesita: Mastra para agentes, memoria, RAG y workflows en TypeScript nativo con integración Next.js. LangGraph punto js solo si hay flujos de estado cíclicos complejos. OpenAI Agents SDK solo si el equipo se compromete exclusivamente a OpenAI.

Agentes embebidos en UI existente: CopilotKit para React, Vue o Angular.

Monorepo: Turborepo con workspaces. Tres paquetes: apps/web con Next.js, packages/ui con shadcn, packages/core con tipos, cliente de API y validaciones Zod. apps/native con Expo para móvil.

Móvil: Expo con React Native en New Architecture, Expo Router con file-based routing idéntico al web, Nativewind para Tailwind en nativo, EAS Build en la nube. Se comparte la capa no visual: tipos, API client, validaciones, modelos de dominio. La UI nativa se trata como trabajo nuevo.

MCP servers del loop de desarrollo: DesignRevision para instalar componentes reales de shadcn. Context7 para documentación actualizada del framework. Playwright para que el agente pruebe en navegador real. Chrome DevTools para inspección de DOM, consola y red. Figma MCP Server si se trabaja desde diseños: get_design_context, get_variable_defs, get_code_connect_map. GitHub MCP para issues y PRs. Filesystem MCP con sandbox. Sequential Thinking para planificación de UI compleja.

Agent-ready del sitio: archivo llms punto txt en la raíz con resumen machine-readable, complementando sitemap punto xml. HTML semántico servido desde el primer request, sin depender de JavaScript para contenido principal. WebMCP emergente: registrar tools en document punto modelContext para que agentes visitantes consuman el sitio con veintisiete veces menos tokens.

Seguridad: credenciales de MCP solo en variables de entorno o secret manager. Nunca en settings.json. Servidores de base de datos en modo solo lectura salvo que se requiera escritura explícita.

Criterio de decisión de framework: no se elige por popularidad actual, se elige por volumen de datos de entrenamiento y estabilidad de convenciones. React gana hoy por eso. Svelte es la apuesta de segunda generación por ser más explícito y compacto, con su propio MCP tool para mejorar precisión del código generado.

## FASES DE ITERACIÓN

Fase uno, fundación. Scaffold del monorepo con Turborepo, Next.js dieciséis, Tailwind, shadcn copiado en packages/ui, y packages/core con tipos y Zod. Una sola página de landing estática con HTML semántico y el llms punto txt. Sin autenticación, sin API, sin estado. El agente solo aprende la estructura y las convenciones del repo.

Fase dos, interactividad. Componentes con estado local en React, formularios con useActionState, validación en cliente y servidor con Zod. Routing con App Router. Todavía sin backend propio: datos mock o un JSON estático. El agente practica editar componentes existentes sin romper imports ni tokens.

Fase tres, datos reales. API routes en Next.js o un backend separado con FastAPI si el agente necesita orquestación en Python. Conexión del AI SDK: un endpoint de chat con streaming, un ToolLoopAgent con dos o tres tools de solo lectura. UI de chat con useChat. Aquí el agente aprende el patrón de tool calling y structured outputs.

Fase cuatro, agentes con efectos. Tools con needsApproval para acciones que mutan datos. Workflows con Mastra si el flujo tiene pasos, reintentos o memoria. Human-in-the-loop en la UI. Playwright MCP activo para que el agente verifique cada cambio en navegador antes de cerrar la tarea.

Fase cinco, móvil. apps/native con Expo, Expo Router, Nativewind. Se migra solo packages/core y se reescriben las pantallas en React Native. La paridad de features se valida con el agente comparando screenshots y eventos de analytics entre web y nativo, no con código compartido de UI.

Fase seis, agent-ready público. WebMCP con tools registradas en document punto modelContext. Middleware de bots de IA. Auditoría de accesibilidad y performance. El sitio ya no solo es para humanos: es una API para agentes.

Regla transversal en todas las fases: cada iteración es un commit pequeño y revisable. El agente nunca reescribe el repo completo; extiende. Si una fase requiere un cambio arquitectónico que rompa la anterior, se documenta como decisión en el repo antes de ejecutarse, no después.

## ANTI-PATRONES

No inventar componentes cuando shadcn ya tiene uno. Si el agente necesita un botón, un card o un input que ya existe en el registry, lo instala con DesignRevision MCP en lugar de escribirlo desde cero. Código duplicado es deuda que el agente hereda en cada iteración.

No usar CSS-in-JS en runtime. styled-components, Emotion o cualquier librería que inyecte estilos al vuelo. Rompe el modelo de compilación de Svelte-like, infla el bundle y hace que el agente no pueda predecir qué CSS termina en el DOM. Tailwind con variables CSS es el único camino.

No hardcodear colores, espaciados o tipografía. Todo pasa por design tokens. Si el agente ve un valor mágico en un componente, lo reemplaza por la variable correspondiente o crea el token si no existe. Sin tokens, cada cambio de tema es un refactor manual.

No mezclar paradigmas de estado. Si el proyecto usa Server Components, no meter useState en un componente de servidor. Si usa TanStack Query para datos remotos, no duplicar esa lógica con fetch manual en cada página. Un patrón de datos por capa, documentado en packages/core.

No saltarse la validación. Todo input del usuario, todo output de un tool, todo response de API pasa por Zod. El agente que asume que los datos vienen bien es el que produce bugs silenciosos que solo aparecen en producción.

No commitear secretos. API keys, tokens de MCP, connection strings: solo variables de entorno. Si el agente genera un archivo de config con un valor sensible embebido, se rechaza el commit.

No reescribir archivos enteros para un cambio de tres líneas. El diff mínimo es la métrica. Un agente que toca cincuenta líneas para cambiar una es un agente que no entendió el contexto, y eso escala mal con el tamaño del repo.

No ignorar errores de hidratación. Si el HTML del servidor no coincide con lo que React renderiza en cliente, hay un bug de estado inicial. El agente debe tratarlo como bloqueante, no como warning cosmético.

No construir features que no pidieron. Scope creep es el enemigo número uno en iteración con agentes: cada prompt debe mapear a una fase del spec y a un commit. Si el agente propone algo extra, se registra como idea, no se implementa.

No depender de magia implícita. Contextos, providers y wrappers ocultos dificultan que el agente rastree de dónde viene un valor. Preferir props explícitas y composición visible.

## CRITERIOS DE ACEPTACIÓN POR FASE

Fase uno. El monorepo compila sin errores con Turbopack. Existe packages/ui con al menos tres componentes de shadcn instalados vía DesignRevision MCP. Existe packages/core con al menos un tipo, un schema Zod y un cliente de API tipado. La landing renderiza HTML semántico verificable con un validador, y el llms punto txt responde doscientos en la raíz. Cero dependencias de CSS-in-JS en el package.json.

Fase dos. Los formularios validan en cliente y servidor con el mismo schema Zod, sin duplicar reglas. useActionState maneja el estado del form sin librerías externas. El routing de App Router cubre al menos cuatro rutas con layouts anidados. Un cambio de token en packages/ui se refleja en todas las páginas sin tocar componentes individuales. El diff de cualquier feature nueva no excede veinte líneas fuera de su propio archivo.

Fase tres. El endpoint de chat streamea tokens en menos de un segundo al primer chunk. Un ToolLoopAgent ejecuta al menos dos tools de solo lectura y devuelve structured output validado con Zod. useChat actualiza la UI sin re-renders innecesarios, medible con React DevTools. Si un tool falla, el error llega al usuario como mensaje, no como stack trace.

Fase cuatro. Toda tool con needsApproval pausa la ejecución hasta confirmación visual en la UI. Playwright MCP pasa un test de smoke en cada commit de esta fase: la página carga, el chat responde, un tool de solo lectura retorna datos. Mastra persiste el estado de un workflow de dos pasos entre reinicios del servidor. No hay tool que mute datos sin pasar por el gate de aprobación.

Fase cinco. apps/native comparte packages/core sin modificaciones. Expo Router replica la estructura de rutas del web. Nativewind aplica los mismos tokens de Tailwind. EAS Build produce un artefacto de iOS y Android en la nube sin toolchain local. El agente genera un reporte de paridad: pantallas, flujos y eventos de analytics comparados entre web y nativo.

Fase seis. WebMCP registra al menos una tool en document punto modelContext y un agente externo la descubre y la ejecuta. El middleware de bots sirve contenido limpio a los user-agents listados. Lighthouse marca accesibilidad arriba de noventa y performance arriba de ochenta en la landing. El sitio responde a un prompt de un agente de búsqueda con citas correctas al contenido.

Criterio global: cada fase cierra con un commit que pasa CI, un diff revisable y una entrada en el changelog del repo. Si algo no cumple, no se avanza de fase.
