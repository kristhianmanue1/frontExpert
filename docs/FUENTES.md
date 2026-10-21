# Fuentes consultadas (2026-10-17)

> Algunas son fuentes primarias (nextjs.org, react.dev, expo.dev, shadcn, Anthropic) y otras son reportes secundarios. Las cifras secundarias se marcan como tales en el análisis. Hay que revalidarlas antes de citarlas externamente.

## Frameworks y versiones
- Next.js 16.3: https://nextjs.org/blog/next-16-3
- Next.js 16 (proxy.ts, Turbopack): https://makerkit.dev/blog/md/tutorials/nextjs-16
- CVE-2026-64642 (bypass de middleware/proxy): https://osv.dev/vulnerability/CVE-2026-64642 · https://advisories.gitlab.com/npm/next/CVE-2026-64642/
- Next.js y agentes de IA (docs empaquetadas, AGENTS.md): https://nextjs.org/docs/app/guides/ai-agents
- Next.js Evals: https://www.nextjs.org/evals
- React 19.3 (ViewTransition estable): https://react.dev/blog/2026/09/09/react-19-3
- React Labs (View Transitions, Activity): https://react.dev/blog/2025/04/23/react-labs-view-transitions-activity-and-more
- TypeScript 7 GA: https://infoq.com/news/2026/08/typescript-7-released/
- Tailwind CSS 4.2: https://infoq.com/news/2026/04/tailwind-css-4-2-webpack
- Tailwind releases: https://releases.sh/tailwind-css/tailwind-css.md

## IA en producto
- AI SDK 6 (ToolLoopAgent, needsApproval): https://ai-sdk.dev/docs/announcing-ai-sdk-6-beta
- AI SDK 7 (WorkflowAgent): https://buttondown.com/madsford22/archive/vercel-ai-sdk-7-figma-config-2026-and-langchains/ · https://www.issoh.co.jp/tech/details/10402/
- AI SDK, tools y aprobación (`toolApproval`, `needsApproval` deprecado): https://ai-sdk.dev/docs/ai-sdk-core/tools-and-tool-calling
- Mastra 1.0: https://hn.svelte.dev/item/46693959

## Móvil
- Expo SDK 55 (fin de Legacy Architecture): https://expo.dev/changelog/sdk-55
- Expo SDK 56: https://expo.dev/changelog/sdk-56
- Expo SDK 57: https://expo.dev/changelog/sdk-57
- NativeWind v5: https://www.nativewind.dev/v5/guides/migrate-from-v4
- Expo MCP Server: https://expo.dev/blog/become-an-ai-native-developer-with-the-expo-mcp-server · https://docs.expo.dev/eas/ai/mcp.md

## MCP y loop de desarrollo
- shadcn MCP oficial: https://ui.shadcn.com/docs/mcp
- Monorepo en shadcn: https://ui.shadcn.com/docs/changelog/2024-12-monorepo
- DesignRevision MCP: https://designrevision.com/mcp
- Seguridad MCP (CSA): https://labs.cloudsecurityalliance.org/agentic/agentic-mcp-security-best-practices/
- Vulnerabilidades MCP: https://www.practical-devsecops.com/mcp-security-vulnerabilities/
- CVE-2025-9611 (Playwright MCP, DNS rebinding): https://advisories.gitlab.com/npm/@playwright/mcp/CVE-2025-9611/
- Seguridad de tools WebMCP (Chrome): https://developer.chrome.com/docs/ai/webmcp/secure-tools
- Tool poisoning: https://codex.danielvaughan.com/2026/05/27/mcp-tool-poisoning-codex-cli-defence-patterns-hook-gating-registry-trust/

## Agent-ready y bots
- WebMCP (cambio a document.modelContext): https://mcpplaygroundonline.com/blog/what-is-webmcp · https://dev.to/jangwook_kim_e31e7291ad98/webmcps-origin-trial-providecontext-is-already-gone-54j8
- Cifras de tokens de WebMCP: https://capitalandcompute.net/blog/webmcp-token-savings/ · https://arxiv.org/pdf/2508.09171
- llms.txt (97 % sin peticiones): https://ppc.land/llms-txt-adoption-rises-8-8x-but-97-of-files-get-zero-ai-requests/
- Common Crawl sobre llms.txt: https://commoncrawl.org/blog/a-content-analysis-of-llms-txt-files-from-the-july-2026-crawl-archive
- Crawlers de Anthropic: https://support.claude.com/en/articles/8896518
- Spoofing y verificación de bots: https://arcjet.com/learn/detect-bot-spoofing · https://modpagespeed.com/blog/verify-ai-crawlers-web-bot-auth/
- Cloaking: https://www.brightedge.com/glossary/what-is-cloaking
