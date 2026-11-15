<!--
	The home page's wins table, printed in a terminal: `$ wins --sort date`, a real <table> with one row per hackathon whose
	prize has a rank or a label (newest first, joined to its project), a closing line and a final prompt with the cursor.
	Everything is derived from the data. Each row is one link to the hackathon (a stretched link in the EVENT cell).

	Printing: once, when the table is in view (or when `play()` is called, the hook for the scroll transition), the command
	types in about 400ms and the rows print one every 45ms, opacity only. Every row is always in the layout, so the box
	never changes size. The not-yet-printed parts are hidden only under `html.js` and motion-safe and from md up, so
	without JavaScript, under reduced motion and on a phone the whole table is simply there.
-->
<script lang="ts">
	import { cn } from '$lib/utils';
	import { orderedHackathons, projectFor } from '$lib/components/hackathon-order';
	import Terminal from '$lib/components/terminal.svelte';

	let { autoplay = true, class: className }: { autoplay?: boolean; class?: string } = $props();

	// Same labels as the prize badge (which keeps its own copy).
	const rankLabels = { '1st': '1st place', '2nd': '2nd place', '3rd': '3rd place' } as const;

	const month = (timestamp: string) =>
		new Date(`${timestamp}T00:00:00`).toLocaleDateString('en-US', { month: 'short', year: 'numeric' });

	const rows = orderedHackathons
		.filter((h) => h.prize && (h.prize.rank || h.prize.label))
		.map((h) => ({
			id: h.id,
			result: [h.prize?.rank ? rankLabels[h.prize.rank] : '', h.prize?.label ?? ''].filter(Boolean).join(', '),
			event: h.title,
			when: month(h.timestamp),
			built: projectFor(h)?.title
		}));

	const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;
	const closing = `${plural(rows.length, 'win', 'wins')} · ${plural(orderedHackathons.length, 'event', 'events')}`;

	const command = 'wins --sort date';
	const COMMAND_MS = 400;
	const ROW_MS = 45;
	// Steps after the command: the header row, each data row, the closing line, the final prompt.
	const steps = rows.length + 3;

	let root = $state<HTMLElement | null>(null);
	let started = $state(false);
	let typed = $state(command.length);
	let printed = $state(0);
	let timers: ReturnType<typeof setTimeout>[] = [];
	let played = false;

	const showAll = () => {
		started = true;
		typed = command.length;
		printed = steps;
	};

	/** Starts the print (once). Called by the in-view trigger, or from outside with `autoplay={false}`. */
	export function play() {
		if (played) return;
		played = true;
		started = true;
		typed = 0;
		const per = COMMAND_MS / command.length;
		for (let i = 1; i <= command.length; i += 1) timers.push(setTimeout(() => (typed = i), i * per));
		for (let i = 1; i <= steps; i += 1) timers.push(setTimeout(() => (printed = i), COMMAND_MS + i * ROW_MS));
	}

	$effect(() => {
		const el = root;
		if (!el) return;

		// Phones and reduced motion: everything at once.
		if (matchMedia('(prefers-reduced-motion: reduce)').matches || !matchMedia('(min-width: 768px)').matches) {
			showAll();
			return;
		}
		if (!autoplay) return;

		const observer = new IntersectionObserver(
			(entries) => {
				if (entries.some((entry) => entry.isIntersecting)) {
					observer.disconnect();
					play();
				}
			},
			{ threshold: 0.4 }
		);
		observer.observe(el);

		return () => {
			observer.disconnect();
			for (const timer of timers) clearTimeout(timer);
			timers = [];
		};
	});

	// Hidden until printed, only with JavaScript, motion allowed, from md up.
	const hide = 'motion-safe:md:in-[.js]:opacity-0';
	const pending = (step: number) => (printed >= step ? undefined : hide);

	const cell = 'py-0 pr-4 text-left align-top font-normal whitespace-nowrap md:first:pl-3 md:last:pr-3 xl:pr-6';
</script>

<div bind:this={root} class={className}>
	<Terminal title="jay@workbench: ~" bodyClass="lg:max-xl:p-6">
		<p class={cn('whitespace-nowrap', started ? undefined : hide)}>
			<span class="text-muted-foreground">$</span>
			{command.slice(0, typed)}<span class="invisible">{command.slice(typed)}</span>
		</p>

		<div class="-mx-3 max-md:mx-0 md:overflow-x-auto">
			<table class="w-full border-separate border-spacing-0 text-left whitespace-nowrap md:w-max">
				<caption class="sr-only">Hackathon wins, newest first</caption>
				<thead class={cn('text-muted-foreground max-md:sr-only', pending(1))}>
					<tr>
						<th scope="col" class={cell}>RESULT</th>
						<th scope="col" class={cell}>EVENT</th>
						<th scope="col" class={cn(cell, 'max-md:hidden')}>WHEN</th>
						<th scope="col" class={cn(cell, 'max-md:hidden')}>BUILT</th>
					</tr>
				</thead>
				<tbody>
					{#each rows as row, i (row.id)}
						<tr
							class={cn(
								'group/row relative transition-colors duration-(--dur-1) ease-(--ease-out) hover:bg-muted has-[a:focus-visible]:outline-2 has-[a:focus-visible]:-outline-offset-2 has-[a:focus-visible]:outline-ring max-md:block max-md:px-0 max-md:py-1',
								pending(i + 2)
							)}
						>
							<td class={cn(cell, 'text-brand max-md:block max-md:pr-0 max-md:pl-0')}>{row.result}</td>
							<td class={cn(cell, 'max-md:block max-md:pr-0 max-md:pl-0')}>
								<a href={`/hackathons/${row.id}`} class="outline-none after:absolute after:inset-0 after:content-['']"
									>{row.event}</a
								>
							</td>
							<td class={cn(cell, 'tabular-nums max-md:hidden')}>{row.when}</td>
							<td class={cn(cell, 'max-md:hidden')}>{row.built}</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>

		<p class={cn('mt-2 text-muted-foreground', pending(rows.length + 2))}>{closing}</p>
		<p class={cn('whitespace-nowrap', pending(rows.length + 3))}>
			<span class="text-muted-foreground">$</span>
			<span aria-hidden="true" class="cursor-blink text-brand">▊</span>
		</p>
	</Terminal>
</div>
