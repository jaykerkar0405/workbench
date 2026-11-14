import { mdsvex } from 'mdsvex';
import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter({ fallback: '404.html' }),
		prerender: {
			handleHttpError: ({ path, message }) => {
				const ignoredPaths = ['/projects/', '/hackathons/'];

				if (ignoredPaths.some((p) => path.startsWith(p))) {
					return;
				}

				throw new Error(message);
			}
		}
	},
	extensions: ['.svelte', '.svx'],
	preprocess: [vitePreprocess(), mdsvex()]
};

export default config;
