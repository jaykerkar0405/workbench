<script lang="ts">
	import './layout.css';
	import { ModeWatcher } from 'mode-watcher';
	import { afterNavigate, onNavigate } from '$app/navigation';
	import Header from '$lib/components/header.svelte';
	import Footer from '$lib/components/footer.svelte';

	let { children } = $props();

	onNavigate((navigation) => {
		if (
			navigation.willUnload ||
			typeof document.startViewTransition !== 'function' ||
			window.matchMedia('(prefers-reduced-motion: reduce)').matches ||
			navigation.from?.url.pathname === navigation.to?.url.pathname
		) {
			return;
		}

		// html has scroll-behavior: smooth, which would make the scroll reset animate underneath
		// the frozen snapshot and keep scrolling after the fade ends. Reset instantly while the
		// transition runs.
		const root = document.documentElement;
		root.style.scrollBehavior = 'auto';

		return new Promise<void>((resolve) => {
			const transition = document.startViewTransition(async () => {
				resolve();
				await navigation.complete;
			});

			// A skipped or superseded transition rejects these promises; navigation itself is unaffected.
			transition.ready.catch(() => {});
			transition.updateCallbackDone.catch(() => {});
			transition.finished.catch(() => {}).finally(() => root.style.removeProperty('scroll-behavior'));
		});
	});

	// Scroll to the top after a normal navigation. Leave the position alone on back/forward (SvelteKit
	// restores it), on links that carry a hash (the browser scrolls to the target), and when only the
	// query or hash changed.
	afterNavigate((navigation) => {
		if (
			navigation.type === 'popstate' ||
			navigation.to?.url.hash ||
			navigation.from?.url.pathname === navigation.to?.url.pathname
		) {
			return;
		}
		window.scrollTo({ top: 0 });
	});
</script>

<ModeWatcher />

<div class="relative max-lg:pb-[calc(6rem+env(safe-area-inset-bottom))]">
	<Header />

	<main>
		{@render children()}
	</main>

	<Footer />
</div>
