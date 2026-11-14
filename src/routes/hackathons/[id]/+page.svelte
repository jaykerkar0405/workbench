<script lang="ts">
	import Seo from '$lib/components/seo.svelte';
	import { Button } from '$lib/components/ui/button';
	import { Skeleton } from '$lib/components/ui/skeleton';
	import { reveal } from '$lib/components/reveal';
	import { formatDateRange, formatDuration, viewTransitionName } from '$lib/utils';
	import { getHackathonIcon, loadHackathonImages } from '$lib/assets/images';
	import { orderedHackathons, hackathonIndex } from '$lib/components/hackathon-order';
	import { projectIndex } from '$lib/components/project-order';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import TitleBlock from '$lib/components/title-block.svelte';
	import SpecSheet from '$lib/components/spec-sheet.svelte';
	import SectionHeading from '$lib/components/section-heading.svelte';
	import PrizeBadge from '$lib/components/prize-badge.svelte';
	import TeamStack from '$lib/components/team-stack.svelte';
	import Lightbox from '$lib/components/lightbox.svelte';
	import ProjectSpotlight from '$lib/components/project-spotlight.svelte';
	import PrevNext from '$lib/components/prev-next.svelte';

	let { data } = $props();

	const project = $derived(data.project);
	const hackathon = $derived(data.hackathon);
	const icon = $derived(getHackathonIcon(hackathon.id));
	const teamMembersData = $derived(data.teamMembersData || []);

	// Photos load on the client. Reset on every hackathon change and ignore a promise from the previous one.
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let images = $state<any[]>([]);
	let imagesLoading = $state(true);
	let lightboxOpen = $state(false);
	let lightboxIndex = $state(0);

	$effect(() => {
		const id = hackathon.id;
		let stale = false;
		images = [];
		imagesLoading = true;
		lightboxOpen = false;
		lightboxIndex = 0;

		loadHackathonImages(id).then(
			(loaded) => {
				if (stale) return;
				images = loaded;
				imagesLoading = false;
			},
			() => {
				if (stale) return;
				images = [];
				imagesLoading = false;
			}
		);

		return () => {
			stale = true;
		};
	});

	const showPhotos = $derived(imagesLoading || images.length > 0);
	const photosIndex = '01';
	const builtIndex = $derived(showPhotos ? '02' : '01');

	// Previous / next in the same order as the timeline (newest first); no wrap-around.
	const position = $derived(orderedHackathons.findIndex((h) => h.id === hackathon.id));
	const previous = $derived(position > 0 ? orderedHackathons[position - 1] : undefined);
	const next = $derived(position >= 0 ? orderedHackathons[position + 1] : undefined);

	const side = (h: (typeof orderedHackathons)[number]) => ({
		href: `/hackathons/${h.id}`,
		title: h.title,
		index: hackathonIndex(h.id),
		icon: getHackathonIcon(h.id),
		iconFit: 'contain' as const
	});

	const skeletonHeights = ['h-40', 'h-64', 'h-48', 'h-72', 'h-56', 'h-44'];

	const seoDescription = $derived(() => {
		const durationUnit = Number(hackathon.duration) === 1 ? 'hour' : 'hours';
		const prize = hackathon.prize
			? hackathon.prize.rank
				? ` Achieved ${hackathon.prize.rank} place.`
				: hackathon.prize.label
					? ` Won ${hackathon.prize.label}.`
					: ''
			: '';
		return `${hackathon.title} hackathon by ${hackathon.organizer} in ${hackathon.location}. ${hackathon.duration} ${durationUnit} event.${prize}`;
	});
</script>

<Seo description={seoDescription()} title="{hackathon.title} | Hackathons | Jay Kerkar" />

<div class="mx-auto max-w-7xl px-5 pt-10 pb-20 md:px-10 lg:pt-14 lg:pb-28">
	<TitleBlock
		parent={{ label: 'Hackathons', href: '/hackathons' }}
		title={hackathon.title}
		summary="{hackathon.organizer} · {hackathon.location}"
		{icon}
		iconFit="contain"
		iconTransitionName={viewTransitionName('hackathon-icon', hackathon.id)}
		titleTransitionName={viewTransitionName('hackathon-title', hackathon.id)}
	>
		{#snippet meta()}
			<PrizeBadge prize={hackathon.prize} />
		{/snippet}
		{#snippet actions()}
			<Button href={hackathon.website} target="_blank" rel="noopener noreferrer" variant="outline">Event site ↗</Button>
		{/snippet}
	</TitleBlock>

	<SpecSheet
		class="mt-12 lg:mt-16"
		columns={4}
		items={[
			{ label: 'Dates', value: formatDateRange(hackathon.timestamp, hackathon.duration) },
			{ label: 'Duration', value: formatDuration(hackathon.duration) },
			{ label: 'Organiser', value: hackathon.organizer },
			{ label: 'Location', value: hackathon.location }
		]}
	/>

	{#if showPhotos}
		<section class="mt-16 lg:mt-24" aria-label="Photos">
			{#if imagesLoading}
				<SectionHeading index={photosIndex} title="Photos" />
			{:else}
				<SectionHeading index={photosIndex} title="Photos">
					<span class="label tabular-nums">{images.length} {images.length === 1 ? 'photo' : 'photos'}</span>
				</SectionHeading>
			{/if}

			{#if imagesLoading}
				<div class="mt-10 columns-1 gap-4 md:columns-2 lg:columns-3" aria-busy="true">
					{#each skeletonHeights as height (height)}
						<Skeleton class="mb-4 w-full break-inside-avoid rounded-md {height}" />
					{/each}
				</div>
			{:else}
				<div class="mt-10 columns-1 gap-4 md:columns-2 lg:columns-3" {@attach reveal({ stagger: true })}>
					{#each images as image, i (i)}
						<button
							type="button"
							onclick={() => {
								lightboxIndex = i;
								lightboxOpen = true;
							}}
							aria-label="Open photo {i + 1} of {images.length}"
							class="mb-4 block w-full cursor-zoom-in break-inside-avoid overflow-hidden rounded-md border bg-muted transition-opacity duration-(--dur-1) ease-(--ease-out) outline-none hover:opacity-80 focus-visible:ring-3 focus-visible:ring-ring/50"
						>
							<EnhancedImage
								src={image}
								alt=""
								containerClass="w-full"
								skeletonClass="rounded-none"
								class="h-auto w-full"
							/>
						</button>
					{/each}
				</div>
			{/if}
		</section>

		{#if images.length > 0}
			<Lightbox {images} altPrefix="{hackathon.title} photo" bind:open={lightboxOpen} bind:index={lightboxIndex} />
		{/if}
	{/if}

	{#if project}
		<section class="mt-16 lg:mt-24" aria-label="Built here">
			<SectionHeading index={builtIndex} title="Built here" />

			<div class="mt-10">
				{#key project.id}
					<ProjectSpotlight {project} index={projectIndex(project.id)} {hackathon} />
				{/key}
			</div>

			<div class="mt-10">
				<p class="mb-3 label">Team</p>
				{#if teamMembersData.length > 0}
					<TeamStack members={teamMembersData} />
				{:else if project.teamMembers.length > 0}
					<ul class="flex flex-wrap gap-x-3 gap-y-1">
						{#each project.teamMembers as member (member.githubUsername)}
							<li>
								<a
									href={`https://github.com/${member.githubUsername}`}
									target="_blank"
									rel="noopener noreferrer"
									class="rounded-sm link-underline font-mono text-[0.85rem] outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
								>
									@{member.githubUsername}<span class="sr-only"> (opens in a new tab)</span>
								</a>
							</li>
						{/each}
					</ul>
				{:else}
					<span aria-label="No team">—</span>
				{/if}
			</div>
		</section>
	{/if}

	<PrevNext class="mt-20 lg:mt-28" prev={previous && side(previous)} next={next && side(next)} />
</div>
