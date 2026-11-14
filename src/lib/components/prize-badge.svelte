<script lang="ts">
	import { cn } from '$lib/utils';
	import type { Prize } from '$lib/hackathons/types';
	import { Badge } from '$lib/components/ui/badge';

	let { prize, class: className }: { prize?: Prize; class?: string } = $props();

	const rankLabels = { '1st': '1st place', '2nd': '2nd place', '3rd': '3rd place' } as const;

	// One style for every prize: soft brand fill, brand text, sans, no border. The shadcn Badge defaults that are
	// overridden: h-5 (20px) becomes 22px, its transparent 1px border goes (border-0), the default variant's
	// bg-primary / text-primary-foreground become the soft pair, and font-medium and text-xs are kept as they are.
	const badgeClass = 'h-5.5 rounded-sm border-0 bg-brand-soft px-2 text-xs font-medium text-brand';
</script>

{#if prize && (prize.rank || prize.label)}
	<span class={cn('inline-flex flex-wrap items-center gap-1.5', className)}>
		{#if prize.rank}
			<Badge class={badgeClass}>{rankLabels[prize.rank]}</Badge>
		{/if}
		{#if prize.label}
			<Badge class={badgeClass}>{prize.label}</Badge>
		{/if}
	</span>
{/if}
