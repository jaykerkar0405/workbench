<script lang="ts">
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import Seo from '$lib/components/seo.svelte';
	import { hackathons } from '$lib/hackathons';
	import HackathonCard from '$lib/components/hackathon-card.svelte';

	let mounted = $state(false);

	const sorted = $derived(
		[...hackathons].sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
	);

	onMount(() => {
		mounted = true;
	});
</script>

<Seo
	title="Hackathons | Jay Kerkar | Full-Stack Developer"
	description="Jay Kerkar's hackathon journey — 12+ hackathons including ETHOnline winner, ETHMumbai AI track winner, and multiple runner-up finishes across national and global competitions."
/>

<div class="container mx-auto max-w-7xl px-4 py-12">
	{#key mounted}
		<div in:fly={{ y: -20, duration: 600, delay: 0 }}>
			<section class="mb-16">
				<h2 class="mb-8 text-[1.6875rem] font-bold md:text-3xl">Hackathons</h2>

				<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
					{#each sorted as hackathon (hackathon.id)}
						<HackathonCard {hackathon} />
					{/each}
				</div>
			</section>
		</div>
	{/key}
</div>
