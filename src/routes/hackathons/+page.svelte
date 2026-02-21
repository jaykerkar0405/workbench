<script lang="ts">
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import { hackathons } from '$lib/hackathons';
	import HackathonCard from '$lib/components/hackathon-card.svelte';

	let mounted = $state(false);

	onMount(() => {
		mounted = true;
	});
</script>

<svelte:head>
	<title>Hackathons | Jay Kerkar | Full-Stack Developer - Web, Mobile & Web3 Solutions</title>
</svelte:head>

<div class="container mx-auto max-w-7xl px-4 py-12">
	{#key mounted}
		<div in:fly={{ y: -20, duration: 600, delay: 0 }}>
			<section class="mb-16">
				<h2 class="mb-8 text-[1.6875rem] font-bold md:text-3xl">Hackathons</h2>

				<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
					{#each hackathons as hackathon (hackathon.id)}
						<HackathonCard {hackathon} />
					{/each}
				</div>
			</section>
		</div>
	{/key}
</div>
