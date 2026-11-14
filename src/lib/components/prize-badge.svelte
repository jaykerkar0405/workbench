<script lang="ts">
	import { cn } from '$lib/utils';
	import type { Prize } from '$lib/hackathons/types';
	import { Badge } from '$lib/components/ui/badge';

	let { prize, class: className }: { prize?: Prize; class?: string } = $props();

	const rankLabels = { '1st': '1st place', '2nd': '2nd place', '3rd': '3rd place' } as const;

	const base = 'rounded-sm font-mono text-[0.72rem] font-normal';
</script>

{#if prize && (prize.rank || prize.label)}
	<span class={cn('inline-flex flex-wrap items-center gap-1.5', className)}>
		{#if prize.rank}
			<Badge class={cn(base, 'bg-brand text-brand-foreground')}>{rankLabels[prize.rank]}</Badge>
		{/if}
		{#if prize.label}
			<Badge variant="outline" class={base}>{prize.label}</Badge>
		{/if}
	</span>
{/if}
