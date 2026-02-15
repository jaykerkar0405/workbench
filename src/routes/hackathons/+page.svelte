<script lang="ts">
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';

	let mounted = $state(false);

	onMount(() => {
		mounted = true;
	});
</script>

<svelte:head>
	<title>Hackathons | Jay Kerkar</title>
	<meta name="description" content="My hackathon participations and achievements" />
</svelte:head>

{#if mounted}
	<main class="mx-auto max-w-7xl px-6 py-12 md:px-16 xl:px-6">
		<div class="mb-12" in:fly={{ y: -20, duration: 600, delay: 0 }}>
			<h1 class="mb-4 text-4xl font-bold tracking-tight">Hackathons</h1>
			<p class="text-lg text-muted-foreground">My journey through various hackathons and competitive coding events</p>
		</div>

		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3" in:fly={{ y: -20, duration: 600, delay: 150 }}>
			<Card>
				<CardHeader>
					<CardTitle>Hackathon Coming Soon</CardTitle>
				</CardHeader>
				<CardContent>
					<p class="text-muted-foreground">Check back soon for hackathon updates</p>
				</CardContent>
			</Card>
		</div>
	</main>
{/if}
