<script lang="ts">
	import { cn, formatDateRange, formatDuration, viewTransitionName } from '$lib/utils';
	import type { Hackathon } from '$lib/hackathons/types';
	import type { Project } from '$lib/projects/types';
	import { getHackathonIcon, getProjectIcon } from '$lib/assets/images';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import PrizeBadge from '$lib/components/prize-badge.svelte';
	import ArrowRightIcon from '@lucide/svelte/icons/arrow-right';

	/*
	 * One entry of the hackathons timeline. From lg it sits on nine columns (the page's columns 4 to 12): the event in
	 * five (4-8), what was built there in three (9-11), the arrow in the last (12). The title link covers the whole entry
	 * (stretched link, one tab stop for the event); the built project is its own link above it. The hover fill is the
	 * article itself, 8px wider than the columns on each side so the text stays on the column lines, and it stops short
	 * of the spine.
	 */
	let {
		hackathon,
		index,
		project,
		class: className
	}: {
		index: string;
		class?: string;
		project?: Project;
		hackathon: Hackathon;
	} = $props();

	const icon = $derived(getHackathonIcon(hackathon.id));
	const projectIcon = $derived(project ? getProjectIcon(project.id) : undefined);
	const won = $derived(!!(hackathon.prize && (hackathon.prize.rank || hackathon.prize.label)));
</script>

<article
	class={cn(
		'group/entry relative -mx-2 -my-2 rounded-md px-2 py-2 transition-colors duration-(--dur-1) ease-(--ease-out) hover:bg-muted has-[[data-main-link]:focus-visible]:ring-3 has-[[data-main-link]:focus-visible]:ring-ring/50 lg:grid lg:grid-cols-9 lg:gap-x-6',
		className
	)}
>
	<div class="flex min-w-0 flex-col gap-2 lg:col-span-5">
		<p class="label leading-4 tabular-nums">
			{index} · {formatDateRange(hackathon.timestamp, hackathon.duration)} · {hackathon.location}
		</p>

		<div class="relative flex items-start gap-3">
			<!-- The marker on the spine: 8px, solid brand for a prize, a 1px outline otherwise. It sits in the title row, 10px
				down (half of the 28px first line, less half the node), so it stays centred on the title's first line however the
				meta line or the title wrap. Its x is the page's --node-x from the row's left edge, which is the column line. -->
			<span
				aria-hidden="true"
				data-timeline-node
				class={cn(
					'pointer-events-none absolute top-[10px] left-[calc(var(--node-x)*-1-4px)] size-2 rounded-full ring-4 ring-background',
					won ? 'bg-brand' : 'border border-muted-foreground bg-background'
				)}
			></span>
			{#if icon}
				<div
					class="flex h-7 shrink-0 items-center"
					style:view-transition-name={viewTransitionName('hackathon-icon', hackathon.id)}
				>
					<EnhancedImage
						src={icon}
						alt=""
						containerClass="size-7"
						skeletonClass="rounded-sm"
						class="size-7 rounded-sm object-contain"
					/>
				</div>
			{/if}

			<div class="flex min-w-0 flex-wrap items-baseline-last gap-x-3 gap-y-1">
				<h3
					class="min-w-0 text-item-title leading-7"
					style:view-transition-name={viewTransitionName('hackathon-title', hackathon.id)}
				>
					<a
						href={`/hackathons/${hackathon.id}`}
						data-main-link
						class="outline-none after:absolute after:inset-0 after:content-['']"
					>
						{hackathon.title}
					</a>
				</h3>

				<PrizeBadge prize={hackathon.prize} />
			</div>
		</div>

		<p class="text-muted-foreground">{hackathon.organizer} · {formatDuration(hackathon.duration)}</p>
	</div>

	{#if project}
		<div class="mt-4 flex min-w-0 flex-col gap-1.5 lg:col-span-3 lg:col-start-6 lg:mt-0">
			<div class="flex flex-wrap items-center gap-x-2.5 gap-y-1">
				<span class="label">Built</span>
				{#if projectIcon}
					<!-- The same box as the icon in the projects list rows (1px border, muted fill, 4px corners), so a near-white icon
						still reads as an icon. -->
					<div class="size-5 shrink-0 overflow-hidden rounded-sm border bg-muted">
						<EnhancedImage
							src={projectIcon}
							alt=""
							containerClass="size-full"
							skeletonClass="rounded-none"
							class="size-full object-cover"
						/>
					</div>
				{/if}
				<a
					href={`/projects/${project.id}`}
					class="relative z-10 rounded-sm link-underline font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
					>{project.title}</a
				>
			</div>
			<p class="text-sm text-muted-foreground">{project.shortDescription}</p>
		</div>
	{/if}

	<ArrowRightIcon
		aria-hidden="true"
		class="pointer-events-none size-5 shrink-0 text-muted-foreground transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/entry:translate-x-1 motion-safe:group-hover/entry:translate-x-1 max-lg:absolute max-lg:top-9 max-lg:right-2 lg:col-start-9 lg:row-start-1 lg:mt-7 lg:justify-self-end"
	/>
</article>
