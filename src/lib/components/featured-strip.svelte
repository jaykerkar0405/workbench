<!--
	The featured strip of /projects below lg: three tiles in a native horizontal scroller (scroll-snap, no carousel
	library), above the list. Each tile is one link to the case study: a 16:10 mat with the first screenshot (cover,
	anchored left top, like the desktop preview), then the title and the event. The strip bleeds to the screen edges; its
	padding and scroll-padding match the page's, so the first tile lines up with the content and the page itself never
	scrolls sideways.

	Tile width: 80% of the content width up to 20rem below md (so the next tile peeks in on a phone and the frame never
	grows past about 190px tall on a wide phone), 20rem from md. The tiles carry no view-transition-name: the list rows
	below own the project-icon / project-title names, and a name must exist once per page.
-->
<script lang="ts">
	import type { Attachment } from 'svelte/attachments';
	import { flushSync } from 'svelte';
	import { cn, viewTransitionName } from '$lib/utils';
	import type { Project } from '$lib/projects/types';
	import { hackathonFor } from '$lib/components/project-order';
	import { projectScreenshots } from '$lib/components/project-screenshots';
	import { eventLabel } from '$lib/components/project-row.svelte';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import MediaMat from '$lib/components/media-mat.svelte';

	/*
	 * The tiles carry no view-transition-name until one is activated: `transferred` is the project whose names have been
	 * handed over from its list row to its tile for the navigation that is starting (the page sets it through `onactivate`
	 * and the row for that project drops its names). flushSync makes the DOM say so before SvelteKit's onNavigate captures
	 * the old page for the transition. The tile's title carries `project-title-<id>`; the mat carries no name (a 16:10
	 * screenshot morphing into the 56px icon looked wrong, see the report), so the icon comes in with the root crossfade.
	 */
	let {
		projects,
		transferred = null,
		onactivate,
		class: className
	}: {
		projects: Project[];
		transferred?: string | null;
		onactivate?: (id: string) => void;
		class?: string;
	} = $props();

	const activate = (event: MouseEvent, id: string) => {
		if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
		onactivate?.(id);
		flushSync();
	};

	// Keyboard focus on a tile that is only partly in view: browsers do not always scroll such a tile into view, so the
	// strip does it itself, to the snap position (the tile's left edge on the content edge). Instant under reduced motion.
	const revealFocused: Attachment<HTMLElement> = (strip) => {
		const onfocusin = (event: FocusEvent) => {
			const tile = (event.target as HTMLElement).closest('li');
			if (!tile) return;
			const view = strip.getBoundingClientRect();
			const box = tile.getBoundingClientRect();
			if (box.left >= view.left && box.right <= view.right) return;
			const inset = parseFloat(getComputedStyle(strip).scrollPaddingLeft) || 0;
			strip.scrollBy({
				left: box.left - view.left - inset,
				behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth'
			});
		};
		strip.addEventListener('focusin', onfocusin);
		return () => strip.removeEventListener('focusin', onfocusin);
	};
</script>

<ul
	{@attach revealFocused}
	aria-label="Featured projects"
	class={cn(
		'-mx-5 -my-1 flex snap-x snap-mandatory scroll-px-5 [scrollbar-width:none] gap-3 overflow-x-auto px-5 py-1 motion-safe:scroll-smooth md:-mx-10 md:scroll-px-10 md:px-10 [&::-webkit-scrollbar]:hidden',
		className
	)}
>
	{#each projects as project, i (project.id)}
		{@const hackathon = hackathonFor(project)}
		{@const screenshot = projectScreenshots(project.id)[0]}
		<li class="w-[min(80%,20rem)] shrink-0 snap-start md:w-80">
			<a
				href={`/projects/${project.id}`}
				onclick={(event) => activate(event, project.id)}
				class="group/tile block rounded-lg outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
			>
				<MediaMat ratio={16 / 10} zoom>
					{#if screenshot}
						<EnhancedImage
							src={screenshot}
							alt=""
							loading={i === 0 ? 'eager' : 'lazy'}
							style="object-position: left top"
							skeletonClass="rounded-none"
							containerClass="size-full"
							class="size-full object-cover"
						/>
					{/if}
				</MediaMat>

				<p
					class="mt-3 w-fit text-lg leading-tight font-semibold"
					style:view-transition-name={transferred === project.id
						? viewTransitionName('project-title', project.id)
						: undefined}
				>
					{project.title}
				</p>
				{#if hackathon}
					<p class="mt-1 label">{eventLabel(hackathon)}</p>
				{/if}
			</a>
		</li>
	{/each}
</ul>
