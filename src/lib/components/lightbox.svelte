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

	const controlClass = 'absolute z-20 rounded-md bg-background/70 backdrop-blur hover:bg-background';
</script>

<Dialog.Root bind:open>
	<Dialog.Content
		{onkeydown}
		showCloseButton={false}
		class={cn(
			'flex h-[90vh] w-[96vw] max-w-[96vw] items-center justify-center rounded-lg! bg-transparent p-0 shadow-none ring-0 duration-(--dur-2) ease-(--ease-out) sm:max-w-[96vw] data-open:zoom-in-100! data-closed:duration-(--dur-1) data-closed:zoom-out-100!',
			className
		)}
	>
		<Dialog.Title class="sr-only">{altPrefix}</Dialog.Title>
		<Dialog.Description class="sr-only">
			{many ? `Image ${index + 1} of ${count}. Use the arrow keys to move between images.` : 'Full-size image.'}
		</Dialog.Description>

		{#if images[index]}
			<EnhancedImage
				src={images[index]}
				alt={`${altPrefix} ${index + 1}`}
				skeletonClass="rounded-lg"
				containerClass="flex max-h-full max-w-full items-center justify-center"
				class="h-auto max-h-[90vh] w-auto max-w-[96vw] rounded-lg object-contain"
			/>
		{/if}

		<Dialog.Close>
			{#snippet child({ props })}
				<Button {...props} variant="ghost" size="icon" class={cn(controlClass, 'top-2 right-2')}>
					<XIcon />
					<span class="sr-only">Close</span>
				</Button>
			{/snippet}
		</Dialog.Close>

		{#if many}
			<Button
				type="button"
				size="icon"
				variant="ghost"
				onclick={() => step(-1)}
				class={cn(controlClass, 'top-1/2 left-2 -translate-y-1/2')}
			>
				<ChevronLeftIcon />
				<span class="sr-only">Previous image</span>
			</Button>

			<Button
				type="button"
				size="icon"
				variant="ghost"
				onclick={() => step(1)}
				class={cn(controlClass, 'top-1/2 right-2 -translate-y-1/2')}
			>
				<ChevronRightIcon />
				<span class="sr-only">Next image</span>
			</Button>

			<p
				aria-live="polite"
				class="absolute bottom-3 left-1/2 z-20 -translate-x-1/2 rounded-sm bg-background/70 px-2 py-1 label tabular-nums backdrop-blur"
			>
				{index + 1} / {count}
			</p>
		{/if}
	</Dialog.Content>
</Dialog.Root>
