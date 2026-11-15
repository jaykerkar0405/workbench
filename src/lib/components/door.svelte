<!--
	A door on the home page: one panel that is one link to a listing page (/projects or /hackathons). The count at 64px, the
	title at 28px, and a `LATEST` line with the newest names. Nothing is looked up here; the page derives every value.
	Hover and keyboard focus fill the panel with `muted` and move the arrow 4px (140ms, transform only); the count stays put.
	The link's name is `Title, count. Latest: a, b, c`, so the screen reader hears what the eye reads.
-->
<script lang="ts">
	import { cn } from '$lib/utils';

	let {
		href,
		count,
		title,
		latest,
		class: className
	}: { href: string; count: number; title: string; latest: string[]; class?: string } = $props();
</script>

<a
	{href}
	aria-label={`${title}, ${count}. Latest: ${latest.join(', ')}`}
	class={cn(
		'group/door relative block p-6 transition-colors duration-(--dur-1) ease-(--ease-out) outline-none hover:bg-muted focus-visible:bg-muted focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-ring focus-visible:outline-solid md:p-8',
		className
	)}
>
	<p class="text-page-title tabular-nums md:text-[4rem]">{count}</p>
	<p class="mt-2 text-section-title">{title}</p>

	<p class="mt-4 grid grid-cols-[auto_1fr] items-baseline gap-x-4 text-sm text-muted-foreground" aria-hidden="true">
		<span class="label">Latest</span>
		<span class="font-mono">{latest.join(' · ')}</span>
	</p>

	<span
		aria-hidden="true"
		class="absolute top-6 right-6 text-xl text-muted-foreground transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/door:translate-x-1 motion-safe:group-focus-visible/door:translate-x-1 md:top-8 md:right-8"
		>→</span
	>
</a>
