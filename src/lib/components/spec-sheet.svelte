<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';

	type SpecItem = { label: string; value?: string; content?: Snippet };

	let {
		items,
		columns = 4,
		class: className
	}: {
		class?: string;
		items: SpecItem[];
		columns?: 2 | 3 | 4;
	} = $props();

	// Full literal strings so Tailwind's compiler can see every class.
	// Rules: every cell has a top rule except those in the first row; every cell that is not first
	// in its row has a left rule and left padding. Empty positions in an incomplete row draw nothing.
	const gridClass = {
		2: 'lg:grid-cols-2',
		3: 'lg:grid-cols-3',
		4: 'lg:grid-cols-4'
	} as const;

	const cellClass = {
		2: 'lg:border-l lg:pl-6 lg:[&:nth-child(-n+2)]:border-t-0 lg:[&:nth-child(2n+1)]:border-l-0 lg:[&:nth-child(2n+1)]:pl-0',
		3: 'lg:border-l lg:pl-6 lg:[&:nth-child(-n+3)]:border-t-0 lg:[&:nth-child(3n+1)]:border-l-0 lg:[&:nth-child(3n+1)]:pl-0',
		4: 'lg:border-l lg:pl-6 lg:[&:nth-child(-n+4)]:border-t-0 lg:[&:nth-child(4n+1)]:border-l-0 lg:[&:nth-child(4n+1)]:pl-0'
	} as const;
</script>

<dl class={cn('grid grid-cols-1 border-y sm:grid-cols-2', gridClass[columns], className)}>
	{#each items as item, i (`${item.label}-${i}`)}
		<div
			class={cn(
				'flex min-w-0 flex-col gap-2 border-t py-5 pr-6 first:border-t-0 sm:pl-0 sm:even:border-l sm:even:pl-6 sm:[&:nth-child(-n+2)]:border-t-0',
				cellClass[columns]
			)}
		>
			<dt class="label">{item.label}</dt>
			<dd class="text-base text-foreground">
				{#if item.content}
					{@render item.content()}
				{:else}
					{item.value || '—'}
				{/if}
			</dd>
		</div>
	{/each}
</dl>
