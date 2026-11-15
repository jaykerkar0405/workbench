<script lang="ts">
	import { page } from '$app/state';
	import Terminal from '$lib/components/terminal.svelte';

	const messages: Record<number, string> = {
		404: 'No such file or directory',
		500: 'Internal Server Error',
		503: 'Service Unavailable'
	};

	const message = $derived(messages[page.status] ?? 'Unexpected Error');

	// Anyone can type any path: it is only ever rendered as text. A long one stays on one line and is cut in the middle by
	// CSS: the start is a flexible span that gets an ellipsis when it does not fit, the last END characters are fixed, so
	// the result is always "start…end" at whatever width the terminal has. The full path is the tooltip.
	const END = 12;
	const pathname = $derived(page.url.pathname);
	const long = $derived(pathname.length > END + 4);
	const start = $derived(long ? pathname.slice(0, -END) : pathname);
	const end = $derived(long ? pathname.slice(-END) : '');

	const link = 'rounded-sm link-underline outline-none focus-visible:ring-3 focus-visible:ring-ring/50';
</script>

<svelte:head>
	<title>{page.status} · {message} | Jay Kerkar</title>
	<meta name="robots" content="noindex" />
</svelte:head>

<!-- The block is centred in the visible area under the header: below lg the layout's bottom padding (the dock's
	clearance) is taken off the height, so on a phone it never sits under the dock. -->
<div
	class="mx-auto flex min-h-[calc(100svh-var(--header-h)-6rem-env(safe-area-inset-bottom))] w-full max-w-7xl items-center px-5 py-10 max-lg:pt-16 md:px-10 lg:grid lg:min-h-[calc(100svh-var(--header-h))] lg:grid-cols-12 lg:gap-x-6"
>
	<div class="w-full min-w-0 lg:col-span-7">
		<h1 class="sr-only">{page.status} {message}</h1>
		<p class="mb-4 label" aria-hidden="true">Error {page.status}</p>

		<Terminal title="jay@workbench: ~">
			<p class="flex whitespace-nowrap" title={long ? pathname : undefined}>
				<span class="text-muted-foreground">$</span>&nbsp;cd&nbsp;<span class="min-w-0 truncate">{start}</span><span
					class="shrink-0">{end}</span
				>
			</p>
			<p class="whitespace-nowrap">cd: {message} ({page.status})</p>
			<p class="whitespace-nowrap">
				<span class="text-muted-foreground">$</span>
				<span aria-hidden="true" class="cursor-blink text-brand">▊</span>
			</p>
		</Terminal>

		<nav aria-label="Where to go" class="mt-6 flex flex-wrap gap-4 font-medium">
			<a href="/" class={link}>Home</a>
			<a href="/projects" class={link}>Projects</a>
			<a href="/hackathons" class={link}>Hackathons</a>
		</nav>
	</div>
</div>
