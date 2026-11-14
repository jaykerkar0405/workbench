<script lang="ts">
	import { cn, formatDateRange, formatDuration, viewTransitionName } from '$lib/utils';
	import type { Hackathon } from '$lib/hackathons/types';
	import type { Project } from '$lib/projects/types';
	import { getHackathonIcon, getProjectIcon } from '$lib/assets/images';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import PrizeBadge from '$lib/components/prize-badge.svelte';

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
	const won = $derived(!!hackathon.prize);
</script>

<article
	class={cn(
		'group/entry relative flex flex-col gap-4 rounded-md has-[[data-main-link]:focus-visible]:ring-3 has-[[data-main-link]:focus-visible]:ring-ring/50 lg:flex-row lg:items-center lg:justify-between lg:gap-8',
		className
	)}
>
	<!-- The marker on the spine: solid brand for a prize, hollow otherwise. Positioned by the page's CSS variables. -->
	<span
		aria-hidden="true"
		data-timeline-node
		class={cn(
			'pointer-events-none absolute top-[calc(2.4rem+2px)] left-[calc(var(--node-x)*-1-5px)] size-2.5 rounded-full ring-4 ring-background',
			won ? 'bg-brand' : 'border-[1.5px] border-muted-foreground bg-background'
		)}
	></span>

	<div class="flex min-w-0 flex-col gap-3">
		<p
			class="label tabular-nums transition-colors duration-(--dur-1) ease-(--ease-out) group-focus-within/entry:text-brand group-hover/entry:text-brand"
		>
			{index} · {formatDateRange(hackathon.timestamp, hackathon.duration)} · {hackathon.location}
		</p>

		<div class="flex flex-wrap items-center gap-x-3 gap-y-2">
			{#if icon}
				<div class="size-7 shrink-0" style:view-transition-name={viewTransitionName('hackathon-icon', hackathon.id)}>
					<EnhancedImage
						src={icon}
						alt=""
						containerClass="size-7"
						skeletonClass="rounded-sm"
						class="size-7 rounded-sm object-contain"
					/>
				</div>
			{/if}

			<h3
				class="min-w-0 text-2xl font-semibold tracking-tight"
				style:view-transition-name={viewTransitionName('hackathon-title', hackathon.id)}
			>
				<a
					href={`/hackathons/${hackathon.id}`}
					data-main-link
					class="block outline-none after:absolute after:inset-0 after:content-['']"
				>
					<span
						class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/entry:translate-x-1.5 motion-safe:group-hover/entry:translate-x-1.5"
						>{hackathon.title}</span
					>
				</a>
			</h3>

			<PrizeBadge prize={hackathon.prize} />
		</div>

		<p class="text-muted-foreground">{hackathon.organizer} · {formatDuration(hackathon.duration)}</p>

		{#if project}
			<div class="flex flex-wrap items-center gap-x-2.5 gap-y-1">
				<span class="label">Built →</span>
				{#if projectIcon}
					<EnhancedImage
						src={projectIcon}
						alt=""
						containerClass="size-5 shrink-0"
						skeletonClass="rounded-sm"
						class="size-5 rounded-sm object-cover"
					/>
				{/if}
				<a
					href={`/projects/${project.id}`}
					class="relative z-10 rounded-sm link-underline font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
					>{project.title}</a
				>
			</div>
		{/if}
	</div>

	<div class="flex shrink-0 items-center gap-x-6 text-sm font-medium">
		<a
			href={hackathon.website}
			target="_blank"
			rel="noopener noreferrer"
			class="group/ext relative z-10 rounded-sm link-underline outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
		>
			Event site <span
				aria-hidden="true"
				class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/ext:translate-x-0.5 motion-safe:group-hover/ext:-translate-y-0.5 motion-safe:group-focus-visible/ext:translate-x-0.5 motion-safe:group-focus-visible/ext:-translate-y-0.5"
				>↗</span
			>
			<span class="sr-only">(opens in a new tab)</span>
		</a>

		<span aria-hidden="true" class="text-muted-foreground">
			Details <span
				class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-within/entry:translate-x-1 motion-safe:group-hover/entry:translate-x-1"
				>→</span
			>
		</span>
	</div>
</article>
