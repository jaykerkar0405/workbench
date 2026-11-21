<script lang="ts">
	import Seo from '$lib/components/seo.svelte';
	import Stat from '$lib/components/stat.svelte';
	import { reveal } from '$lib/components/reveal';
	import TimelineEntry from '$lib/components/timeline-entry.svelte';
	import { orderedHackathons, hackathonsByYear, hackathonIndex, projectFor } from '$lib/components/hackathon-order';

	// A win is an event with a prize that has a rank or a label (the same test the badge uses).
	const isWin = (h: (typeof orderedHackathons)[number]) => !!(h.prize && (h.prize.rank || h.prize.label));
	const wins = orderedHackathons.filter(isWin).length;
	// Distinct places, as written in `location`, not counting Online.
	const cities = new Set(orderedHackathons.filter((h) => h.location !== 'Online').map((h) => h.location)).size;

	const stats = [
		{ value: orderedHackathons.length, label: 'Events' },
		{ value: wins, label: 'Wins' },
		{ value: cities, label: 'Cities' },
		{ value: hackathonsByYear.length, label: 'Years' }
	];

	const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;

	// "6 events · 3 wins" for a year; the wins part is left out when there are none.
	const yearLine = (items: typeof orderedHackathons) => {
		const n = items.filter(isWin).length;
		return [plural(items.length, 'event', 'events'), ...(n > 0 ? [plural(n, 'win', 'wins')] : [])].join(' · ');
	};
</script>

<Seo
	title="Hackathons | Jay Kerkar | Full-Stack Developer"
	description="Jay Kerkar's hackathon journey — 12+ hackathons including ETHOnline winner, ETHMumbai AI track winner, and multiple runner-up finishes across national and global competitions."
/>

<div class="mx-auto max-w-7xl px-5 pt-(--gap-header-title) pb-(--gap-section) md:px-10">
	<header>
		<h1 class="text-page-title">Hackathons</h1>

		<div class="bleed mt-(--gap-title-content) grid grid-cols-2 gap-x-6 gap-y-8 border-y py-8 md:grid-cols-4">
			{#each stats as stat (stat.label)}
				<Stat value={stat.value} label={stat.label} />
			{/each}
		</div>
	</header>

	<div class="mt-(--gap-section) flex flex-col gap-(--gap-section)">
		{#each hackathonsByYear as group (group.year)}
			<section aria-labelledby={`year-${group.year}`} class="lg:grid lg:grid-cols-12 lg:gap-x-6">
				<!-- Below lg a sticky mono bar under the 56px header; from lg a solid numeral in the first two columns. -->
				<div
					class="sticky top-14 z-20 -mx-5 bg-background px-5 py-3 md:-mx-10 md:px-10 lg:top-24 lg:col-span-2 lg:col-start-1 lg:row-start-1 lg:mx-0 lg:self-start lg:bg-transparent lg:p-0"
				>
					<h2 id={`year-${group.year}`}>
						<span class="label text-foreground tabular-nums lg:hidden">{group.year} · {yearLine(group.items)}</span>
						<span
							class="hidden text-[2.5rem] leading-none font-bold tracking-tighter text-foreground tabular-nums lg:block"
							>{group.year}</span
						>
					</h2>
					<p class="mt-3 hidden label tabular-nums lg:block">{yearLine(group.items)}</p>
				</div>

				<div class="relative mt-6 pl-7 lg:contents">
					<div
						aria-hidden="true"
						class="absolute inset-y-0 left-[3px] w-px lg:relative lg:inset-auto lg:col-start-2 lg:row-start-1 lg:w-auto"
					>
						<span data-timeline-spine class="absolute inset-y-0 left-0 w-px bg-border lg:right-[-12.5px] lg:left-auto"
						></span>
					</div>

					<ol class="[--node-x:24.5px] lg:col-span-10 lg:col-start-3 lg:row-start-1 lg:[--node-x:12px]">
						{#each group.items as hackathon (hackathon.id)}
							<li class="border-t py-6 first:border-t-0 first:pt-2 last:pb-2" {@attach reveal()}>
								<TimelineEntry {hackathon} index={hackathonIndex(hackathon.id)} project={projectFor(hackathon)} />
							</li>
						{/each}
					</ol>
				</div>
			</section>
		{/each}
	</div>
</div>
