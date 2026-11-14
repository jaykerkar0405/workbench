<script lang="ts">
	import { flip } from 'svelte/animate';
	import { fade } from 'svelte/transition';
	import { cubicOut } from 'svelte/easing';
	import { prefersReducedMotion } from 'svelte/motion';
	import { projects } from '$lib/projects';
	import Seo from '$lib/components/seo.svelte';
	import { hackathons } from '$lib/hackathons';
	import type { Project } from '$lib/projects/types';
	import { reveal } from '$lib/components/reveal';
	import * as ToggleGroup from '$lib/components/ui/toggle-group';
	import ProjectRow from '$lib/components/project-row.svelte';
	import ProjectSpotlight from '$lib/components/project-spotlight.svelte';

	const hackathonTimestamp = (p: Project): number => {
		if (!p.hackathonId) return -Infinity;
		const h = hackathons.find((h) => h.id === p.hackathonId);
		return h ? new Date(h.timestamp).getTime() : -Infinity;
	};

	const sortByHackathon = (a: Project, b: Project) => hackathonTimestamp(b) - hackathonTimestamp(a);

	const otherProjects = projects.filter((p) => !p.featured).sort(sortByHackathon);
	const featuredProjects = projects.filter((p) => p.featured).sort(sortByHackathon);

	// A project's number is its position in "featured (sorted) then the rest (sorted)", from 01. It never
	// changes under a filter, and the detail pages use the same rule.
	const ordered = [...featuredProjects, ...otherProjects];
	const indexById = Object.fromEntries(ordered.map((p, i) => [p.id, String(i + 1).padStart(2, '0')]));
	const hackathonById = Object.fromEntries(hackathons.map((h) => [h.id, h]));

	const withHackathon = ordered.filter((p) => p.hackathonId);
	const withLive = ordered.filter((p) => p.deployedLink);

	type FilterKey = 'all' | 'featured' | 'hackathon' | 'live';

	const filters: { key: FilterKey; label: string; count: number }[] = [
		{ key: 'all', label: 'All', count: ordered.length },
		{ key: 'featured', label: 'Featured', count: featuredProjects.length },
		{ key: 'hackathon', label: 'Hackathon builds', count: withHackathon.length },
		{ key: 'live', label: 'Live', count: withLive.length }
	];

	let filter = $state<FilterKey>('all');

	const spotlights = $derived(filter === 'all' || filter === 'featured' ? featuredProjects : []);
	const rows = $derived(
		filter === 'all' ? otherProjects : filter === 'hackathon' ? withHackathon : filter === 'live' ? withLive : []
	);
	const shown = $derived(spotlights.length + rows.length);

	const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;

	const summary = `${plural(ordered.length, 'project', 'projects')} · ${withHackathon.length} built at ${
		withHackathon.length === 1 ? 'a hackathon' : 'hackathons'
	} · ${featuredProjects.length} featured`;

	// Every duration collapses to zero for reduced motion.
	const ms = (n: number) => (prefersReducedMotion.current ? 0 : n);
</script>

<Seo
	title="Projects | Jay Kerkar | Full-Stack Developer"
	description="Browse Jay Kerkar's full-stack projects spanning Web3 dApps, AI-powered applications, and developer tools. Featuring award-winning hackathon builds using React, SvelteKit, Solidity, and more."
/>

<div class="mx-auto max-w-7xl px-5 pt-12 pb-20 md:px-10 lg:pt-16 lg:pb-28">
	<header class="flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between">
		<div class="flex flex-col gap-4">
			<h1 class="text-display">Projects</h1>
			<p class="label tabular-nums">{summary}</p>
		</div>

		<div class="-m-1 max-w-full [scrollbar-width:none] overflow-x-auto p-1 lg:overflow-visible">
			<ToggleGroup.Root
				type="single"
				variant="outline"
				aria-label="Filter projects"
				class="w-max rounded-sm"
				bind:value={() => filter, (next) => (filter = (next || 'all') as FilterKey)}
			>
				{#each filters as item (item.key)}
					<ToggleGroup.Item
						value={item.key}
						class="gap-2 font-mono text-[0.78rem] tracking-[0.04em] group-data-horizontal/toggle-group:data-[spacing=0]:first:rounded-l-sm group-data-horizontal/toggle-group:data-[spacing=0]:last:rounded-r-sm data-[state=on]:bg-primary data-[state=on]:text-primary-foreground data-[state=on]:hover:bg-primary"
					>
						{item.label}
						<span class="tabular-nums opacity-70">{item.count}</span>
					</ToggleGroup.Item>
				{/each}
			</ToggleGroup.Root>
		</div>

		<p class="sr-only" aria-live="polite">Showing {plural(shown, 'project', 'projects')}</p>
	</header>

	{#if spotlights.length > 0}
		<section
			class="mt-16 lg:mt-20"
			in:fade={{ duration: ms(200) }}
			out:fade={{ duration: ms(120) }}
			aria-label="Featured projects"
		>
			<p class="mb-10 label tabular-nums">Featured · {spotlights.length}</p>

			<div class="flex flex-col gap-20 lg:gap-28">
				{#each spotlights as project, i (project.id)}
					<div {@attach i > 0 ? reveal() : undefined}>
						<ProjectSpotlight
							{project}
							index={indexById[project.id]}
							hackathon={project.hackathonId ? hackathonById[project.hackathonId] : undefined}
							reverse={i % 2 === 1}
						/>
					</div>
				{/each}
			</div>
		</section>
	{/if}

	{#if rows.length > 0}
		<section class={spotlights.length > 0 ? 'mt-24 lg:mt-32' : 'mt-16 lg:mt-20'} aria-label="Project index">
			<p class="mb-6 label tabular-nums">Index · {rows.length}</p>

			<ol class="divide-y border-y" {@attach reveal({ stagger: true })}>
				{#each rows as project (project.id)}
					<li
						animate:flip={{ duration: ms(280), easing: cubicOut }}
						in:fade={{ duration: ms(200) }}
						out:fade={{ duration: ms(120) }}
					>
						<ProjectRow
							{project}
							index={indexById[project.id]}
							hackathon={project.hackathonId ? hackathonById[project.hackathonId] : undefined}
						/>
					</li>
				{/each}
			</ol>
		</section>
	{/if}

	{#if shown === 0}
		<p class="mt-16 label text-muted-foreground lg:mt-20">No projects match this filter.</p>
	{/if}
</div>
