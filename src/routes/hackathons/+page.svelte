<script lang="ts">
	import Seo from '$lib/components/seo.svelte';
	import Stat from '$lib/components/stat.svelte';
	import { reveal } from '$lib/components/reveal';
	import TimelineEntry from '$lib/components/timeline-entry.svelte';
	import { orderedHackathons, hackathonsByYear, hackathonIndex, projectFor } from '$lib/components/hackathon-order';

	const hours = orderedHackathons.reduce((total, h) => total + h.duration, 0);
	const wins = orderedHackathons.filter((h) => h.prize).length;
	const cities = Object.keys(
		Object.fromEntries(orderedHackathons.filter((h) => h.location !== 'Online').map((h) => [h.location, true]))
	).length;

	const stats = [
		{ value: orderedHackathons.length, label: 'Events' },
		{ value: wins, label: 'Podiums & track wins' },
		{ value: hours, label: 'Hours hacked' },
		{ value: cities, label: 'Cities' }
	];

	const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;
</script>

<Seo
	title="Hackathons | Jay Kerkar | Full-Stack Developer"
	description="Jay Kerkar's hackathon journey — 12+ hackathons including ETHOnline winner, ETHMumbai AI track winner, and multiple runner-up finishes across national and global competitions."
/>

<div class="mx-auto max-w-7xl px-5 pt-12 pb-20 md:px-10 lg:pt-16 lg:pb-28">
	<header>
		<h1 class="text-page-title">Hackathons</h1>

		<div class="mt-10 grid grid-cols-2 gap-x-6 gap-y-8 border-y py-8 md:grid-cols-4 lg:mt-14">
			{#each stats as stat (stat.label)}
				<Stat value={stat.value} label={stat.label} />
			{/each}
		</div>
	</header>

	<div class="mt-16 flex flex-col gap-16 lg:mt-24 lg:gap-28">
		{#each hackathonsByYear as group (group.year)}
			<section aria-labelledby={`year-${group.year}`} class="lg:grid lg:grid-cols-12 lg:gap-x-6">
				<div
					class="sticky top-14 z-20 bg-background py-3 lg:top-24 lg:col-span-2 lg:row-start-1 lg:self-start lg:bg-transparent lg:py-0"
				>
					<h2 id={`year-${group.year}`}>
						<span class="label text-foreground tabular-nums lg:hidden"
							>{group.year} · {plural(group.items.length, 'event', 'events')}</span
						>
						<span
							class="hidden text-[clamp(3rem,6vw,5rem)] leading-none font-bold tracking-tighter text-transparent tabular-nums [-webkit-text-stroke:1px_var(--foreground)] lg:block"
							>{group.year}</span
						>
					</h2>
					<p class="mt-3 hidden label tabular-nums lg:block">{plural(group.items.length, 'event', 'events')}</p>
				</div>

				<div class="relative mt-6 pl-7 lg:contents">
					<div
						aria-hidden="true"
						class="absolute inset-y-0 left-[3px] w-px lg:relative lg:inset-auto lg:col-start-3 lg:row-start-1 lg:w-auto"
					>
						<span data-timeline-spine class="absolute inset-y-0 left-0 w-px bg-border lg:right-[-12.5px] lg:left-auto"
						></span>
					</div>

					<ol class="[--node-x:24.5px] lg:col-span-9 lg:col-start-4 lg:row-start-1 lg:[--node-x:12px]">
						{#each group.items as hackathon (hackathon.id)}
							<li class="border-t py-10 first:border-t-0 first:pt-0 last:pb-0" {@attach reveal()}>
								<TimelineEntry {hackathon} index={hackathonIndex(hackathon.id)} project={projectFor(hackathon)} />
							</li>
						{/each}
					</ol>
				</div>
			</section>
		{/each}
	</div>
</div>
