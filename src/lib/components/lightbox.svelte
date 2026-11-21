<script lang="ts">
	import type { ComponentProps } from 'svelte';
	import { cn } from '$lib/utils';
	import { Button } from '$lib/components/ui/button';
	import * as Dialog from '$lib/components/ui/dialog';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import ChevronLeftIcon from '@lucide/svelte/icons/chevron-left';
	import ChevronRightIcon from '@lucide/svelte/icons/chevron-right';
	import XIcon from '@lucide/svelte/icons/x';

	let {
		images,
		altPrefix,
		open = $bindable(false),
		index = $bindable(0),
		class: className
	}: {
		class?: string;
		open?: boolean;
		index?: number;
		altPrefix: string;
		images: ComponentProps<typeof EnhancedImage>['src'][];
	} = $props();

	const count = $derived(images.length);
	const many = $derived(count > 1);

	const step = (delta: number) => {
		if (count > 1) index = (index + delta + count) % count;
	};

	// Scoped to the dialog content, so it only listens while the lightbox is open and focused.
	const onkeydown = (event: KeyboardEvent) => {
		if (event.key === 'ArrowLeft') {
			event.preventDefault();
			step(-1);
		} else if (event.key === 'ArrowRight') {
			event.preventDefault();
			step(1);
		}
	};

	let stage = $state<HTMLElement | null>(null);

	// Focus the close button on open (the conventional safe target), instead of the first arrow.
	const onOpenAutoFocus = (event: Event) => {
		event.preventDefault();
		stage?.querySelector<HTMLElement>('[data-lightbox-close]')?.focus();
	};

	// Dialog.Content is the full-viewport stage, so bits-ui never sees an "outside" click. A click that lands on the
	// stage itself (not the image, the row or a control) is a click on the scrim.
	let suppressClose = false;
	const onclick = (event: MouseEvent) => {
		if (suppressClose) {
			suppressClose = false;
			return;
		}
		if (event.target === event.currentTarget) open = false;
	};

	// Swipe: touch and pen only, so mouse clicks and drags on desktop are never intercepted.
	const SWIPE_MIN = 50; // px of horizontal travel
	const SWIPE_RATIO = 1.5; // horizontal must beat vertical by this factor
	const SWIPE_MAX_MS = 800;
	const LOCK_PX = 10; // travel before the gesture commits to horizontal (or is dropped as vertical)
	const FOLLOW_MAX = 120; // the image follows the finger by at most this many px

	type Gesture = { id: number; x: number; y: number; t: number; locked: boolean };
	let gesture: Gesture | null = null;
	let dragX = $state(0);
	let dragging = $state(false);

	const reduceMotion = () => matchMedia('(prefers-reduced-motion: reduce)').matches;

	const resetGesture = (node?: Element | null) => {
		if (gesture?.locked) {
			try {
				node?.releasePointerCapture(gesture.id);
			} catch {
				// the pointer may already be gone
			}
		}
		gesture = null;
		dragging = false;
		dragX = 0;
	};

	const onpointerdown = (event: PointerEvent) => {
		suppressClose = false;
		if (!many || (event.pointerType !== 'touch' && event.pointerType !== 'pen')) return;
		// A second finger cancels the gesture.
		if (!event.isPrimary || gesture) {
			resetGesture(event.currentTarget as Element);
			return;
		}
		if ((event.target as Element).closest('button')) return;
		gesture = { id: event.pointerId, x: event.clientX, y: event.clientY, t: event.timeStamp, locked: false };
	};

	const onpointermove = (event: PointerEvent) => {
		if (!gesture || event.pointerId !== gesture.id) return;
		const dx = event.clientX - gesture.x;
		const dy = event.clientY - gesture.y;

		if (!gesture.locked) {
			if (Math.abs(dy) > LOCK_PX && Math.abs(dy) > Math.abs(dx)) {
				gesture = null; // a vertical drag: not ours
				return;
			}
			if (Math.abs(dx) < LOCK_PX || Math.abs(dx) < Math.abs(dy) * SWIPE_RATIO) return;
			gesture.locked = true;
			(event.currentTarget as Element).setPointerCapture(event.pointerId);
		}

		if (!reduceMotion()) {
			dragging = true;
			dragX = Math.max(-FOLLOW_MAX, Math.min(FOLLOW_MAX, dx));
		}
	};

	const onpointerup = (event: PointerEvent) => {
		if (!gesture || event.pointerId !== gesture.id) return;
		const { locked, x, y, t } = gesture;
		const dx = event.clientX - x;
		const dy = event.clientY - y;
		const node = event.currentTarget as Element;

		if (!locked) {
			gesture = null; // a tap, or too little travel: nothing happens
			return;
		}

		suppressClose = true; // the click that may follow a swipe must not close the lightbox
		const swiped =
			Math.abs(dx) >= SWIPE_MIN && Math.abs(dx) > Math.abs(dy) * SWIPE_RATIO && event.timeStamp - t <= SWIPE_MAX_MS;

		if (swiped) {
			// Reset the offset while still "dragging" so the new image does not slide in.
			resetGesture(node);
			dragging = true;
			step(dx < 0 ? 1 : -1);
			requestAnimationFrame(() => (dragging = false));
		} else {
			// Spring back: dragging ends first so the transform transitions to 0.
			resetGesture(node);
		}
	};

	const onpointercancel = (event: PointerEvent) => {
		if (gesture && event.pointerId === gesture.id) resetGesture(event.currentTarget as Element);
	};

	const ghost = 'size-11 rounded-md text-muted-foreground hover:bg-muted hover:text-foreground';
</script>

{#snippet arrow(direction: -1 | 1, buttonClass?: string)}
	<Button type="button" size="icon" variant="ghost" onclick={() => step(direction)} class={cn(ghost, buttonClass)}>
		{#if direction < 0}
			<ChevronLeftIcon class="size-5" />
			<span class="sr-only">Previous image</span>
		{:else}
			<ChevronRightIcon class="size-5" />
			<span class="sr-only">Next image</span>
		{/if}
	</Button>
{/snippet}

<Dialog.Root bind:open>
	<!-- The content is the stage: it covers the viewport (over the header and the dock) with the page colour at 92%.
		The default overlay behind it cannot be styled from here and is left alone.
		touch-pan-y touch-pinch-zoom: the browser keeps vertical pans and pinch-zoom, horizontal moves are ours. -->
	<Dialog.Content
		bind:ref={stage}
		{onkeydown}
		{onclick}
		{onpointerdown}
		{onpointermove}
		{onpointerup}
		{onpointercancel}
		{onOpenAutoFocus}
		showCloseButton={false}
		class={cn(
			'top-0 left-0 flex h-dvh w-full max-w-none translate-x-0 translate-y-0 touch-pan-y touch-pinch-zoom flex-col items-center justify-center gap-0 rounded-none bg-background/92 p-0 shadow-none ring-0 duration-(--dur-2) ease-(--ease-out) motion-reduce:animate-none! sm:max-w-none data-open:zoom-in-100! data-closed:duration-(--dur-1) data-closed:zoom-out-100!',
			className
		)}
	>
		<Dialog.Title class="sr-only">{altPrefix}</Dialog.Title>
		<Dialog.Description class="sr-only">
			{many ? `Image ${index + 1} of ${count}. Use the arrow keys to move between images.` : 'Full-size image.'}
		</Dialog.Description>

		<!-- The figure is as wide as the image, or 16rem on a narrow one. The row under the image takes its width. -->
		<div class="flex w-fit max-w-full min-w-64 flex-col gap-4">
			<!-- The arrows hang off this box (24px outside each edge), so they follow the image when its width changes.
				Below md there is no room for them beside the image; they move into the row instead. -->
			<div class="relative mx-auto w-fit">
				{#if many}
					{@render arrow(-1, 'absolute top-1/2 right-full mr-6 -translate-y-1/2 max-md:hidden')}
					{@render arrow(1, 'absolute top-1/2 left-full ml-6 -translate-y-1/2 max-md:hidden')}
				{/if}

				<div
					style:transform={dragX ? `translateX(${dragX}px)` : undefined}
					class={cn(
						!dragging && 'transition-transform duration-(--dur-1) ease-(--ease-out) motion-reduce:transition-none'
					)}
				>
					{#if images[index]}
						{#key index}
							<!-- Width limit: 88vw, or at md and up what is left after 68px (44 + 24) on each side for the arrows.
								Height limit: 88dvh, or what is left after the 44px row, its 16px gap and 16px above and below. -->
							<EnhancedImage
								src={images[index]}
								alt={`${altPrefix} ${index + 1}`}
								draggable="false"
								skeletonClass="rounded-md"
								containerClass="flex rounded-md"
								class="h-auto max-h-[min(88dvh,calc(100dvh-5.75rem))] w-auto max-w-[88vw] rounded-md object-contain duration-(--dur-1) select-none motion-reduce:transition-none md:max-w-[min(88vw,calc(100vw-9.5rem))]"
							/>
						{/key}
					{/if}
				</div>
			</div>

			<div class="grid h-11 grid-cols-[1fr_auto_1fr] items-center">
				<div class="flex items-center justify-self-start">
					{#if many}
						{@render arrow(-1, 'md:hidden')}
						<!-- The invisible sizer reserves the width of the widest value, so the row does not shift as you step. -->
						<p aria-live="polite" class="inline-grid px-1 label text-muted-foreground tabular-nums">
							<span aria-hidden="true" class="invisible col-start-1 row-start-1 select-none">{count} / {count}</span>
							<span class="col-start-1 row-start-1">{index + 1} / {count}</span>
						</p>
						{@render arrow(1, 'md:hidden')}
					{/if}
				</div>

				<!-- Caption slot: empty, no caption data exists. -->
				<div></div>

				<Dialog.Close>
					{#snippet child({ props })}
						<Button {...props} data-lightbox-close variant="ghost" size="icon" class={cn(ghost, 'justify-self-end')}>
							<XIcon class="size-5" />
							<span class="sr-only">Close</span>
						</Button>
					{/snippet}
				</Dialog.Close>
			</div>
		</div>
	</Dialog.Content>
</Dialog.Root>
