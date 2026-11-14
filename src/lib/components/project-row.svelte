<script lang="ts" module>
	import type { Hackathon } from '$lib/hackathons/types';

	/** Where a project was built, e.g. "ETHOnline 2025" or "HackByte 3.0 ’26". Shown in the `label` style. */
	export const eventLabel = (hackathon: Hackathon): string => {
		const year = hackathon.timestamp.slice(0, 4);
		return hackathon.title.includes(year) ? hackathon.title : `${hackathon.title} ’${year.slice(2)}`;
	};
</script>

<script lang="ts">
	import { onMount } from 'svelte';
	import { cn, viewTransitionName } from '$lib/utils';
	import type { Project } from '$lib/projects/types';
	import { Button } from '$lib/components/ui/button';
	import * as HoverCard from '$lib/components/ui/hover-card';
	import { AspectRatio } from '$lib/components/ui/aspect-ratio';
	import { Skeleton } from '$lib/components/ui/skeleton';
	import { GithubIcon } from '$lib/components/brand-icons';
	import { getProjectIcon, loadProjectScreenshots } from '$lib/assets/images';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import TagList from '$lib/components/tag-list.svelte';
	import ArrowRightIcon from '@lucide/svelte/icons/arrow-right';
	import ExternalLinkIcon from '@lucide/svelte/icons/external-link';

	let {
		project,
		index,
		hackathon,
		shareTransition = true,
		class: className
	}: {
		index: string;
		class?: string;
		project: Project;
		hackathon?: Hackathon;
		shareTransition?: boolean;
	} = $props();

	const icon = $derived(getProjectIcon(project.id));
	const detailHref = $derived(`/projects/${project.id}`);

	// Hover preview: pointer devices at lg and up only; screenshots load once, on first hover or focus.
	let previewEnabled = $state(false);
	let previewOpen = $state(false);
	let screenshots = $state<Awaited<ReturnType<typeof loadProjectScreenshots>> | null>(null);
	let requested: Promise<void> | undefined;

	const ensureScreenshots = () => {
		if (!previewEnabled) return;
		requested ??= loadProjectScreenshots(project.id).then(
			(shots) => {
				screenshots = shots;
				if (shots.length === 0) previewOpen = false;
			},
			() => {
				screenshots = [];
				previewOpen = false;
			}
		);
	};

	const noScreenshots = $derived(screenshots !== null && screenshots.length === 0);

	onMount(() => {
		const query = window.matchMedia('(min-width: 1280px) and (hover: hover) and (pointer: fine)');
		const update = () => (previewEnabled = query.matches);
		update();
		query.addEventListener('change', update);
		return () => query.removeEventListener('change', update);
	});

	const iconStyleName = $derived(shareTransition ? viewTransitionName('project-icon', project.id) : undefined);
	const titleStyleName = $derived(shareTransition ? viewTransitionName('project-title', project.id) : undefined);

	/** Badges shown before "+N" in the row's tag column: three overflowed the 274 px cell for 2 of 13 projects at xl, two fit for all. */
	const TAGS_MAX = 2;

	const ext =
		'relative z-10 opacity-0 transition-opacity duration-(--dur-1) ease-(--ease-out) group-focus-within/row:opacity-100 group-hover/row:opacity-100 focus-visible:opacity-100 [@media(hover:none)]:opacity-100';
</script>

<article
	onpointerenter={ensureScreenshots}
	onfocusin={ensureScreenshots}
	class={cn(
		'group/row relative grid min-h-14 grid-cols-[auto_1fr_auto] items-center gap-x-3 gap-y-1 rounded-md px-3 py-3 transition-colors duration-(--dur-1) ease-(--ease-out) hover:bg-muted/50 has-[[data-main-link]:focus-visible]:ring-3 has-[[data-main-link]:focus-visible]:ring-ring/50 xl:min-h-[72px] xl:grid-cols-12 xl:gap-x-6 xl:px-4 xl:py-0',
		className
	)}
>
	<span
		class="label tabular-nums transition-colors duration-(--dur-1) ease-(--ease-out) group-focus-within/row:text-brand group-hover/row:text-brand xl:col-span-1"
	>
		{index}
	</span>

	<div class="flex min-w-0 items-center gap-3 xl:col-span-3">
		{#if icon}
			<div
				class="size-8 shrink-0 overflow-hidden rounded-sm border bg-muted"
				style:view-transition-name={iconStyleName}
			>
				<EnhancedImage
					src={icon}
					alt=""
					containerClass="size-8"
					skeletonClass="rounded-sm"
					class="size-8 object-cover"
				/>
			</div>
		{/if}

		<h3 class="min-w-0 text-lg font-semibold" style:view-transition-name={titleStyleName}>
			<HoverCard.Root
				bind:open={previewOpen}
				openDelay={150}
				closeDelay={80}
				disabled={!previewEnabled || noScreenshots}
			>
				<HoverCard.Trigger>
					{#snippet child({ props })}
						<!-- bits-ui marks the trigger as a button with a popup; this is a plain link to the project. -->
						<a
							{...props}
							href={detailHref}
							role={undefined}
							aria-haspopup={undefined}
							aria-expanded={undefined}
							data-main-link
							class="block truncate pr-2 outline-none after:absolute after:inset-0 after:content-['']"
						>
							<span
								class="inline-block max-w-full truncate align-bottom transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/row:translate-x-1.5 motion-safe:group-hover/row:translate-x-1.5"
								>{project.title}</span
							>
						</a>
					{/snippet}
				</HoverCard.Trigger>

				<HoverCard.Content side="bottom" align="start" class="w-80 p-1">
					<AspectRatio ratio={16 / 10} class="overflow-hidden rounded-sm border bg-muted">
						{#if screenshots && screenshots[0]}
							<EnhancedImage
								src={screenshots[0]}
								alt=""
								containerClass="size-full"
								skeletonClass="rounded-none"
								class="size-full object-cover object-top"
							/>
						{:else}
							<Skeleton class="size-full rounded-none" />
						{/if}
					</AspectRatio>
				</HoverCard.Content>
			</HoverCard.Root>
		</h3>
	</div>

	<div class="col-span-2 col-start-2 row-start-2 min-w-0 xl:col-span-3 xl:col-start-auto xl:row-start-auto">
		<div class="flex items-center gap-2">
			<p class="line-clamp-2 min-w-0 flex-1 text-sm text-muted-foreground xl:truncate xl:text-base">
				{project.shortDescription}
			</p>

			<!-- Space is always reserved so the description never re-truncates when these fade in. -->
			<div class="hidden w-[4.5rem] shrink-0 items-center justify-end gap-1 xl:flex">
				<Button
					href={project.githubLink}
					target="_blank"
					rel="noopener noreferrer"
					variant="ghost"
					size="icon-sm"
					aria-label={`${project.title} on GitHub`}
					class={ext}
				>
					<svg viewBox={GithubIcon.viewBox} fill="currentColor" class="size-4" aria-hidden="true">
						{#each GithubIcon.paths as d (d)}
							<path {d} />
						{/each}
					</svg>
				</Button>

				{#if project.deployedLink}
					<Button
						href={project.deployedLink}
						target="_blank"
						rel="noopener noreferrer"
						variant="ghost"
						size="icon-sm"
						aria-label={`${project.title} live site`}
						class={ext}
					>
						<ExternalLinkIcon class="size-4" aria-hidden="true" />
					</Button>
				{/if}
			</div>
		</div>
	</div>

	<div class="pointer-events-none relative z-10 hidden min-w-0 xl:col-span-3 xl:block [&_button]:pointer-events-auto">
		<TagList items={project.techStack} max={TAGS_MAX} class="flex-nowrap" />
	</div>

	<div class="hidden min-w-0 items-center gap-3 xl:col-span-2 xl:flex">
		<div class="min-w-0 flex-1">
			{#if hackathon}
				{@const label = eventLabel(hackathon)}
				<a
					href={`/hackathons/${hackathon.id}`}
					title={label}
					class="relative z-10 block truncate rounded-sm link-underline label outline-none hover:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50"
				>
					{label}
				</a>
			{:else}
				<span class="label" aria-label="No event">—</span>
			{/if}
		</div>

		<ArrowRightIcon
			aria-hidden="true"
			class="pointer-events-none size-5 shrink-0 -rotate-45 text-muted-foreground transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/row:rotate-0 motion-safe:group-hover/row:rotate-0"
		/>
	</div>

	<ArrowRightIcon
		aria-hidden="true"
		class="pointer-events-none col-start-3 row-start-1 size-5 -rotate-45 justify-self-end text-muted-foreground transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/row:rotate-0 motion-safe:group-hover/row:rotate-0 xl:hidden"
	/>
</article>
