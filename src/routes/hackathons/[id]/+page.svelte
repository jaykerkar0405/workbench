<script lang="ts">
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';

	let { data } = $props();
	let mounted = $state(false);

	onMount(() => {
		mounted = true;
	});
</script>

{#if mounted}
	<div class="container mx-auto px-4 py-16" in:fly={{ y: -20, duration: 600, delay: 0 }}>
		<h1 class="mb-4 text-4xl font-bold">Hackathon ID:</h1>
		<p class="text-2xl">{data.id}</p>
	</div>
{/if}
