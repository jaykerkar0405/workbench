<script lang="ts">
	import Seo from '$lib/components/seo.svelte';
	import { Button } from '$lib/components/ui/button';
	import { formatDateRange, formatDuration, viewTransitionName } from '$lib/utils';
	import { getHackathonIcon } from '$lib/assets/images';
	import { hackathonPhotos } from '$lib/components/hackathon-photos';
	import { orderedHackathons, hackathonIndex } from '$lib/components/hackathon-order';
	import TitleBlock from '$lib/components/title-block.svelte';
	import SpecSheet from '$lib/components/spec-sheet.svelte';
	import SectionHeading from '$lib/components/section-heading.svelte';
	import { reveal } from '$lib/components/reveal';
	import PrizeBadge from '$lib/components/prize-badge.svelte';
	import Lightbox from '$lib/components/lightbox.svelte';
	import PhotoGrid from '$lib/components/photo-grid.svelte';
	import BuiltHere from '$lib/components/built-here.svelte';
	import PrevNext from '$lib/components/prev-next.svelte';

	let { data } = $props();

	const project = $derived(data.project);
	const hackathon = $derived(data.hackathon);
	const icon = $derived(getHackathonIcon(hackathon.id));
	const teamMembersData = $derived(data.teamMembersData || []);

	// Known at render time (see hackathon-photos.ts), so they are in the prerendered HTML and nothing shifts.
	const images = $derived(hackathonPhotos(hackathon.id));
	const firstSection = $derived(images.length > 0 ? 'photos' : 'built');
	const builtIndex = $derived(firstSection === 'photos' ? '02' : '01');

	let lightboxOpen = $state(false);
	let lightboxIndex = $state(0);

	// Close the lightbox when moving to another event.
	$effect(() => {
		void hackathon.id;
		lightboxOpen = false;
		lightboxIndex = 0;
	});

	// Previous / next in the same order as the timeline (newest first), wrapping around: the previous of the first is
	// the last, the next of the last is the first. With fewer than two events neither side is given.
	const position = $derived(orderedHackathons.findIndex((h) => h.id === hackathon.id));
	const count = orderedHackathons.length;
	const previous = $derived(position >= 0 && count > 1 ? orderedHackathons[(position - 1 + count) % count] : undefined);
	const next = $derived(position >= 0 && count > 1 ? orderedHackathons[(position + 1) % count] : undefined);

	const side = (h: (typeof orderedHackathons)[number]) => ({
		href: `/hackathons/${h.id}`,
		title: h.title,
		index: hackathonIndex(h.id),
		icon: getHackathonIcon(h.id),
		iconFit: 'contain' as const
	});

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

<div class="mx-auto max-w-7xl px-5 pt-(--gap-header-title) pb-[calc(var(--gap-section)-2rem)] md:px-10">
	<TitleBlock
		parent={{ label: 'Hackathons', href: '/hackathons' }}
		title={hackathon.title}
		{icon}
		iconFit="contain"
		iconTransitionName={viewTransitionName('hackathon-icon', hackathon.id)}
		titleTransitionName={viewTransitionName('hackathon-title', hackathon.id)}
	>
		{#snippet badge()}
			<PrizeBadge prize={hackathon.prize} />
		{/snippet}
		{#snippet actions()}
			<Button href={hackathon.website} target="_blank" rel="noopener noreferrer" variant="outline" class="rounded-md"
				>Event site ↗</Button
			>
		{/snippet}
	</TitleBlock>

	<SpecSheet
		class="mt-(--gap-title-content)"
		columns={4}
		items={[
			{ label: 'Dates', value: formatDateRange(hackathon.timestamp, hackathon.duration) },
			{ label: 'Duration', value: formatDuration(hackathon.duration) },
			{ label: 'Organiser', value: hackathon.organizer },
			{ label: 'Location', value: hackathon.location }
		]}
	/>

	{#if firstSection === 'photos'}
		<section class="mt-(--gap-title-content)" aria-label="Photos">
			<div {@attach reveal()}>
				<SectionHeading index="01" title="Photos" rule={false}>
					<span class="label tabular-nums">{images.length} {images.length === 1 ? 'photo' : 'photos'}</span>
				</SectionHeading>
			</div>

			<PhotoGrid
				class="mt-(--gap-heading)"
				{images}
				onopen={(i) => {
					lightboxIndex = i;
					lightboxOpen = true;
				}}
			/>
		</section>

		<Lightbox {images} altPrefix="{hackathon.title} photo" bind:open={lightboxOpen} bind:index={lightboxIndex} />
	{/if}

	{#if project}
		{@const isFirst = firstSection === 'built'}
		<section class={isFirst ? 'mt-(--gap-title-content)' : 'mt-(--gap-section)'} aria-label="Built here">
			<div {@attach reveal()}>
				<SectionHeading index={builtIndex} title="Built here" rule={!isFirst} />
			</div>

			<div class="mt-(--gap-heading)">
				{#key project.id}
					<BuiltHere {project} members={teamMembersData} />
				{/key}
			</div>
		</section>
	{/if}

	<PrevNext class="mt-(--gap-section)" prev={previous && side(previous)} next={next && side(next)} />
</div>
