<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';
	import { Separator } from '$lib/components/ui/separator';

	let {
		id,
		index,
		title,
		children,
		level = 2,
		class: className
	}: {
		id?: string;
		index: string;
		title: string;
		class?: string;
		level?: 2 | 3;
		children?: Snippet;
	} = $props();
</script>

<div class={cn('w-full', className)}>
	<Separator />

	<div class="flex flex-wrap items-baseline gap-x-4 gap-y-2 pt-6 sm:flex-nowrap">
		<span class="shrink-0 label tabular-nums" aria-hidden="true">{index}</span>

		<svelte:element this={level === 2 ? 'h2' : 'h3'} {id} class="min-w-0 text-section-title">
			{title}
		</svelte:element>

		{#if children}
			<div class="basis-full text-sm text-muted-foreground sm:ml-auto sm:shrink-0 sm:basis-auto">
				{@render children()}
			</div>
		{/if}
	</div>
</div>
