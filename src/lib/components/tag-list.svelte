<script lang="ts">
	import { cn } from '$lib/utils';
	import type { TechStack } from '$lib/projects/types';
	import { Badge, badgeVariants } from '$lib/components/ui/badge';
	import * as Tooltip from '$lib/components/ui/tooltip';

	let {
		max,
		items,
		class: className
	}: {
		max?: number;
		class?: string;
		items: TechStack[];
	} = $props();

	const overflowing = $derived(max !== undefined && items.length > max);
	const shown = $derived(overflowing ? items.slice(0, max) : items);
	const hidden = $derived(overflowing ? items.slice(max) : []);
	const hiddenTitles = $derived(hidden.map((item) => item.title).join(', '));

	const tagClass = 'rounded-sm font-mono text-[0.72rem] font-normal text-muted-foreground';
</script>

{#if items.length > 0}
	<Tooltip.Provider>
		<ul class={cn('flex flex-wrap gap-1.5', className)}>
			{#each shown as item, i (`${item.title}-${i}`)}
				<li>
					<Badge variant="outline" class={tagClass}>{item.title}</Badge>
				</li>
			{/each}

			{#if hidden.length > 0}
				<li>
					<Tooltip.Root>
						<Tooltip.Trigger>
							{#snippet child({ props })}
								<button
									type="button"
									{...props}
									aria-label={`${hidden.length} more: ${hiddenTitles}`}
									class={cn(badgeVariants({ variant: 'outline' }), tagClass, 'cursor-help hover:text-foreground')}
								>
									+{hidden.length}
								</button>
							{/snippet}
						</Tooltip.Trigger>
						<Tooltip.Content class="font-mono text-[0.72rem]">{hiddenTitles}</Tooltip.Content>
					</Tooltip.Root>
				</li>
			{/if}
		</ul>
	</Tooltip.Provider>
{/if}
