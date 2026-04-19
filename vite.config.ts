import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';
import { sveltekit } from '@sveltejs/kit/vite';
import { enhancedImages } from '@sveltejs/enhanced-img';

export default defineConfig({
	cacheDir: '.vercel/cache/vite',
	plugins: [tailwindcss(), enhancedImages(), sveltekit()]
});
