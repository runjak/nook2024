// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
    prefetch: {
        /**
         * Enabling prefetching for ViewTransitions.
         *
         * https://docs.astro.build/en/reference/configuration-reference/#prefetchprefetchall
         * https://docs.astro.build/en/guides/view-transitions
         */
        prefetchAll: true
    }
});
