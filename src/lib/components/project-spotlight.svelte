<script lang="ts">
	import { onMount } from 'svelte';
	import { cn, viewTransitionName } from '$lib/utils';
	import type { Project } from '$lib/projects/types';
	import type { Hackathon } from '$lib/hackathons/types';
	import { AspectRatio } from '$lib/components/ui/aspect-ratio';
	import { Skeleton } from '$lib/components/ui/skeleton';
	import { getProjectIcon, loadProjectScreenshots } from '$lib/assets/images';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import TagList from '$lib/components/tag-list.svelte';
	import { eventLabel } from '$lib/components/project-row.svelte';

	let {
		project,
		index,
		hackathon,
		reverse = false,
		shareTransition = true,
		class: className
	}: {
		index: string;
		class?: string;
		project: Project;
		reverse?: boolean;
		hackathon?: Hackathon;
		shareTransition?: boolean;
	} = $props();

	const icon = $derived(getProjectIcon(project.id));

	let screenshots = $state<Awaited<ReturnType<typeof loadProjectScreenshots>> | null>(null);
	let root = $state<HTMLElement>();

	// Screenshots load once the panel is within about one viewport height of the screen. Panels already
	// in view fire the observer's first callback straight away. The skeleton holds the frame meanwhile.
	onMount(() => {
		let cancelled = false;

		const load = () =>
			loadProjectScreenshots(project.id).then(
				(shots) => {
					if (!cancelled) screenshots = shots;
				},
				() => {
					if (!cancelled) screenshots = [];
				}
			);

		if (!root || typeof IntersectionObserver === 'undefined') {
			load();
			return () => {
				cancelled = true;
			};
		}

		const observer = new IntersectionObserver(
			(entries) => {
				if (entries.some((entry) => entry.isIntersecting)) {
					observer.disconnect();
					load();
				}
			},
			{ rootMargin: '100% 0px' }
		);
		observer.observe(root);

		return () => {
			cancelled = true;
			observer.disconnect();
		};
	});

	const iconStyleName = $derived(shareTransition ? viewTransitionName('project-icon', project.id) : undefined);
	const titleStyleName = $derived(shareTransition ? viewTransitionName('project-title', project.id) : undefined);

	const textLink =
		'link-underline group/ext relative z-10 rounded-sm font-mono text-[0.78rem] tracking-[0.08em] text-foreground uppercase outline-none focus-visible:ring-3 focus-visible:ring-ring/50';
	const nudge =
		'inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-visible/ext:translate-x-0.5 motion-safe:group-focus-visible/ext:-translate-y-0.5 motion-safe:group-hover/ext:translate-x-0.5 motion-safe:group-hover/ext:-translate-y-0.5';
</script>

<article
	bind:this={root}
	class={cn(
		'group/panel relative grid gap-8 rounded-md has-[[data-main-link]:focus-visible]:ring-3 has-[[data-main-link]:focus-visible]:ring-ring/50 lg:grid-cols-12 lg:items-center lg:gap-x-6',
		className
	)}
>
	<div class={cn('pointer-events-none lg:col-span-7', reverse && 'lg:order-2')}>
		<AspectRatio ratio={16 / 10} class="overflow-hidden rounded-md border bg-muted">
			{#if screenshots === null}
				<Skeleton class="size-full rounded-none" />
			{:else if screenshots[0]}
				<EnhancedImage
					src={screenshots[0]}
					alt={`${project.title} screenshot`}
					skeletonClass="rounded-none"
					containerClass="size-full origin-center transition-transform duration-(--dur-2) ease-(--ease-out) motion-safe:group-hover/panel:scale-[1.02]"
					class="size-full object-cover object-top"
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
		</AspectRatio>
	</div>

	<div class={cn('flex min-w-0 flex-col gap-5 lg:col-span-5', reverse && 'lg:order-1')}>
		<p class="label tabular-nums">
			{index}
			{#if hackathon}
				·
				<a
					href={`/hackathons/${hackathon.id}`}
					class="relative z-10 rounded-sm link-underline outline-none hover:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50"
					>{eventLabel(hackathon)}</a
				>
			{/if}
		</p>

		<div class="flex items-center gap-4">
			{#if icon}
				<div
					class="size-10 shrink-0 overflow-hidden rounded-md border bg-muted"
					style:view-transition-name={iconStyleName}
				>
					<EnhancedImage
						src={icon}
						alt=""
						containerClass="size-10"
						skeletonClass="rounded-md"
						class="size-10 object-cover"
					/>
				</div>
			{/if}

			<h3
				class="min-w-0 text-[2rem] leading-tight font-bold tracking-tight"
				style:view-transition-name={titleStyleName}
			>
				<a
					href={`/projects/${project.id}`}
					data-main-link
					class="outline-none after:absolute after:inset-0 after:content-['']"
				>
					{project.title}
				</a>
			</h3>
		</div>

		<p class="text-lg text-muted-foreground">{project.shortDescription}</p>

		<div class="pointer-events-none relative z-10 [&_button]:pointer-events-auto">
			<TagList items={project.techStack} max={6} />
		</div>

		<div class="flex flex-wrap items-center gap-x-6 gap-y-2">
			<span
				aria-hidden="true"
				class="link-underline font-mono text-[0.78rem] tracking-[0.08em] text-foreground uppercase group-hover/panel:[background-size:100%_1px] group-has-[[data-main-link]:focus-visible]/panel:[background-size:100%_1px]"
			>
				Case study
				<span
					class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/panel:translate-x-1 motion-safe:group-has-[[data-main-link]:focus-visible]/panel:translate-x-1"
					>→</span
				>
			</span>

			<a href={project.githubLink} target="_blank" rel="noopener noreferrer" class={textLink}>
				GitHub <span aria-hidden="true" class={nudge}>↗</span>
				<span class="sr-only">(opens in a new tab)</span>
			</a>

			{#if project.deployedLink}
				<a href={project.deployedLink} target="_blank" rel="noopener noreferrer" class={textLink}>
					Live <span aria-hidden="true" class={nudge}>↗</span>
					<span class="sr-only">(opens in a new tab)</span>
				</a>
			{/if}
		</div>
	</div>
</article>
