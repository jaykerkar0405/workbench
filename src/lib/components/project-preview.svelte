<!--
	The preview panel beside the projects list (from lg). One fixed panel that shows the previewed project: a screenshot
	in a mat (16:10, left top anchored, so a screenshot's own header and logo are always visible) and a text block.

	The panel never moves or resizes: the text blocks of every project in the list are stacked in one grid cell, so the
	cell is as tall as the tallest, and only the active one is visible (the others are invisible and inert, so they take
	no tab stop and are not read). The change is a 160ms crossfade of opacity. The image is a single slot: it is mounted
	only for the previewed project, so a screenshot is requested on its first preview, not on load.

	No view-transition-name in here: the row's icon and title carry them, and two elements with one name break the
	transition.
-->
<script lang="ts">
	import { fade } from 'svelte/transition';
	import { prefersReducedMotion } from 'svelte/motion';
	import { getProjectIcon } from '$lib/assets/images';
	import { projectScreenshots } from '$lib/components/project-screenshots';
	import { hackathonFor, projectIndex } from '$lib/components/project-order';
	import { eventLabel } from '$lib/components/project-row.svelte';
	import type { Project } from '$lib/projects/types';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import MediaMat from '$lib/components/media-mat.svelte';
	import PrizeBadge from '$lib/components/prize-badge.svelte';
	import TagList from '$lib/components/tag-list.svelte';

	let {
		projects,
		activeId,
		class: className
	}: {
		class?: string;
		projects: Project[];
		activeId: string | undefined;
	} = $props();

	const active = $derived(projects.find((project) => project.id === activeId));
	const screenshot = $derived(active ? projectScreenshots(active.id)[0] : undefined);
	const icon = $derived(active ? getProjectIcon(active.id) : undefined);

	const fadeMs = () => (prefersReducedMotion.current ? 0 : 160);

	const link =
		'link-underline group/ext rounded-sm text-sm font-medium text-foreground outline-none focus-visible:ring-3 focus-visible:ring-ring/50';
	const nudge =
		'inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-visible/ext:translate-x-0.5 motion-safe:group-focus-visible/ext:-translate-y-0.5 motion-safe:group-hover/ext:translate-x-0.5 motion-safe:group-hover/ext:-translate-y-0.5';
	const fadeClass =
		'transition-[opacity,visibility] duration-(--dur-page) ease-(--ease-out) motion-reduce:transition-none';
</script>

<aside aria-label="Preview" class={className}>
	<MediaMat ratio={16 / 10} zoom>
		<!-- A plain still fill until the screenshot has loaded; no pulse. -->
		<div class="absolute inset-0 bg-muted"></div>
		{#key active?.id}
			<div class="absolute inset-0" in:fade={{ duration: fadeMs() }} out:fade={{ duration: fadeMs() }}>
				{#if screenshot}
					<EnhancedImage
						src={screenshot}
						alt=""
						style="object-position: left top"
						skeletonClass="rounded-none"
						containerClass="size-full"
						class="size-full object-cover"
					/>
				{:else if icon}
					<div class="flex size-full items-center justify-center">
						<EnhancedImage
							src={icon}
							alt=""
							containerClass="size-16"
							skeletonClass="rounded-md"
							class="size-16 rounded-md object-cover"
						/>
					</div>
				{/if}
			</div>
		{/key}
	</MediaMat>

	<div class="mt-6 grid">
		{#each projects as project (project.id)}
			{@const hackathon = hackathonFor(project)}
			{@const current = project.id === activeId}
			<div
				inert={!current}
				class="col-start-1 row-start-1 flex min-w-0 flex-col gap-4 {fadeClass} {current
					? 'visible opacity-100'
					: 'invisible opacity-0'}"
			>
				<div class="flex min-h-5.5 flex-wrap items-center gap-x-3 gap-y-1">
					<p class="label tabular-nums">
						{projectIndex(project.id)}
						{#if hackathon}
							·
							<a
								href={`/hackathons/${hackathon.id}`}
								class="rounded-sm link-underline outline-none hover:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50"
								>{eventLabel(hackathon)}</a
							>
						{/if}
					</p>
					{#if hackathon}
						<PrizeBadge prize={hackathon.prize} />
					{/if}
				</div>

				<h2 class="text-section-title">
					<a
						href={`/projects/${project.id}`}
						class="rounded-sm outline-none focus-visible:ring-3 focus-visible:ring-ring/50">{project.title}</a
					>
				</h2>

				<p class="text-lead">{project.shortDescription}</p>

				<!-- One line: five tags from xl, three below (the column is narrower there). -->
				<TagList items={project.techStack} max={5} class="hidden flex-nowrap xl:flex" />
				<TagList items={project.techStack} max={3} class="flex flex-nowrap xl:hidden" />

				<div class="flex flex-wrap items-center gap-x-6 gap-y-2">
					<a href={`/projects/${project.id}`} class="{link} group/cs">
						Case study
						<span
							class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/cs:translate-x-1 motion-safe:group-focus-visible/cs:translate-x-1"
							>→</span
						>
					</a>
					<a href={project.githubLink} target="_blank" rel="noopener noreferrer" class={link}>
						GitHub <span aria-hidden="true" class={nudge}>↗</span>
						<span class="sr-only">(opens in a new tab)</span>
					</a>
					{#if project.deployedLink}
						<a href={project.deployedLink} target="_blank" rel="noopener noreferrer" class={link}>
							Live <span aria-hidden="true" class={nudge}>↗</span>
							<span class="sr-only">(opens in a new tab)</span>
						</a>
					{/if}
				</div>
			</div>
		{/each}
	</div>
</aside>
