<script lang="ts">
	import { tick } from 'svelte';
	import { navigating } from '$app/state';
	import { flip } from 'svelte/animate';
	import { fade } from 'svelte/transition';
	import { cubicOut } from 'svelte/easing';
	import { prefersReducedMotion } from 'svelte/motion';
	import { MediaQuery } from 'svelte/reactivity';
	import Seo from '$lib/components/seo.svelte';
	import { reveal } from '$lib/components/reveal';
	import {
		featuredProjects,
		orderedProjects as ordered,
		projectIndex,
		hackathonFor
	} from '$lib/components/project-order';
	import * as ToggleGroup from '$lib/components/ui/toggle-group';
	import { cn } from '$lib/utils';
	import { segmentedContainer, segmentedIndicator, segmentedItem } from '$lib/components/segmented';
	import ProjectRow from '$lib/components/project-row.svelte';
	import ProjectPreview from '$lib/components/project-preview.svelte';
	import FeaturedStrip from '$lib/components/featured-strip.svelte';

	const withHackathon = ordered.filter((p) => p.hackathonId);
	const withLive = ordered.filter((p) => p.deployedLink);
	const featuredIds = new Set(featuredProjects.map((p) => p.id));

	type FilterKey = 'all' | 'featured' | 'hackathon' | 'live';

	const filters: { key: FilterKey; label: string; short: string; count: number }[] = [
		{ key: 'all', label: 'All', short: 'All', count: ordered.length },
		{ key: 'featured', label: 'Featured', short: 'Featured', count: featuredProjects.length },
		{ key: 'hackathon', label: 'Hackathon builds', short: 'Hackathon', count: withHackathon.length },
		{ key: 'live', label: 'Live', short: 'Live', count: withLive.length }
	];

	let filter = $state<FilterKey>('all');

	// One list for every filter; featured come first because `ordered` already puts them first.
	const rows = $derived(
		filter === 'all'
			? ordered
			: filter === 'featured'
				? featuredProjects
				: filter === 'hackathon'
					? withHackathon
					: withLive
	);
	const shown = $derived(rows.length);

	// The previewed project: the last row hovered or focused, or the first row of the current filter.
	// The project whose transition names a tapped strip tile has taken over from its row, for one navigation.
	let transferred = $state<string | null>(null);

	// A tapped tile's names are only borrowed for one navigation. When a navigation ends without leaving this page (it
	// was cancelled or failed) the row gets its names back; so it does if no navigation started at all after the tap.
	let wasNavigating = false;
	$effect(() => {
		if (navigating.to) {
			wasNavigating = true;
		} else if (wasNavigating) {
			wasNavigating = false;
			transferred = null;
		}
	});
	const borrow = (id: string) => {
		transferred = id;
		setTimeout(() => {
			if (!navigating.to && transferred === id) transferred = null;
		}, 600);
	};

	let previewed = $state<string | null>(null);
	const activeId = $derived(rows.some((p) => p.id === previewed) ? (previewed ?? undefined) : rows[0]?.id);

	const setFilter = (next: FilterKey) => {
		filter = next;
		previewed = null; // the preview switches to the first remaining row
	};

	const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;

	// The count line, in parts: the first and last stay in one piece, so the line breaks at a "·" (and balances) and
	// never leaves a word like "FEATURED" alone on the second line.
	const summaryParts = [
		plural(ordered.length, 'project', 'projects'),
		`${withHackathon.length} built at ${withHackathon.length === 1 ? 'a hackathon' : 'hackathons'}`,
		`${featuredProjects.length} featured`
	];

	// Every duration collapses to zero for reduced motion.
	const ms = (n: number) => (prefersReducedMotion.current ? 0 : n);

	// The preview panel (and with it the roving tab stop) exists from lg. Below it every row link is a tab stop.
	const wide = new MediaQuery('min-width: 1024px', false);

	// Keyboard: one tab stop in the list (the previewed row). Arrow keys, Home and End move focus between rows, which
	// updates the preview; the next Tab leaves the list and lands in the preview panel, acting on the project arrowed to.
	let list = $state<HTMLElement>();
	const onkeydown = async (event: KeyboardEvent) => {
		const keys = ['ArrowDown', 'ArrowUp', 'Home', 'End'];
		if (!wide.current || !keys.includes(event.key) || !list) return;
		const links = [...list.querySelectorAll<HTMLElement>('[data-main-link]')];
		const current = links.findIndex((link) => link === document.activeElement);
		if (current === -1) return;
		event.preventDefault();
		const target =
			event.key === 'Home'
				? 0
				: event.key === 'End'
					? links.length - 1
					: Math.max(0, Math.min(links.length - 1, current + (event.key === 'ArrowDown' ? 1 : -1)));
		const link = links[target];
		link.tabIndex = 0;
		link.focus();
		await tick();
	};
</script>

<Seo
	title="Projects | Jay Kerkar | Full-Stack Developer"
	description="Browse Jay Kerkar's full-stack projects spanning Web3 dApps, AI-powered applications, and developer tools. Featuring award-winning hackathon builds using React, SvelteKit, Solidity, and more."
/>

<div class="mx-auto max-w-7xl px-5 pt-(--gap-header-title) pb-(--gap-section) md:px-10">
	<!-- The filter's bottom edge is the count line's bottom edge (items-end on the block), not the title block's. -->
	<header class="flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between">
		<div class="flex flex-col gap-4">
			<h1 class="text-page-title">Projects</h1>
			<p class="label [text-wrap:balance] tabular-nums">
				<span class="whitespace-nowrap">{summaryParts[0]}</span> · {summaryParts[1]} ·
				<span class="whitespace-nowrap">{summaryParts[2]}</span>
			</p>
		</div>

		<div class="w-full lg:w-auto">
			<ToggleGroup.Root
				type="single"
				aria-label="Filter projects"
				spacing={1}
				{@attach segmentedIndicator}
				class={cn(segmentedContainer, 'relative flex h-9 w-full items-center lg:inline-flex lg:w-max')}
				bind:value={
					() => filter,
					(next) => {
						// Clicking the active segment leaves it selected (the group reports an empty value for it).
						if (next) setFilter(next as FilterKey);
					}
				}
			>
				{#each filters as item (item.key)}
					<ToggleGroup.Item
						value={item.key}
						aria-label={`${item.label}, ${item.count}`}
						class={cn(
							segmentedItem,
							'h-6.5 min-w-fit flex-1 gap-1.5 px-2 hover:bg-transparent data-[state=on]:hover:bg-foreground min-[480px]:gap-2 min-[480px]:px-3 lg:flex-none lg:px-4'
						)}
					>
						<!-- Short labels under 480px; the accessible name above is always the long one with its count. -->
						<span aria-hidden="true" class="min-[480px]:hidden">{item.short}</span>
						<span aria-hidden="true" class="max-[479px]:hidden">{item.label}</span>
						<span aria-hidden="true" class="font-mono text-xs tabular-nums opacity-70">{item.count}</span>
					</ToggleGroup.Item>
				{/each}
			</ToggleGroup.Root>
		</div>

		<p class="sr-only" aria-live="polite">Showing {plural(shown, 'project', 'projects')}</p>
	</header>

	{#if rows.length > 0}
		{#if filter === 'all'}
			<FeaturedStrip
				class="mt-(--gap-title-content) lg:hidden"
				projects={featuredProjects}
				{transferred}
				onactivate={borrow}
			/>
		{/if}

		<div
			class={cn(
				'grid gap-x-6 lg:mt-(--gap-title-content) lg:grid-cols-12 lg:items-start',
				filter === 'all' ? 'mt-8' : 'mt-(--gap-title-content)'
			)}
		>
			<section class="lg:col-span-7" aria-label="Project index">
				<p id="list-help" class="sr-only">
					Use the up and down arrow keys to move between projects and change the preview. Tab moves on to the preview.
				</p>

				<ol
					bind:this={list}
					aria-describedby="list-help"
					{@attach (node) => {
						node.addEventListener('keydown', onkeydown);
						return () => node.removeEventListener('keydown', onkeydown);
					}}
					class="divide-y border-y"
					{@attach reveal({ stagger: true })}
				>
					{#each rows as project (project.id)}
						<li
							animate:flip={{ duration: ms(220), easing: cubicOut }}
							in:fade={{ duration: ms(200) }}
							out:fade={{ duration: ms(120) }}
							class="lg:h-11"
						>
							<ProjectRow
								{project}
								index={projectIndex(project.id)}
								hackathon={hackathonFor(project)}
								featured={featuredIds.has(project.id)}
								shareTransition={project.id !== transferred}
								active={project.id === activeId}
								tabbable={!wide.current || project.id === activeId}
								onpreview={() => (previewed = project.id)}
							/>
						</li>
					{/each}
				</ol>
			</section>

			<ProjectPreview class="sticky top-24 max-lg:hidden lg:col-span-5" projects={rows} {activeId} />
		</div>
	{:else}
		<p class="mt-(--gap-title-content) label text-muted-foreground">No projects match this filter.</p>
	{/if}
</div>
