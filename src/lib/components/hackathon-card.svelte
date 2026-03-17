<script lang="ts">
	import { resolve } from '$app/paths';
	import { Button } from '$lib/components/ui/button';
	import type { Hackathon } from '$lib/hackathons/types';
	import { Card, CardContent } from '$lib/components/ui/card';
	import { MapPin, Clock, Calendar, Trophy, ExternalLink, ArrowRight, Building2 } from 'lucide-svelte';

	let { hackathon }: { hackathon: Hackathon } = $props();

	const formatDateRange = (timestamp: string, duration: number): string => {
		const start = new Date(timestamp + 'T00:00:00');
		const end = new Date(start.getTime() + duration * 60 * 60 * 1000);
		const fmt = (d: Date, opts: Intl.DateTimeFormatOptions) => d.toLocaleDateString('en-US', opts);
		if (start.getMonth() === end.getMonth() && start.getFullYear() === end.getFullYear()) {
			return `${fmt(start, { month: 'short', day: 'numeric' })} – ${fmt(end, { day: 'numeric' })}, ${start.getFullYear()}`;
		}
		return `${fmt(start, { month: 'short', day: 'numeric' })} – ${fmt(end, { month: 'short', day: 'numeric' })}, ${end.getFullYear()}`;
	};

	const dateRange = $derived(formatDateRange(hackathon.timestamp, hackathon.duration));

	const prizeLabel = (h: Hackathon): string | null => {
		if (!h.prize) return null;
		if (h.prize.rank) {
			const map = { '1st': '🥇 1st Place', '2nd': '🥈 2nd Place', '3rd': '🥉 3rd Place' };
			return map[h.prize.rank];
		}
		return h.prize.label ?? null;
	};

	const badge = $derived(prizeLabel(hackathon));
</script>

<Card class="flex h-full flex-col overflow-hidden py-3">
	<CardContent class="flex flex-1 flex-col gap-5 p-6">
		<div class="flex items-start justify-between gap-4">
			<div class="flex items-start gap-3">
				<img
					alt={hackathon.title}
					src={`/hackathons/${hackathon.id}/icon.webp`}
					class="size-12 rounded-lg border border-border object-cover"
				/>

				<div class="-mt-1 min-w-0 flex-1">
					<h3 class="mb-1 text-xl font-bold">{hackathon.title}</h3>
					<div class="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-muted-foreground">
						<span class="flex items-center gap-1">
							<Calendar class="size-3.5 shrink-0" />
							{dateRange}
						</span>
					</div>
				</div>
			</div>

			<a target="_blank" rel="noopener noreferrer" href={hackathon.website} class="shrink-0">
				<Button variant="outline" size="icon" aria-label="Visit hackathon website">
					<ExternalLink class="size-4" />
				</Button>
			</a>
		</div>

		<div class="flex flex-col gap-2 rounded-xl border border-border bg-secondary/30 px-4 py-3">
			<span class="flex items-center gap-2 text-sm text-muted-foreground">
				<Clock class="size-4 shrink-0" />
				{hackathon.duration} Hours
			</span>
			<span class="flex items-center gap-2 text-sm text-muted-foreground">
				<Building2 class="size-4 shrink-0" />
				{hackathon.organizer}
			</span>
			<span class="flex items-center gap-2 text-sm text-muted-foreground">
				<MapPin class="size-4 shrink-0" />
				{hackathon.location}
			</span>
		</div>

		<div class="mt-auto flex items-center gap-3">
			{#if badge}
				<div
					class="flex items-center gap-1.5 rounded-full border border-border bg-secondary/50 px-3 py-1 text-sm font-medium"
				>
					<Trophy class="size-3.5 shrink-0" />
					{badge}
				</div>
			{/if}

			<a href={resolve(`/hackathons/${hackathon.id}`)} class="ml-auto" data-sveltekit-noscroll>
				<Button class="gap-2" aria-label="View {hackathon.title} details">
					View
					<ArrowRight class="size-4" />
				</Button>
			</a>
		</div>
	</CardContent>
</Card>
