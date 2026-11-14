<script lang="ts">
	import { page } from '$app/state';
	import Terminal from '$lib/components/terminal.svelte';

	const messages: Record<number, string> = {
		404: 'No such file or directory',
		500: 'Internal Server Error',
		503: 'Service Unavailable'
	};

	const message = $derived(messages[page.status] ?? 'Unexpected Error');

	// Anyone can type any path: it is only ever rendered as text, and a long one is shortened in the middle.
	const MAX_PATH = 80;
	const shown = $derived.by(() => {
		const pathname = page.url.pathname;
		if (pathname.length <= MAX_PATH) return pathname;
		const keep = MAX_PATH - 1;
		return `${pathname.slice(0, Math.ceil(keep / 2))}…${pathname.slice(pathname.length - Math.floor(keep / 2))}`;
	});

	// When the path was cut, the full value is available as a tooltip (it never appears in the visible text).
	const cut = $derived(shown !== page.url.pathname);

	const lines = $derived([`$ cd ${shown}`, `cd: ${message} (${page.status})`]);

	const link =
		'rounded-sm underline decoration-1 underline-offset-4 outline-none focus-visible:ring-3 focus-visible:ring-ring/50';
</script>

<svelte:head>
	<title>{page.status} · {message} | Jay Kerkar</title>
	<meta name="robots" content="noindex" />
</svelte:head>

<div
	class="mx-auto max-w-7xl px-5 pt-10 pb-20 md:px-10 lg:flex lg:min-h-[calc(100svh-var(--header-h))] lg:items-center lg:py-16"
>
	<div class="w-full max-w-2xl" title={cut ? page.url.pathname : undefined}>
		<h1 class="sr-only">{page.status} {message}</h1>
		<p class="mb-4 label" aria-hidden="true">Error {page.status}</p>

		<Terminal title="jay@mumbai: ~" {lines} typing={false}>
			<p>
				<span class="text-brand">$</span>
				<a href="/" class={link} aria-label="Go to the homepage">cd ~</a>
			</p>
			<p>
				<span class="text-brand">$</span> ls ~
				<a href="/projects" class={link} aria-label="Go to projects">projects/</a>
				<a href="/hackathons" class={link} aria-label="Go to hackathons">hackathons/</a>
			</p>
		</Terminal>
	</div>
</div>
