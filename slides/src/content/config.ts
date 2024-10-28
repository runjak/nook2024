import { z, defineCollection } from "astro:content";

const slideCollection = defineCollection({
  type: "content",
  schema: z.object({ title: z.string() }),
});

export const collections = {
  slides: slideCollection,
};
