<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';
	import { Button } from '$lib/components/ui/button';
	import { Card } from '$lib/components/ui/card';

	let {
		title,
		lines,
		typing = true,
		children,
		class: className
	}: {
		title: string;
		lines: string[];
		typing?: boolean;
		/** Extra content printed directly after the lines, in the same mono type (not hidden from assistive tech). */
		children?: Snippet;
		class?: string;
	} = $props();

	const CHAR_MS = 18;
	const LINE_PAUSE_MS = 120;

	// Where each line starts in the joined text (one character per line break).
	const starts = $derived(lines.map((_, i) => lines.slice(0, i).reduce((sum, line) => sum + line.length + 1, 0)));
	const total = $derived(lines.reduce((sum, line) => sum + line.length, 0) + Math.max(lines.length - 1, 0));

	// The whole text is always rendered; `typed` only moves the boundary between the visible part and the
	// invisible remainder, so the box never changes size. Until mounted `typed` is 0 and the remainder is the
	// whole text: it stays visible unless html.js is set (see the remainder's classes), so no-JS visitors and
	// crawlers get everything.
	let typed = $state(0);
	let ready = $state(false);
	let finished = $state(false);

	let root = $state<HTMLDivElement | null>(null);
	let timer: ReturnType<typeof setTimeout> | undefined;
	let observer: IntersectionObserver | undefined;

	const stop = () => {
		clearTimeout(timer);
		timer = undefined;
		observer?.disconnect();
		observer = undefined;
	};

	const run = () => {
		stop();
		typed = 0;
		finished = false;

		const step = () => {
			if (typed >= total) {
				timer = undefined;
				finished = true;
				return;
			}
			const char = lines.join('\n')[typed];
			typed += 1;
			// A character that ends a line is followed by a short pause (the line break itself is the next step).
			timer = setTimeout(step, char === '\n' ? LINE_PAUSE_MS : CHAR_MS);
		};

		timer = setTimeout(step, CHAR_MS);
	};

	$effect(() => {
		void lines;
		const el = root;
		if (!el) return;

		ready = true;

		if (!typing || matchMedia('(prefers-reduced-motion: reduce)').matches) {
			typed = total;
			finished = false;
			return;
		}

		typed = 0;
		finished = false;
		observer = new IntersectionObserver(
			(entries) => {
				if (entries.some((entry) => entry.isIntersecting)) {
					observer?.disconnect();
					observer = undefined;
					run();
				}
			},
			{ threshold: 0.25 }
		);
		observer.observe(el);

		return stop;
	});

	const shown = (index: number) => Math.min(Math.max(typed - starts[index], 0), lines[index].length);
	// The cursor sits after the last typed character: on the line being typed, or after the final line when done.
	const cursorLine = $derived.by(() => {
		for (let i = 0; i < lines.length; i += 1) {
			if (typed <= starts[i] + lines[i].length) return i;
		}
		return lines.length - 1;
	});
</script>

<Card bind:ref={root} role="group" aria-label={title} class={cn('gap-0 overflow-hidden rounded-lg p-0', className)}>
	<div class="flex h-10 items-center gap-3 border-b px-4">
		<div class="flex gap-1.5" aria-hidden="true">
			<span class="size-2.5 rounded-full border border-border"></span>
			<span class="size-2.5 rounded-full border border-border"></span>
			<span class="size-2.5 rounded-full border border-border"></span>
		</div>
		<span class="min-w-0 truncate font-mono text-xs text-muted-foreground">{title}</span>

		{#if typing && finished}
			<Button
				type="button"
				variant="ghost"
				size="xs"
				class="ml-auto font-mono text-muted-foreground"
				onclick={run}
				aria-label="Replay typing"
			>
				<span aria-hidden="true">↻</span> replay
			</Button>
		{/if}
	</div>

	<div class="p-4 md:p-6">
		<div class="sr-only">
			{#each lines as line, i (i)}
				<p>{line}</p>
			{/each}
		</div>

		<pre
			aria-hidden="true"
			class="m-0 bg-transparent font-mono text-xs leading-relaxed wrap-anywhere whitespace-pre-wrap text-foreground sm:text-sm">{#each lines as line, i (i)}{@const n =
					shown(i)}{@const dollar = line.startsWith('$ ')}<span class="block"
					>{#if dollar && n > 0}<span class="text-brand">$</span>{line.slice(1, n)}{:else}{line.slice(
							0,
							n
						)}{/if}{#if ready && !children && i === cursorLine}<span class="relative inline-block w-0 align-baseline"
							><span class="absolute left-0 cursor-blink text-brand" style:top="0">▊</span></span
						>{/if}<span class={typing ? 'motion-safe:in-[.js]:invisible' : undefined}
						>{#if dollar && n === 0}<span class="text-brand">$</span>{line.slice(1)}{:else}{line.slice(n)}{/if}</span
					></span
				>{/each}</pre>

		{#if children}
			<div class="font-mono text-xs leading-relaxed wrap-anywhere text-foreground sm:text-sm">
				{@render children()}
			</div>
		{/if}
	</div>
</Card>
