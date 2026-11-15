<script lang="ts">
	import { tick } from 'svelte';
	import Seo from '$lib/components/seo.svelte';
	import { cn, formatDateRange, viewTransitionName } from '$lib/utils';
	import { Button } from '$lib/components/ui/button';
	import { GithubIcon } from '$lib/components/brand-icons';
	import { getProjectIcon, loadProjectScreenshots } from '$lib/assets/images';
	import { orderedProjects, projectIndex, hackathonFor } from '$lib/components/project-order';
	import TitleBlock from '$lib/components/title-block.svelte';
	import SpecSheet from '$lib/components/spec-sheet.svelte';
	import TagList from '$lib/components/tag-list.svelte';
	import PrizeBadge from '$lib/components/prize-badge.svelte';
	import TeamStack from '$lib/components/team-stack.svelte';
	import Gallery from '$lib/components/gallery.svelte';
	import VideoFacade from '$lib/components/video-facade.svelte';
	import PrevNext from '$lib/components/prev-next.svelte';

	let { data } = $props();

	const project = $derived(data.project);
	const repoData = $derived(data.repoData);
	const teamMembersData = $derived(data.teamMembersData || []);
	const ExtendedDescription = $derived(data.ExtendedDescription);

	const icon = $derived(getProjectIcon(project.id));
	const hackathon = $derived(hackathonFor(project));
	// The same test as the badge itself: a prize with neither a rank nor a label is no result.
	const hasPrize = $derived(!!(hackathon?.prize && (hackathon.prize.rank || hackathon.prize.label)));

	// Previous / next wrap around: the previous of the first is the last, the next of the last is the first.
	// With fewer than two projects there is nothing to go to, so neither side is given.
	const position = $derived(orderedProjects.findIndex((p) => p.id === project.id));
	const count = orderedProjects.length;
	const previous = $derived(position >= 0 && count > 1 ? orderedProjects[(position - 1 + count) % count] : undefined);
	const next = $derived(position >= 0 && count > 1 ? orderedProjects[(position + 1) % count] : undefined);

	const side = (p: (typeof orderedProjects)[number]) => ({
		href: `/projects/${p.id}`,
		title: p.title,
		index: projectIndex(p.id),
		icon: getProjectIcon(p.id)
	});

	const formatNumber = (num: number) => (num >= 1000 ? `${(num / 1000).toFixed(1)}k` : num.toString());

	// Screenshots: reset when the project changes, and ignore a promise that belongs to the previous one.
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let screenshots = $state<any[]>([]);
	let screenshotsLoading = $state(true);

	$effect(() => {
		const id = project.id;
		let stale = false;
		screenshotsLoading = true;
		screenshots = [];

		loadProjectScreenshots(id).then(
			(images) => {
				if (stale) return;
				screenshots = images;
				screenshotsLoading = false;
			},
			() => {
				if (stale) return;
				screenshots = [];
				screenshotsLoading = false;
			}
		);

		return () => {
			stale = true;
		};
	});

	// "On this page": built from the rendered prose headings.
	let prose = $state<HTMLElement>();
	let endMarker = $state<HTMLElement>();
	let sections = $state<{ id: string; text: string }[]>([]);
	let currentId = $state<string | null>(null);

	const slugify = (text: string) =>
		text
			.toLowerCase()
			.normalize('NFKD')
			.replace(/[^a-z0-9]+/g, '-')
			.replace(/^-+|-+$/g, '') || 'section';

	$effect(() => {
		// Re-run when the project (and therefore the rendered prose) changes.
		void project.id;
		void ExtendedDescription;
		const root = prose;
		if (!root) {
			sections = [];
			currentId = null;
			return;
		}

		let observer: IntersectionObserver | undefined;
		let cancelled = false;

		tick().then(() => {
			if (cancelled) return;

			const headings = [...root.querySelectorAll<HTMLElement>('h1, h2')];
			const used: Record<string, true> = {};

			for (const heading of headings) {
				let id = heading.id || slugify(heading.textContent ?? '');
				let candidate = id;
				for (let n = 2; candidate in used; n += 1) candidate = `${id}-${n}`;
				id = candidate;
				used[id] = true;
				heading.id = id;

				// The page's real <h1> is the title block; prose <h1>s are section headings.
				if (heading.tagName === 'H1') {
					heading.setAttribute('role', 'heading');
					heading.setAttribute('aria-level', '2');
				}
			}

			sections = headings.map((h) => ({ id: h.id, text: h.textContent?.trim() ?? '' }));

			// Ids only exist after mount, so a pasted /projects/<id>#<section> link is scrolled to here, once.
			if (location.hash.length > 1) {
				document.getElementById(decodeURIComponent(location.hash.slice(1)))?.scrollIntoView({ block: 'start' });
			}
			if (headings.length < 2) {
				currentId = null;
				return;
			}

			const update = () => {
				const line = window.innerHeight * 0.35;
				const atBottom = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2;
				let active = headings[0];
				for (const heading of headings) {
					if (heading.getBoundingClientRect().top <= line) active = heading;
				}
				if (atBottom) active = headings[headings.length - 1];
				currentId = active.id;
			};

			observer = new IntersectionObserver(update, { rootMargin: '-96px 0px -60% 0px', threshold: [0, 1] });
			for (const heading of headings) observer.observe(heading);
			if (endMarker) observer.observe(endMarker);
			update();
		});

		return () => {
			cancelled = true;
			observer?.disconnect();
		};
	});
</script>

<Seo title="{project.title} | Projects | Jay Kerkar" description={project.shortDescription} />

<div class="mx-auto max-w-7xl px-5 pt-(--gap-header-title) pb-[calc(var(--gap-section)-2rem)] md:px-10">
	<TitleBlock
		parent={{ label: 'Projects', href: '/projects' }}
		title={project.title}
		summary={project.shortDescription}
		{icon}
		iconTransitionName={viewTransitionName('project-icon', project.id)}
		titleTransitionName={viewTransitionName('project-title', project.id)}
	>
		{#snippet actions()}
			{#if project.deployedLink}
				<Button href={project.deployedLink} target="_blank" rel="noopener noreferrer" class="rounded-md">Live ↗</Button>
			{/if}

			<Button href={project.githubLink} target="_blank" rel="noopener noreferrer" variant="outline" class="rounded-md">
				<svg viewBox={GithubIcon.viewBox} fill="currentColor" class="size-4" aria-hidden="true">
					{#each GithubIcon.paths as d (d)}
						<path {d} />
					{/each}
				</svg>
				GitHub ↗
			</Button>

			{#if repoData}
				<span class="label tabular-nums">
					<span aria-hidden="true">★ {formatNumber(repoData.stargazers_count)}</span>
					<span class="sr-only">{formatNumber(repoData.stargazers_count)} GitHub stars</span>
				</span>
			{/if}
		{/snippet}
	</TitleBlock>

	<SpecSheet
		class="mt-(--gap-title-content)"
		variant="facts"
		items={[
			{ label: 'Event', content: hackathon ? eventCell : undefined },
			{ label: 'Dates', value: hackathon ? formatDateRange(hackathon.timestamp, hackathon.duration) : undefined },
			{ label: 'Result', content: hasPrize ? resultCell : undefined },
			{ label: 'Team', content: project.teamMembers.length > 0 ? teamCell : undefined }
		]}
		wide={{ label: 'Stack', content: project.techStack.length > 0 ? stackCell : undefined }}
	/>

	{#if screenshotsLoading || screenshots.length > 0}
		<section class="mt-(--gap-title-content)" aria-label="Screenshots">
			{#key project.id}
				<Gallery images={screenshots} loading={screenshotsLoading} altPrefix="{project.title} screenshot" />
			{/key}
		</section>
	{/if}

	{#if ExtendedDescription}
		<div class="mt-(--gap-section) grid gap-10 lg:grid-cols-12 lg:gap-x-6">
			<aside
				class={cn(
					'flex flex-col gap-10 lg:sticky lg:top-24 lg:col-span-4 lg:col-start-9 lg:row-start-1 lg:self-start',
					!project.videoLink && 'max-lg:hidden'
				)}
			>
				{#if sections.length >= 2}
					<nav aria-label="On this page" class="hidden lg:block">
						<p class="mb-3 label">On this page</p>
						<ul class="flex flex-col">
							{#each sections as section (section.id)}
								<li>
									<a
										href={`#${section.id}`}
										aria-current={currentId === section.id ? 'true' : undefined}
										class={cn(
											'relative block rounded-sm py-1.5 pl-4 text-sm transition-colors duration-(--dur-1) ease-(--ease-out) outline-none before:absolute before:inset-y-1 before:left-0 before:w-0.5 before:bg-brand before:opacity-0 hover:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50',
											currentId === section.id ? 'text-foreground before:opacity-100' : 'text-muted-foreground'
										)}
									>
										{section.text}
									</a>
								</li>
							{/each}
						</ul>
					</nav>
				{/if}

				{#if project.videoLink}
					<div>
						<p class="mb-3 label">Demo</p>
						{#key project.id}
							<VideoFacade url={project.videoLink} title="{project.title} demo" />
						{/key}
					</div>
				{/if}
			</aside>

			<div bind:this={prose} class="prose-log prose max-w-none min-w-0 lg:col-span-7 lg:col-start-1 lg:row-start-1">
				<ExtendedDescription />
			</div>
		</div>
	{:else if project.videoLink}
		<div class="mt-(--gap-section) max-w-2xl">
			<p class="mb-3 label">Demo</p>
			{#key project.id}
				<VideoFacade url={project.videoLink} title="{project.title} demo" />
			{/key}
		</div>
	{/if}

	<div bind:this={endMarker} aria-hidden="true"></div>

	<PrevNext class="mt-(--gap-section)" prev={previous && side(previous)} next={next && side(next)} />
</div>

{#snippet eventCell()}
	{#if hackathon}
		<a href={`/hackathons/${hackathon.id}`} class="w-fit rounded-sm link-underline">{hackathon.title}</a>
	{/if}
{/snippet}

{#snippet resultCell()}
	{#if hackathon}
		<PrizeBadge prize={hackathon.prize} />
	{/if}
{/snippet}

{#snippet stackCell()}
	<TagList items={project.techStack} />
{/snippet}

{#snippet teamCell()}
	<TeamStack members={teamMembersData} usernames={project.teamMembers.map((member) => member.githubUsername)} />
{/snippet}
