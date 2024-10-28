// @ts-check
import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";

export default defineConfig({
  site: "https://nook2024.runjak.codes",
  prefetch: {
    /**
     * Enabling prefetching for ViewTransitions.
     *
     * https://docs.astro.build/en/reference/configuration-reference/#prefetchprefetchall
     * https://docs.astro.build/en/guides/view-transitions
     */
    prefetchAll: true,
  },
  integrations: [mdx()],
});
