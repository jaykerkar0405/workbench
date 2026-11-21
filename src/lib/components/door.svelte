<!--
	A door on the home page: one panel that is one link to a listing page (/projects or /hackathons). The count at 64px, the
	title at 28px, and a `LATEST` line with the newest names. Nothing is looked up here; the page derives every value.
	Hover and keyboard focus fill the panel with `muted` and move the arrow 4px (140ms, transform only); the count stays put.
	The link's name is `Title, count. Latest: a, b, c`, so the screen reader hears what the eye reads.
-->
<script lang="ts">
	import type { ComponentProps } from 'svelte';
	import { cn } from '$lib/utils';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';

	type LatestItem = { title: string; icon?: ComponentProps<typeof EnhancedImage>['src']; fit?: 'cover' | 'contain' };

	let {
		href,
		count,
		title,
		latest,
		class: className
	}: { href: string; count: number; title: string; latest: LatestItem[]; class?: string } = $props();

	const latestTitles = $derived(latest.map((item) => item.title));
	const hasIcons = $derived(latest.some((item) => item.icon));
</script>

<a
	{href}
	aria-label={`${title}, ${count}${latest.length ? `. Latest: ${latestTitles.join(', ')}` : ''}`}
	class={cn(
		'group/door relative block px-5 py-6 transition-colors duration-(--dur-1) ease-(--ease-out) outline-none hover:bg-muted focus-visible:bg-muted focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-ring focus-visible:outline-solid md:px-10 md:py-8',
		className
	)}
>
	<p class="text-page-title tabular-nums md:text-[4rem]">{count}</p>
	<p class="mt-2 text-section-title">{title}</p>

	{#if latest.length}
		<div
			class={cn(
				'mt-4 grid items-start gap-x-4 text-sm leading-5 text-muted-foreground',
				hasIcons ? 'grid-cols-[auto_auto_minmax(0,1fr)]' : 'grid-cols-[auto_minmax(0,1fr)]'
			)}
			aria-hidden="true"
		>
			<span class="flex h-5 items-center label">Latest</span>
			{#if hasIcons}
				<div class="flex gap-1">
					{#each latest as item, i (i)}
						{#if item.icon}
							<div class="size-5 shrink-0 overflow-hidden rounded-sm border bg-muted">
								<EnhancedImage
									src={item.icon}
									alt=""
									containerClass="size-full"
									skeletonClass="rounded-none"
									class={cn('size-full', item.fit === 'contain' ? 'object-contain' : 'object-cover')}
								/>
							</div>
						{/if}
					{/each}
				</div>
			{/if}
			<span class="font-mono wrap-break-word">{latestTitles.join(' · ')}</span>
		</div>
	{/if}

	<span
		aria-hidden="true"
		class="absolute top-6 right-5 text-xl text-muted-foreground transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/door:translate-x-1 motion-safe:group-focus-visible/door:translate-x-1 md:top-8 md:right-10"
		>→</span
	>
</a>
