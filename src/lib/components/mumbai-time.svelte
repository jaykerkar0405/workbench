<!--
	The live Mumbai time, `18:03 IST`, in the `label` style. Same technique as the footer's clock (footer.svelte): always
	Asia/Kolkata whatever the visitor's zone, rendered only after mount so the prerendered HTML and the hydrated DOM agree,
	updated on the minute, cleaned up on unmount. An invisible sizer reserves the width of the full text, so nothing shifts
	when the time appears; without JavaScript the slot reads `IST` alone.
-->
<script lang="ts">
	import { cn } from '$lib/utils';

	let { class: className }: { class?: string } = $props();

	const timeZone = 'Asia/Kolkata';
	const clockFormat = new Intl.DateTimeFormat('en-GB', {
		timeZone,
		hour: '2-digit',
		minute: '2-digit',
		hourCycle: 'h23'
	});
	const stampFormat = new Intl.DateTimeFormat('sv-SE', {
		timeZone,
		year: 'numeric',
		month: '2-digit',
		day: '2-digit',
		hour: '2-digit',
		minute: '2-digit',
		hourCycle: 'h23'
	});

	let time = $state<string | null>(null);
	let stamp = $state('');

	$effect(() => {
		const update = () => {
			const now = new Date();
			time = clockFormat.format(now);
			stamp = `${stampFormat.format(now).replace(' ', 'T')}+05:30`;
		};

		update();

		let interval: ReturnType<typeof setInterval> | undefined;
		const timeout = setTimeout(
			() => {
				update();
				interval = setInterval(update, 60_000);
			},
			60_000 - (Date.now() % 60_000)
		);

		return () => {
			clearTimeout(timeout);
			clearInterval(interval);
		};
	});
</script>

<p class={cn('inline-grid label tabular-nums', className)}>
	<span aria-hidden="true" class="invisible col-start-1 row-start-1 text-right select-none">00:00 IST</span>
	<span class="col-start-1 row-start-1 text-right"
		>{#if time}<time datetime={stamp}>{time} IST</time>{:else}IST{/if}</span
	>
</p>
