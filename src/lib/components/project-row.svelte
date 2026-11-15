<script lang="ts" module>
	import type { Hackathon } from '$lib/hackathons/types';

	/** Where a project was built, e.g. "ETHOnline 2025" or "HackByte 3.0 ’26". Shown in the `label` style. */
	export const eventLabel = (hackathon: Hackathon): string => {
		const year = hackathon.timestamp.slice(0, 4);
		return hackathon.title.includes(year) ? hackathon.title : `${hackathon.title} ’${year.slice(2)}`;
	};
</script>

<script lang="ts">
	import { cn, viewTransitionName } from '$lib/utils';
	import type { Project } from '$lib/projects/types';
	import { getProjectIcon } from '$lib/assets/images';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import ArrowRightIcon from '@lucide/svelte/icons/arrow-right';

	/*
	 * One row of the projects list. The title link is the row's only link and covers the whole row (stretched link), so
	 * there is one tab stop per row. From lg the row is one line: index, icon and title (and FEATURED), the event, an
	 * arrow; the description, tags and links live in the preview panel. Below lg it is two lines with the description (and, from md, the event on line one).
	 * `active` is the previewed row (it keeps the fill from lg up, where the preview panel exists), `tabbable` is the roving tab stop of the list.
	 */
	let {
		project,
		index,
		hackathon,
		featured = false,
		active = false,
		tabbable = true,
		onpreview,
		shareTransition = true,
		class: className
	}: {
		index: string;
		class?: string;
		project: Project;
		hackathon?: Hackathon;
		featured?: boolean;
		active?: boolean;
		tabbable?: boolean;
		onpreview?: () => void;
		shareTransition?: boolean;
	} = $props();

	const icon = $derived(getProjectIcon(project.id));
	const iconStyleName = $derived(shareTransition ? viewTransitionName('project-icon', project.id) : undefined);
	const titleStyleName = $derived(shareTransition ? viewTransitionName('project-title', project.id) : undefined);
</script>

<div
	data-row
	data-active={active || undefined}
	{@attach (node) => {
		// Hover and keyboard focus both move the preview (listeners, not attributes: the row itself is not interactive).
		const preview = () => onpreview?.();
		node.addEventListener('pointerenter', preview);
		node.addEventListener('focusin', preview);
		return () => {
			node.removeEventListener('pointerenter', preview);
			node.removeEventListener('focusin', preview);
		};
	}}
	class={cn(
		'group/row relative grid grid-cols-[auto_1fr_auto] items-center gap-x-3 gap-y-1 rounded-md px-3 py-4 transition-colors duration-(--dur-1) ease-(--ease-out) hover:bg-muted has-[[data-main-link]:focus-visible]:ring-3 has-[[data-main-link]:focus-visible]:ring-ring/50 md:grid-cols-[auto_minmax(0,1fr)_auto_1.25rem] lg:h-full lg:grid-cols-[2.5rem_minmax(0,1fr)_auto_1.25rem] lg:py-0 lg:data-active:bg-muted',
		className
	)}
>
	<span class="label tabular-nums lg:w-10">{index}</span>

	<div class="flex min-w-0 items-center gap-3">
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

		<h3 class="text-lg font-semibold" style:view-transition-name={titleStyleName}>
			<a
				href={`/projects/${project.id}`}
				data-main-link
				tabindex={tabbable ? 0 : -1}
				class="outline-none after:absolute after:inset-0 after:content-['']"
			>
				{project.title}
			</a>
		</h3>

		{#if featured}
			<span class="label whitespace-nowrap">Featured</span>
		{/if}
	</div>

	{#if hackathon}
		<span class="text-right label whitespace-nowrap max-md:hidden">{eventLabel(hackathon)}</span>
	{:else}
		<span class="max-md:hidden"></span>
	{/if}

	<ArrowRightIcon
		aria-hidden="true"
		class="pointer-events-none size-5 shrink-0 text-muted-foreground transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/row:translate-x-1 motion-safe:group-hover/row:translate-x-1 max-md:col-start-3 max-md:row-start-1"
	/>

	<p class="col-span-2 col-start-2 text-sm text-muted-foreground md:col-span-3 lg:hidden">{project.shortDescription}</p>
</div>
