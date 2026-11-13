<script lang="ts">
	import type { ComponentProps } from 'svelte';
	import { cn } from '$lib/utils';
	import { Separator } from '$lib/components/ui/separator';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';

	type Side = {
		href: string;
		title: string;
		index?: string;
		iconFit?: 'cover' | 'contain';
		icon?: ComponentProps<typeof EnhancedImage>['src'];
	};

	let {
		prev,
		next,
		class: className
	}: {
		next?: Side;
		prev?: Side;
		class?: string;
	} = $props();
</script>

{#snippet half(side: Side, dir: 'prev' | 'next')}
	{@const word = dir === 'prev' ? 'Prev' : 'Next'}
	<a
		href={side.href}
		aria-label={`${word === 'Prev' ? 'Previous' : 'Next'}: ${side.title}`}
		class={cn(
			'group/pn flex min-w-0 flex-col gap-3 rounded-sm py-8 outline-none focus-visible:ring-3 focus-visible:ring-ring/50',
			dir === 'next' && 'items-end text-right'
		)}
	>
		<span class="flex items-center gap-2 label tabular-nums" aria-hidden="true">
			{#if dir === 'prev'}
				<span
					class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) group-hover/pn:-translate-x-1 group-focus-visible/pn:-translate-x-1"
					>←</span
				>
			{/if}
			<span>{word}{side.index ? ` · ${side.index}` : ''}</span>
			{#if dir === 'next'}
				<span
					class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) group-hover/pn:translate-x-1 group-focus-visible/pn:translate-x-1"
					>→</span
				>
			{/if}
		</span>

		<span class={cn('flex max-w-full min-w-0 items-center gap-3', dir === 'next' && 'flex-row-reverse')}>
			{#if side.icon}
				<EnhancedImage
					src={side.icon}
					alt=""
					containerClass="size-8 shrink-0"
					skeletonClass="rounded-sm"
					class={cn('size-8 rounded-sm', side.iconFit === 'contain' ? 'object-contain' : 'object-cover')}
				/>
			{/if}
			<span
				class="min-w-0 truncate text-xl font-semibold text-muted-foreground transition-colors duration-(--dur-1) ease-(--ease-out) group-hover/pn:text-foreground group-focus-visible/pn:text-foreground"
				>{side.title}</span
			>
		</span>
	</a>
{/snippet}

<nav aria-label="Previous and next" class={cn('w-full', className)}>
	<Separator />

	<div class="grid sm:grid-cols-[1fr_auto_1fr] sm:gap-x-8">
		<div class="min-w-0">
			{#if prev}
				{@render half(prev, 'prev')}
			{/if}
		</div>

		<Separator orientation="vertical" class="hidden sm:block" />

		<div class="min-w-0">
			{#if next}
				{@render half(next, 'next')}
			{/if}
		</div>
	</div>
</nav>
