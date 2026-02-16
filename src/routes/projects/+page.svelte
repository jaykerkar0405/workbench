<script lang="ts">
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import { projects } from '$lib/projects';
	import ProjectCard from '$lib/components/project-card.svelte';

	const otherProjects = projects.filter((p) => !p.featured);
	const featuredProjects = projects.filter((p) => p.featured);

	let mounted = $state(false);

	onMount(() => {
		mounted = true;
	});
</script>

<svelte:head>
	<title>Projects | Jay Kerkar | Full-Stack Developer - Web, Mobile & Web3 Solutions</title>
</svelte:head>

<div class="container mx-auto max-w-7xl px-4 py-12">
	{#if featuredProjects.length > 0}
		{#key mounted}
			<div in:fly={{ y: -20, duration: 600, delay: 0 }}>
				<section class="mb-16">
					<h2 class="mb-8 text-[1.6875rem] font-bold md:text-3xl">Featured Projects</h2>

					<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
						{#each featuredProjects as project (project.id)}
							<ProjectCard {project} />
						{/each}
					</div>
				</section>
			</div>
		{/key}
	{/if}

	{#if otherProjects.length > 0}
		{#key mounted}
			<div in:fly={{ y: -20, duration: 600, delay: 150 }}>
				<section class="mb-16">
					<h2 class="mb-8 text-[1.6875rem] font-bold md:text-3xl">Other Projects</h2>

					<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
						{#each otherProjects as project (project.id)}
							<ProjectCard {project} />
						{/each}
					</div>
				</section>
			</div>
		{/key}
	{/if}
</div>
