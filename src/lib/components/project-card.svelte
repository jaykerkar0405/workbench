<script lang="ts">
	import { siGithub } from 'simple-icons';
	import { hackathons } from '$lib/hackathons';
	import { Button } from '$lib/components/ui/button';
	import type { Project } from '$lib/projects/types';
	import { getProjectIcon } from '$lib/assets/images';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { Card, CardContent } from '$lib/components/ui/card';
	import { ExternalLink, Zap, ArrowRight } from 'lucide-svelte';

	let { project }: { project: Project } = $props();

	const icon = $derived(getProjectIcon(project.id));

	const hackathon = $derived(
		project.hackathonId ? (hackathons.find((h) => h.id === project.hackathonId) ?? null) : null
	);

	const brandColor = (hex: string) => {
		const normalized = hex.toLowerCase();
		if (normalized === '000000' || normalized === 'ffffff') return 'currentColor';
		return `#${hex}`;
	};
</script>

<Card class="flex h-full flex-col overflow-hidden py-3">
	<CardContent class="flex flex-1 flex-col gap-5.5 p-6">
		<div class="flex items-start justify-between gap-4">
			<div class="flex items-start gap-3">
				{#if icon}
					<enhanced:img src={icon} alt={project.title} class="size-12 rounded-lg border border-border object-cover" />
				{/if}

				<div class="-mt-1 min-w-0 flex-1">
					<h3 class="mb-1 text-xl font-bold">{project.title}</h3>
					<p class="line-clamp-2 text-sm text-muted-foreground">{project.shortDescription}</p>
				</div>
			</div>

			<div class="flex shrink-0 gap-2">
				<a target="_blank" href={project.githubLink} rel="noopener noreferrer">
					<Button variant="outline" size="icon" aria-label="View on GitHub">
						<svg class="size-4" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
							<path d={siGithub.path} />
						</svg>
					</Button>
				</a>

				{#if project.deployedLink}
					<a target="_blank" rel="noopener noreferrer" href={project.deployedLink}>
						<Button variant="outline" size="icon" aria-label="View deployed site">
							<ExternalLink class="size-4" />
						</Button>
					</a>
				{/if}
			</div>
		</div>

		<div
			class="scrollbar-hide w-full overflow-x-auto overflow-y-hidden rounded-xl border border-border bg-secondary/30"
		>
			<Tooltip.Provider>
				<div class="flex items-center justify-between gap-3 px-4 py-3">
					{#each project.techStack as tech (tech.title)}
						<Tooltip.Root>
							<Tooltip.Trigger
								aria-label={tech.title}
								class="flex size-9 shrink-0 items-center justify-center rounded-lg hover:scale-110"
							>
								<svg
									width="26"
									height="26"
									viewBox="0 0 24 24"
									fill="currentColor"
									xmlns="http://www.w3.org/2000/svg"
									style="color: {brandColor(tech.hex)}"
								>
									<path d={tech.path} />
								</svg>
							</Tooltip.Trigger>
							<Tooltip.Content>
								<p class="font-medium">{tech.title}</p>
							</Tooltip.Content>
						</Tooltip.Root>
					{/each}
				</div>
			</Tooltip.Provider>
		</div>

		<div class="mt-auto flex items-center gap-4">
			{#if project.hackathonId}
				<a href="/hackathons/{project.hackathonId}" data-sveltekit-noscroll>
					<Button variant="outline" class="gap-2">
						<Zap class="size-4" />
						{hackathon ? `Built at ${hackathon.title}` : 'Built at hackathon'}
					</Button>
				</a>
			{/if}

			<a href="/projects/{project.id}" class="ml-auto" data-sveltekit-noscroll>
				<Button class="gap-2" aria-label="View {project.title} details">
					View
					<ArrowRight class="size-4" />
				</Button>
			</a>
		</div>
	</CardContent>
</Card>

<style>
	.scrollbar-hide {
		scrollbar-gutter: stable;
		scrollbar-width: thin;
		scrollbar-color: transparent transparent;
	}
	.scrollbar-hide::-webkit-scrollbar {
		width: 6px;
		height: 6px;
	}
	.scrollbar-hide:hover,
	.scrollbar-hide:focus-within {
		scrollbar-color: hsl(var(--border)) transparent;
	}
	.scrollbar-hide::-webkit-scrollbar-track {
		background: transparent;
	}
	.scrollbar-hide::-webkit-scrollbar-thumb {
		background: transparent;
		border-radius: 3px;
	}
	.scrollbar-hide:hover::-webkit-scrollbar-thumb,
	.scrollbar-hide:focus-within::-webkit-scrollbar-thumb {
		background: hsl(var(--border));
	}
</style>
