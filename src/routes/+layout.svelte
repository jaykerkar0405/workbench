<script lang="ts">
	import './layout.css';
	import { ModeWatcher } from 'mode-watcher';
	import { afterNavigate } from '$app/navigation';
	import Header from '$lib/components/header.svelte';
	import Footer from '$lib/components/footer.svelte';
	import ScrollToTop from '$lib/components/scroll-to-top.svelte';

	let { children } = $props();

	afterNavigate(() => {
		window.scrollTo({ top: 0 });
	});
</script>

<ModeWatcher />

<div class="relative">
	<Header />

	<main>
		{@render children()}
	</main>

	<Footer />
	<ScrollToTop />
</div>
