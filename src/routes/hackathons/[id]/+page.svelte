<script lang="ts">
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import { Button } from '$lib/components/ui/button';
	import type { Hackathon } from '$lib/hackathons/types';
	import ProjectCard from '$lib/components/project-card.svelte';
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Users, MapPin, Calendar, Clock, Building2, Trophy, ExternalLink } from 'lucide-svelte';

	let { data } = $props();

	const project = $derived(data.project);
	const hackathon = $derived(data.hackathon);
	const images = $derived(data.images || []);
	const teamMembersData = $derived(data.teamMembersData || []);

	let mounted = $state(false);

	onMount(() => {
		mounted = true;
	});

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

<svelte:head>
	<title>{hackathon.title} | Hackathons | Jay Kerkar</title>
	<meta name="description" content="{hackathon.title} by {hackathon.organizer} in {hackathon.location}" />
</svelte:head>

{#key mounted}
	<div class="container mx-auto max-w-7xl px-4 py-12">
		<div class="mb-8" in:fly={{ y: -20, duration: 600, delay: 0 }}>
			<div class="flex flex-wrap items-start justify-between gap-4">
				<div class="flex items-start gap-4">
					<img
						alt={hackathon.title}
						src={`/hackathons/${hackathon.id}/icon.png`}
						class="size-15 rounded-lg border border-border object-cover"
					/>
					<div class="-mt-1 flex flex-col lg:gap-1">
						<h1 class="text-[1.675rem] font-bold">{hackathon.title}</h1>
						<div class="flex flex-wrap items-center gap-x-3 gap-y-1 text-[0.9rem] text-muted-foreground">
							<span class="flex items-center gap-1">
								<MapPin class="size-3.5 shrink-0" />
								{hackathon.location}
							</span>
							<span class="flex items-center gap-1">
								<Calendar class="size-3.5 shrink-0" />
								{dateRange}
							</span>
							<span class="flex items-center gap-1">
								<Clock class="size-3.5 shrink-0" />
								{hackathon.duration} Hours
							</span>
							<span class="flex items-center gap-1">
								<Building2 class="size-3.5 shrink-0" />
								{hackathon.organizer}
							</span>
						</div>
					</div>
				</div>

				<div class="flex flex-wrap items-center gap-3">
					{#if badge}
						<div
							class="flex items-center gap-1.5 rounded-full border border-border bg-secondary/50 px-3 py-1.5 text-sm font-medium"
						>
							<Trophy class="size-3.5 shrink-0" />
							{badge}
						</div>
					{/if}
					<a target="_blank" rel="noopener noreferrer" href={hackathon.website}>
						<Button variant="outline" size="icon" aria-label="Visit hackathon website">
							<ExternalLink class="size-4" />
						</Button>
					</a>
				</div>
			</div>
		</div>

		<div class="grid grid-cols-1 items-start gap-6 lg:grid-cols-3">
			<div class="flex flex-col gap-5" in:fly={{ y: -20, duration: 600, delay: 300 }}>
				{#if project}
					<ProjectCard {project} />
				{/if}

				{#if teamMembersData.length > 0}
					<Card>
						<CardHeader>
							<CardTitle class="flex items-center gap-2 text-lg">
								<Users class="size-5" />
								Team
							</CardTitle>
						</CardHeader>
						<CardContent class="-mt-2 py-0">
							<div class="grid gap-4">
								{#each teamMembersData as member (member.username)}
									<a
										target="_blank"
										href={member.profileUrl}
										rel="noopener noreferrer"
										class="flex items-center gap-4 rounded-lg border border-border bg-secondary/30 p-4 transition-colors hover:bg-secondary/50"
									>
										<img src={member.avatar} alt={member.name} class="size-12 rounded-full border-2 border-border" />
										<div class="flex flex-col gap-1">
											<span class="font-semibold">{member.name}</span>
											<span class="text-sm text-muted-foreground">@{member.username}</span>
										</div>
									</a>
								{/each}
							</div>
						</CardContent>
					</Card>
				{/if}
			</div>

			{#if images.length > 0}
				<div class="lg:col-span-2" in:fly={{ y: -20, duration: 600, delay: 450 }}>
					<div class="columns-2 gap-3">
						{#each images as image, i (i)}
							<div class="mb-3 break-inside-avoid overflow-hidden rounded-xl border border-border">
								<img src={image} alt="{hackathon.title} Image {i + 1}" class="h-auto w-full" />
							</div>
						{/each}
					</div>
				</div>
			{/if}
		</div>
	</div>
{/key}
