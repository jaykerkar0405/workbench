<!--
	A mat for a screenshot, photo or video: a `surface` panel with a 1px border, 12px corners and 8px of padding, around
	media clipped to 8px corners (concentric with the padding). No shadow. Not interactive: no role, no tab stop; a
	caller that wants a clickable mat wraps it in a link or button.

	Sizing: with `ratio` the inner frame has its final size before anything loads, so loading -> loaded never shifts
	the page. Without it the media keeps its natural ratio (the image's own width and height attributes), and the
	placeholder falls back to 16 / 10, so give `ratio` whenever the source arrives asynchronously.

	Zoom (`zoom`): the media scales to 1.015 over 300ms inside the clipped inner frame; the mat itself never moves.
	The trigger is the Tailwind named group `group/mat`. The mat carries that group itself, so hovering it (or
	focusing inside it) scales it, and so does an ancestor carrying `group/mat`. The ancestor is the case that
	matters: under a stretched link the mat never receives :hover itself, so put `group/mat` on the panel that
	contains both. Reduced motion: nothing scales (motion-safe).
-->
<script lang="ts">
	import type { ComponentProps, Snippet } from 'svelte';
	import { cn } from '$lib/utils';
	import { AspectRatio } from '$lib/components/ui/aspect-ratio';
	import { Skeleton } from '$lib/components/ui/skeleton';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';

	let {
		src,
		alt = '',
		ratio,
		position = 'left top',
		fit = 'cover',
		loading = false,
		zoom = false,
		children,
		class: className
	}: {
		src?: ComponentProps<typeof EnhancedImage>['src'];
		alt?: string;
		ratio?: number;
		position?: string;
		fit?: 'cover' | 'contain';
		loading?: boolean;
		zoom?: boolean;
		children?: Snippet;
		class?: string;
	} = $props();

	const placeholder = $derived(loading || (!src && !children));
	const fill = $derived(ratio !== undefined);

	const zoomClass =
		'motion-safe:transition-[scale] motion-safe:duration-300 motion-safe:ease-(--ease-out) motion-safe:group-hover/mat:scale-[1.015] motion-safe:group-focus-within/mat:scale-[1.015]';
</script>

{#snippet media()}
	{#if placeholder}
		<Skeleton aria-hidden="true" class="absolute inset-0 size-full animate-none rounded-none bg-muted" />
	{:else}
		<div class={cn(fill && 'size-full', zoom && zoomClass)}>
			{#if src}
				<EnhancedImage
					{src}
					{alt}
					style={`object-position: ${position}`}
					containerClass={cn(fill && 'size-full')}
					class={cn(fill ? 'size-full' : 'h-auto w-full', fit === 'cover' ? 'object-cover' : 'object-contain')}
				/>
			{/if}
			{@render children?.()}
		</div>
	{/if}
{/snippet}

<div data-slot="media-mat" class={cn('group/mat rounded-lg border bg-surface p-2', className)}>
	{#if fill}
		<AspectRatio {ratio} class="relative overflow-hidden rounded-md">
			{@render media()}
		</AspectRatio>
	{:else}
		<div class={cn('relative overflow-hidden rounded-md', placeholder && 'aspect-[16/10]')}>
			{@render media()}
		</div>
	{/if}
</div>
