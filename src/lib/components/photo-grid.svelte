<!--
	A fixed-ratio photo grid: every cell is 4:3 and the block ends on a straight line at every count.

	From md (4 columns): 2 photos are two cells of two columns each; 3 are three equal cells in one row (a 2 x 2 lead plus
	two singles would leave two holes); 4 are one row of four; 5 or more put a 2 x 2 lead beside a 2 x 2 block of four.
	With 6 to 8 photos five cells show and the fifth reads +N; with 9 all nine show; with 10 or more the ninth reads +N.
	Below md (2 columns) the lead goes full width, except for 2 and 4 photos, which are plain pairs.

	The lead is exactly 4:3 because the row gap (12px) is three quarters of the column gap (16px): the lead is
	2w + 16 wide and 2h + 12 tall, and with h = 3w/4 that is 4:3.
-->
<script lang="ts">
	import type { ComponentProps } from 'svelte';
	import { cn } from '$lib/utils';
	import { reveal } from '$lib/components/reveal';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';

	type Photo = ComponentProps<typeof EnhancedImage>['src'];

	let {
		images,
		onopen,
		class: className
	}: {
		class?: string;
		images: Photo[];
		onopen: (index: number) => void;
	} = $props();

	const total = $derived(images.length);
	const shown = $derived(total >= 10 ? 9 : total >= 6 && total <= 8 ? 5 : total);
	const hidden = $derived(total - shown);

	// Full literal strings so Tailwind's compiler can see every class.
	const gridClass = $derived(total === 3 ? 'grid-cols-2 md:grid-cols-3' : 'grid-cols-2 md:grid-cols-4');

	const cellSpan = (i: number) => {
		if (total === 2) return 'md:col-span-2';
		if (total === 3) return i === 0 ? 'col-span-2 md:col-span-1' : '';
		if (total >= 5 && i === 0) return 'col-span-2 md:row-span-2';
		return '';
	};
</script>

<div
	class={cn('grid gap-2 [--reveal-radius:var(--radius-md)] md:gap-x-4 md:gap-y-3', gridClass, className)}
	{@attach reveal({ stagger: true, mask: true })}
>
	{#each images.slice(0, shown) as photo, i (i)}
		{@const more = hidden > 0 && i === shown - 1}
		<button
			type="button"
			onclick={() => onopen(i)}
			aria-label={more ? `Open photo ${i + 1} of ${total} (${hidden} more)` : `Open photo ${i + 1} of ${total}`}
			class={cn(
				'group/cell relative block aspect-[4/3] w-full cursor-zoom-in overflow-hidden rounded-md border bg-surface outline-none focus-visible:ring-3 focus-visible:ring-ring/50',
				cellSpan(i)
			)}
		>
			<EnhancedImage
				src={photo}
				alt=""
				skeletonClass="rounded-none"
				containerClass="size-full origin-center motion-safe:transition-[scale] motion-safe:duration-300 motion-safe:ease-(--ease-out) motion-safe:group-hover/cell:scale-[1.015] motion-safe:group-focus-visible/cell:scale-[1.015]"
				class="size-full object-cover"
			/>
			{#if more}
				<span
					aria-hidden="true"
					class="absolute inset-0 z-20 grid place-items-center bg-background/70 font-mono text-[1.75rem] text-foreground tabular-nums"
				>
					+{hidden}
				</span>
			{/if}
		</button>
	{/each}
</div>
