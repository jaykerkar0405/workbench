<script module lang="ts">
	/** The 11-character id of a YouTube watch, youtu.be or embed link, or null when the URL is not one. */
	export const parseYoutubeId = (value: string): string | null => {
		let parsed: URL;
		try {
			parsed = new URL(value);
		} catch {
			return null;
		}

		const host = parsed.hostname.replace(/^(www|m)\./, '');
		let id: string | null = null;

		if (host === 'youtu.be') {
			id = parsed.pathname.split('/')[1] ?? null;
		} else if (host === 'youtube.com' || host === 'youtube-nocookie.com') {
			if (parsed.pathname === '/watch') {
				id = parsed.searchParams.get('v');
			} else if (parsed.pathname.startsWith('/embed/')) {
				id = parsed.pathname.split('/')[2] ?? null;
			}
		}

		return id && /^[\w-]{11}$/.test(id) ? id : null;
	};
</script>

<script lang="ts">
	import { tick, type ComponentProps } from 'svelte';
	import { fade } from 'svelte/transition';
	import { prefersReducedMotion } from 'svelte/motion';
	import { cn } from '$lib/utils';
	import PlayIcon from '@lucide/svelte/icons/play';
	import { Button } from '$lib/components/ui/button';
	import * as Carousel from '$lib/components/ui/carousel';
	import * as ScrollArea from '$lib/components/ui/scroll-area';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import MediaMat from '$lib/components/media-mat.svelte';
	import Lightbox from '$lib/components/lightbox.svelte';

	type Source = ComponentProps<typeof EnhancedImage>['src'];
	type CarouselApi = Parameters<NonNullable<ComponentProps<typeof Carousel.Root>['setApi']>>[0];

	let {
		images,
		altPrefix,
		videoUrl,
		videoTitle = 'Demo video',
		class: className
	}: {
		class?: string;
		altPrefix: string;
		images: Source[];
		videoUrl?: string;
		videoTitle?: string;
	} = $props();

	// The strip has the demo video first (when there is one), then the screenshots in order. `selected` is a strip
	// position; the screenshot index is `selected - offset`. The lightbox only ever sees the screenshots.
	const videoId = $derived(videoUrl ? parseYoutubeId(videoUrl) : null);
	const offset = $derived(videoId ? 1 : 0);
	const total = $derived(images.length + offset);
	const indices = $derived(Array.from({ length: total }, (_, i) => i));

	// Until someone picks, the first screenshot is the lead (the video only when it is all there is).
	let picked = $state<number | null>(null);
	const selected = $derived(picked ?? (images.length > 0 ? offset : 0));
	const isVideo = $derived(videoId !== null && selected === 0);
	const shot = $derived(isVideo ? -1 : selected - offset);

	// Selecting the video thumbnail means "play"; selecting anything else removes the iframe, which stops playback.
	let playing = $state(false);
	const select = (i: number) => {
		picked = i;
		playing = videoId !== null && i === 0;
	};

	let lightboxOpen = $state(false);
	let carouselApi = $state<CarouselApi>();
	let rowViewport = $state<HTMLElement | null>(null);

	const fadeMs = () => (prefersReducedMotion.current ? 0 : 260);

	// Keep the thumbnail strip following the selection (for example after arrow keys in the lightbox), but only when the
	// selected thumbnail is out of view: the first screenshot is item 1, and scrolling to it would hide the video.
	$effect(() => {
		if (!carouselApi || total <= 5) return;
		// Geometry, not slidesInView(): that list stays empty until an IntersectionObserver callback has run.
		const slide = carouselApi.slideNodes()[selected]?.getBoundingClientRect();
		const view = carouselApi.rootNode().getBoundingClientRect();
		if (slide && (slide.left < view.left - 1 || slide.right > view.right + 1)) {
			carouselApi.scrollTo(selected, prefersReducedMotion.current);
		}
	});

	// Keyboard focus in the strip. Embla's own watchFocus (on by default) scrolls the focused slide's snap to the start
	// edge even when the thumbnail is already fully visible, which pushed the video thumbnail off the left edge, so it is
	// off here. Instead: undo the browser's native scroll of the overflow-hidden viewport (Embla moves a transform and
	// would not know about it), then scroll the carousel only when the focused thumbnail is not fully in view.
	const revealFocused = (event: FocusEvent) => {
		const api = carouselApi;
		const target = event.target as HTMLElement | null;
		const slide = target?.closest<HTMLElement>('[data-embla-slide]');
		if (!api || !slide) return;
		const root = api.rootNode();
		root.scrollLeft = 0;
		const view = root.getBoundingClientRect();
		// The slide box includes a 16px gutter on its start side; the thumbnail is the part that matters.
		const thumb = (slide.firstElementChild ?? slide).getBoundingClientRect();
		if (thumb.left < view.left - 1 || thumb.right > view.right + 1) {
			api.scrollTo(api.slideNodes().indexOf(slide), prefersReducedMotion.current);
		}
	};

	// Below md the strip is a scroll row: keep the selected thumbnail inside it. The row's own scrollLeft is set, not
	// scrollIntoView, so the page never scrolls vertically; instantly under reduced motion.
	$effect(() => {
		void selected;
		const row = rowViewport;
		if (!row) return;
		tick().then(() => {
			const item = row.querySelector<HTMLElement>('[aria-current="true"]');
			if (!item) return;
			const box = row.getBoundingClientRect();
			const rect = item.getBoundingClientRect();
			let left = row.scrollLeft;
			if (rect.left < box.left) left += rect.left - box.left - 4;
			else if (rect.right > box.right) left += rect.right - box.right + 4;
			if (left !== row.scrollLeft) {
				row.scrollTo({ left, behavior: prefersReducedMotion.current ? 'instant' : 'smooth' });
			}
		});
	});

	// The selection is a 2px brand outline, drawn inside the thumbnail (the carousel clips whatever sits outside it).
	// Keyboard focus is a separate ring, so the two never fight.
	const thumbClass = (active: boolean) =>
		cn(
			'relative block aspect-video w-full cursor-pointer overflow-hidden rounded-md border bg-surface transition-opacity duration-(--dur-1) ease-(--ease-out) focus-visible:opacity-100 focus-visible:ring-3 focus-visible:ring-ring/50 motion-reduce:transition-none',
			active ? '-outline-offset-2 outline-2 outline-brand' : 'opacity-60 outline-none hover:opacity-100'
		);

	const posterUrl = (id: string) => `https://i.ytimg.com/vi/${id}/hqdefault.jpg`;

	const playVideo = (event: MouseEvent) => {
		// Without JavaScript the link still opens the video; with it, the lead frame becomes the player.
		event.preventDefault();
		playing = true;
	};

	// A link is activated by Enter only; thumbnails also answer Space, like their button siblings.
	const spaceSelects = (event: KeyboardEvent, i: number) => {
		if (event.key === ' ') {
			event.preventDefault();
			select(i);
		}
	};
</script>

{#snippet playMark()}
	<span class="absolute inset-0 grid place-items-center">
		<span class="flex size-7 items-center justify-center rounded-sm bg-background/90 text-foreground">
			<PlayIcon class="size-3.5 translate-x-px fill-current" />
		</span>
	</span>
{/snippet}

{#snippet thumb(i: number)}
	{#if videoId && i === 0}
		<a
			href={videoUrl}
			target="_blank"
			rel="noopener noreferrer"
			onclick={(event) => {
				event.preventDefault();
				select(0);
			}}
			onkeydown={(event) => spaceSelects(event, 0)}
			aria-label="Play demo video"
			aria-current={selected === 0 ? 'true' : undefined}
			class={thumbClass(selected === 0)}
		>
			<img alt="" loading="lazy" src={posterUrl(videoId)} class="size-full object-cover" />
			{@render playMark()}
		</a>
	{:else}
		<button
			type="button"
			onclick={() => select(i)}
			aria-label={`Show ${altPrefix} ${i - offset + 1}`}
			aria-current={i === selected ? 'true' : undefined}
			class={thumbClass(i === selected)}
		>
			<EnhancedImage
				src={images[i - offset]}
				alt=""
				containerClass="size-full"
				skeletonClass="rounded-none"
				class="size-full object-contain"
			/>
		</button>
	{/if}
{/snippet}

{#if total > 0}
	<div class={cn('flex flex-col gap-4', className)}>
		<!-- A fixed 16:9 frame: the page never moves when the selection changes. Screenshots are contained, never cropped,
			with their own 8px corners; what is left of the frame is the mat's own surface. -->
		<MediaMat ratio={16 / 9} zoom={!playing}>
			{#if isVideo && videoId}
				{#if playing}
					<iframe
						title={videoTitle}
						allowfullscreen
						class="absolute inset-0 size-full"
						src={`https://www.youtube-nocookie.com/embed/${videoId}?autoplay=1`}
						allow="accelerometer; autoplay; encrypted-media; picture-in-picture"
					></iframe>
				{:else}
					<img alt="" loading="lazy" class="absolute inset-0 size-full object-cover" src={posterUrl(videoId)} />
					<Button
						href={videoUrl}
						target="_blank"
						rel="noopener noreferrer"
						variant="ghost"
						onclick={playVideo}
						aria-label={`Play video: ${videoTitle}`}
						class="absolute inset-0 h-full w-full rounded-none"
					>
						<span class="flex size-14 items-center justify-center rounded-md border bg-background/90 text-foreground">
							<PlayIcon class="size-6 translate-x-0.5 fill-current" />
						</span>
					</Button>
				{/if}
			{:else if images[shot]}
				<button
					type="button"
					onclick={() => (lightboxOpen = true)}
					aria-label={`Open ${altPrefix} ${shot + 1} full size`}
					class="absolute inset-0 cursor-zoom-in outline-none focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:ring-inset"
				>
					{#key shot}
						<div
							class="[container-type:size] absolute inset-0 flex items-center justify-center"
							in:fade={{ duration: fadeMs() }}
							out:fade={{ duration: fadeMs() }}
						>
							<!-- The wrapper is a size container, so the image is limited with cqh / cqw (a percentage max-height cannot resolve
							through the <picture> element the image sits in). -->
							<EnhancedImage
								src={images[shot]}
								alt={`${altPrefix} ${shot + 1}`}
								skeletonClass="rounded-md"
								containerClass="contents"
								class="h-auto max-h-[100cqh] w-auto max-w-[100cqw] rounded-md object-contain duration-(--dur-2) motion-reduce:transition-none"
							/>
						</div>
					{/key}
				</button>
			{/if}
		</MediaMat>

		{#if total > 1}
			<div class="hidden md:block" onfocusin={revealFocused}>
				<!-- With more than five items the arrows get their own space at the two ends (36px plus 8px), never over a thumbnail. -->
				<Carousel.Root
					class={cn(total > 5 && 'px-11')}
					opts={{ align: 'start', dragFree: true, watchFocus: false }}
					setApi={(api) => (carouselApi = api)}
				>
					<Carousel.Content>
						{#each indices as i (i)}
							<Carousel.Item class="basis-1/5">
								{@render thumb(i)}
							</Carousel.Item>
						{/each}
					</Carousel.Content>
					{#if total > 5}
						<Carousel.Previous class="start-0 size-9 rounded-md bg-background" />
						<Carousel.Next class="end-0 size-9 rounded-md bg-background" />
					{/if}
				</Carousel.Root>
			</div>

			<ScrollArea.Root orientation="horizontal" class="md:hidden" bind:viewportRef={rowViewport}>
				<div class="flex w-max gap-2 p-0.5 pb-3">
					{#each indices as i (i)}
						<div class="w-28 shrink-0">
							{@render thumb(i)}
						</div>
					{/each}
				</div>
			</ScrollArea.Root>
		{/if}

		{#if videoUrl && !videoId}
			<a href={videoUrl} target="_blank" rel="noopener noreferrer" class="w-fit link-underline text-sm font-medium">
				Watch video ↗
			</a>
		{/if}
	</div>

	{#if images.length > 0}
		<!-- The lightbox only gets the screenshots; its index is the strip position minus the video's slot. -->
		<Lightbox
			{images}
			{altPrefix}
			bind:open={lightboxOpen}
			bind:index={
				() => Math.max(shot, 0),
				(value) => {
					picked = value + offset;
					playing = false;
				}
			}
		/>
	{/if}
{:else if videoUrl}
	<a
		href={videoUrl}
		target="_blank"
		rel="noopener noreferrer"
		class={cn('link-underline text-sm font-medium', className)}
	>
		Watch video ↗
	</a>
{/if}
