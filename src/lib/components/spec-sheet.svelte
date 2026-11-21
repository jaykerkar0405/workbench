<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';

	type SpecItem = { label: string; value?: string; content?: Snippet };

	let {
		items,
		wideRows = [],
		columns = 4,
		variant = 'grid',
		class: className
	}: {
		class?: string;
		wideRows?: SpecItem[];
		items: SpecItem[];
		columns?: 1 | 2 | 3 | 4;
		variant?: 'grid' | 'facts';
	} = $props();

	// An item with neither a value nor content is not rendered.
	const shown = $derived(items.filter((item) => item.content || item.value));
	const shownWideRows = $derived(wideRows.filter((item) => item.content || item.value));

	// Each fact starts on a three-column track. The last fact fills the remaining tracks.
	const spanClass = [
		[],
		['lg:col-span-12'],
		['lg:col-span-3', 'lg:col-span-9'],
		['lg:col-span-3', 'lg:col-span-3', 'lg:col-span-6'],
		['lg:col-span-3', 'lg:col-span-3', 'lg:col-span-3', 'lg:col-span-3']
	];

	// Full literal strings so Tailwind's compiler can see every class.
	// Rules: every cell has a top rule except those in the first row; every cell that is not first
	// in its row has a left rule and left padding. Empty positions in an incomplete row draw nothing.
	const gridClass = {
		1: '',
		2: 'lg:grid-cols-2',
		3: 'lg:grid-cols-3',
		4: 'lg:grid-cols-4'
	} as const;

	const cellClass = {
		1: '',
		2: 'lg:border-l lg:pl-6 lg:[&:nth-child(-n+2)]:border-t-0 lg:[&:nth-child(2n+1)]:border-l-0 lg:[&:nth-child(2n+1)]:pl-0',
		3: 'lg:border-l lg:pl-6 lg:[&:nth-child(-n+3)]:border-t-0 lg:[&:nth-child(3n+1)]:border-l-0 lg:[&:nth-child(3n+1)]:pl-0',
		4: 'lg:border-l lg:pl-6 lg:[&:nth-child(-n+4)]:border-t-0 lg:[&:nth-child(4n+1)]:border-l-0 lg:[&:nth-child(4n+1)]:pl-0'
	} as const;
</script>

{#if variant === 'facts'}
	<dl class={cn('border-y', className)}>
		{#if shown.length > 0}
			<!-- Below lg: two columns with hairlines. On desktop, each rule sits in the middle of the 24px gutter. -->
			<div class="grid grid-cols-2 lg:grid-cols-12 lg:gap-x-6">
				{#each shown as item, i (`${item.label}-${i}`)}
					<div
						class={cn(
							'relative flex min-w-0 flex-col gap-2 py-5 lg:min-h-22 lg:py-4',
							spanClass[shown.length]?.[i],
							i >= 2 && 'border-t lg:border-t-0',
							i % 2 === 1 ? 'border-l pl-6 lg:border-l-0 lg:pl-0' : 'pr-6 lg:pr-0',
							i === shown.length - 1 && i % 2 === 0 && 'col-span-2',
							i > 0 &&
								"lg:before:absolute lg:before:inset-y-0 lg:before:-left-3 lg:before:w-px lg:before:bg-border lg:before:content-['']"
						)}
					>
						<dt class="label">{item.label}</dt>
						<dd class={cn('flex min-h-7 items-center text-base text-foreground', item.value && 'tabular-nums')}>
							{#if item.content}
								{@render item.content()}
							{:else}
								{item.value}
							{/if}
						</dd>
					</div>
				{/each}
			</div>
		{/if}

		{#each shownWideRows as item, i (`${item.label}-${i}`)}
			<div
				class={cn(
					'grid gap-x-6 gap-y-2 py-5 lg:grid-cols-12 lg:items-baseline',
					(shown.length > 0 || i > 0) && 'border-t'
				)}
			>
				<!-- Center the label's line box in the first 24px avatar row to align it with the name. -->
				<dt
					class="label lg:col-span-3 lg:has-[+dd_[data-slot=avatar]]:mt-[calc((1.5rem-1lh)/2)] lg:has-[+dd_[data-slot=avatar]]:self-start"
				>
					{item.label}
				</dt>
				<dd class="min-w-0 text-base text-foreground lg:col-span-9">
					{#if item.content}
						{@render item.content()}
					{:else}
						{item.value}
					{/if}
				</dd>
			</div>
		{/each}
	</dl>
{:else}
	<dl class={cn('grid grid-cols-1 border-y', columns !== 1 && 'sm:grid-cols-2', gridClass[columns], className)}>
		{#each shown as item, i (`${item.label}-${i}`)}
			<div
				class={cn(
					'flex min-w-0 flex-col gap-2 border-t py-5 first:border-t-0',
					// One column: a hairline between rows and nothing else. Otherwise the multi-column rules.
					columns !== 1 && 'pr-6 sm:pl-0 sm:even:border-l sm:even:pl-6 sm:[&:nth-child(-n+2)]:border-t-0',
					cellClass[columns]
				)}
			>
				<dt class="label">{item.label}</dt>
				<dd class="text-base text-foreground">
					{#if item.content}
						{@render item.content()}
					{:else}
						{item.value}
					{/if}
				</dd>
			</div>
		{/each}
	</dl>
{/if}
