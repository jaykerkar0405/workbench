<!--
	"Built here" on a hackathon page: the project made at the event. A screenshot in a mat across columns 1 to 8 and the
	text in columns 9 to 12, top-aligned with the mat. Below lg the text sits under the mat.

	The screenshot is contained, never cropped, with its own 8px corners on the mat's surface, the way the project
	gallery's lead frame does it. The title link is the one tab stop to the project page; the mat and "Case study →" are
	links for the pointer only (tabindex -1, hidden from screen readers), so a keyboard user does not meet one target
	three times.
-->
<script lang="ts">
	import { viewTransitionName } from '$lib/utils';
	import type { Project } from '$lib/projects/types';
	import { getProjectIcon } from '$lib/assets/images';
	import { projectIndex } from '$lib/components/project-order';
	import { projectScreenshots } from '$lib/components/project-screenshots';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import MediaMat from '$lib/components/media-mat.svelte';
	import TagList from '$lib/components/tag-list.svelte';
	import TeamStack from '$lib/components/team-stack.svelte';
	import type { ComponentProps } from 'svelte';

	let {
		project,
		members = []
	}: {
		project: Project;
		members?: ComponentProps<typeof TeamStack>['members'];
	} = $props();

	const icon = $derived(getProjectIcon(project.id));
	const screenshot = $derived(projectScreenshots(project.id)[0]);
	const href = $derived(`/projects/${project.id}`);

	const link =
		'link-underline group/ext rounded-sm text-sm font-medium text-foreground outline-none focus-visible:ring-3 focus-visible:ring-ring/50';
	const nudge =
		'inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-visible/ext:translate-x-0.5 motion-safe:group-focus-visible/ext:-translate-y-0.5 motion-safe:group-hover/ext:translate-x-0.5 motion-safe:group-hover/ext:-translate-y-0.5';
</script>

<article class="group/panel grid gap-8 lg:grid-cols-12 lg:items-start lg:gap-x-6">
	<div class="lg:col-span-8">
		<MediaMat ratio={16 / 9} zoom>
			<a {href} tabindex="-1" aria-hidden="true" class="absolute inset-0 block">
				<!-- A size container, so the image is limited with cqh / cqw (a percentage max-height cannot resolve through
					the <picture> element). The focus zoom of the title link is applied here, on top of the mat's hover zoom. -->
				<div
					class="[container-type:size] absolute inset-0 flex items-center justify-center transition-transform duration-300 ease-(--ease-out) motion-safe:group-has-[[data-main-link]:focus-visible]/panel:scale-[1.015] motion-reduce:transition-none"
				>
					{#if screenshot}
						<EnhancedImage
							src={screenshot}
							alt=""
							skeletonClass="rounded-md"
							containerClass="contents"
							class="h-auto max-h-[100cqh] w-auto max-w-[100cqw] rounded-md object-contain"
						/>
					{:else if icon}
						<EnhancedImage
							src={icon}
							alt=""
							containerClass="size-16"
							skeletonClass="rounded-md"
							class="size-16 rounded-md object-cover"
						/>
					{/if}
				</div>
			</a>
		</MediaMat>
	</div>

	<div class="flex min-w-0 flex-col gap-5 lg:col-span-4">
		<p class="label tabular-nums">Project {projectIndex(project.id)}</p>

		<div class="flex items-center gap-4">
			{#if icon}
				<div
					class="size-10 shrink-0 overflow-hidden rounded-md border bg-muted"
					style:view-transition-name={viewTransitionName('project-icon', project.id)}
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

			<h3 class="min-w-0 text-item-title" style:view-transition-name={viewTransitionName('project-title', project.id)}>
				<a {href} data-main-link class="rounded-sm outline-none focus-visible:ring-3 focus-visible:ring-ring/50">
					{project.title}
				</a>
			</h3>
		</div>

		<p class="text-lead">{project.shortDescription}</p>

		<TagList items={project.techStack} max={6} />

		<div class="flex flex-wrap items-center gap-x-6 gap-y-2">
			<a
				{href}
				tabindex="-1"
				aria-hidden="true"
				class="group/cs rounded-sm link-underline text-sm font-medium text-foreground outline-none group-has-[[data-main-link]:focus-visible]/panel:[background-size:100%_1px]"
			>
				Case study
				<span
					class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/cs:translate-x-1 motion-safe:group-focus-visible/cs:translate-x-1 motion-safe:group-has-[[data-main-link]:focus-visible]/panel:translate-x-1"
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

		{#if members.length > 0 || project.teamMembers.length > 0}
			<div class="flex flex-col gap-2">
				<p class="label">Team</p>
				<TeamStack {members} usernames={project.teamMembers.map((member) => member.githubUsername)} />
			</div>
		{/if}
	</div>
</article>
