<script lang="ts">
	import type { ComponentProps } from 'svelte';
	import { fade } from 'svelte/transition';
	import { prefersReducedMotion } from 'svelte/motion';
	import { cn } from '$lib/utils';
	import * as Carousel from '$lib/components/ui/carousel';
	import * as ScrollArea from '$lib/components/ui/scroll-area';
	import { AspectRatio } from '$lib/components/ui/aspect-ratio';
	import { Skeleton } from '$lib/components/ui/skeleton';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import Lightbox from '$lib/components/lightbox.svelte';

	type Source = ComponentProps<typeof EnhancedImage>['src'];
	type CarouselApi = Parameters<NonNullable<ComponentProps<typeof Carousel.Root>['setApi']>>[0];

	let {
		images,
		altPrefix,
		loading = false,
		class: className
	}: {
		class?: string;
		loading?: boolean;
		altPrefix: string;
		images: Source[];
	} = $props();

	let selected = $state(0);
	let lightboxOpen = $state(false);
	let carouselApi = $state<CarouselApi>();

	const fadeMs = () => (prefersReducedMotion.current ? 0 : 280);
	const safeSelected = $derived(Math.min(selected, Math.max(images.length - 1, 0)));

	// Keep the thumbnail strip following the selection (for example after arrow keys in the lightbox).
	$effect(() => {
		if (carouselApi && images.length > 5) carouselApi.scrollTo(safeSelected);
	});

	const thumbClass = (active: boolean) =>
		cn(
			'relative block aspect-video w-full overflow-hidden rounded-sm border bg-muted transition-opacity duration-(--dur-1) ease-(--ease-out) outline-none focus-visible:opacity-100 focus-visible:ring-3 focus-visible:ring-ring/50',
			active ? 'outline-2 outline-brand' : 'opacity-60 hover:opacity-100'
		);
</script>

{#snippet thumb(src: Source, i: number)}
	<button
		type="button"
		onclick={() => (selected = i)}
		aria-label={`Show ${altPrefix} ${i + 1}`}
		aria-current={i === safeSelected ? 'true' : undefined}
		class={thumbClass(i === safeSelected)}
	>
		<EnhancedImage
			{src}
			alt=""
			containerClass="size-full"
			skeletonClass="rounded-none"
			class="size-full object-contain"
		/>
	</button>
{/snippet}

{#if loading}
	<div class={cn('flex flex-col gap-4', className)} aria-busy="true">
		<AspectRatio ratio={16 / 9}>
			<Skeleton class="size-full rounded-md" />
		</AspectRatio>
		<div class="hidden grid-cols-5 gap-4 md:grid">
			{#each [0, 1, 2, 3, 4] as n (n)}
				<Skeleton class="aspect-video w-full rounded-sm" />
			{/each}
		</div>
		<div class="flex gap-2 overflow-hidden pb-3 md:hidden">
			{#each [0, 1, 2, 3, 4] as n (n)}
				<Skeleton class="aspect-video w-28 shrink-0 rounded-sm" />
			{/each}
		</div>
	</div>
{:else if images.length > 0}
	<div class={cn('flex flex-col gap-4', className)}>
		<AspectRatio ratio={16 / 9} class="overflow-hidden rounded-md border bg-muted">
			<button
				type="button"
				onclick={() => (lightboxOpen = true)}
				aria-label={`Open ${altPrefix} ${safeSelected + 1} full size`}
				class="absolute inset-0 cursor-zoom-in outline-none focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:ring-inset"
			>
				{#key safeSelected}
					<div class="absolute inset-0" in:fade={{ duration: fadeMs() }} out:fade={{ duration: fadeMs() }}>
						<EnhancedImage
							src={images[safeSelected]}
							alt={`${altPrefix} ${safeSelected + 1}`}
							skeletonClass="rounded-none"
							containerClass="size-full"
							class="size-full object-contain"
						/>
					</div>
				{/key}
			</button>
		</AspectRatio>

		{#if images.length > 1}
			<div class="hidden md:block">
				<Carousel.Root opts={{ align: 'start', dragFree: true }} setApi={(api) => (carouselApi = api)}>
					<Carousel.Content>
						{#each images as src, i (i)}
							<Carousel.Item class="basis-1/5">
								{@render thumb(src, i)}
							</Carousel.Item>
						{/each}
					</Carousel.Content>
					{#if images.length > 5}
						<Carousel.Previous class="-start-3 bg-background" />
						<Carousel.Next class="-end-3 bg-background" />
					{/if}
				</Carousel.Root>
			</div>

			<ScrollArea.Root orientation="horizontal" class="md:hidden">
				<div class="flex w-max gap-2 pb-3">
					{#each images as src, i (i)}
						<div class="w-28 shrink-0">
							{@render thumb(src, i)}
						</div>
					{/each}
				</div>
			</ScrollArea.Root>
		{/if}
	</div>

	<Lightbox {images} {altPrefix} bind:open={lightboxOpen} bind:index={selected} />
{/if}
