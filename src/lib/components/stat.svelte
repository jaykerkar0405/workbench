<script lang="ts">
	import { cn } from '$lib/utils';
	import { cubicOut } from 'svelte/easing';
	import type { Attachment } from 'svelte/attachments';

	let {
		value,
		label,
		suffix = '',
		decimals = 0,
		class: className
	}: {
		value: number;
		label: string;
		class?: string;
		suffix?: string;
		decimals?: number;
	} = $props();

	const DURATION_MS = 900;

	// null means "show the real value" (server render, no JS, in view at load, finished counting).
	let current = $state<number | null>(null);

	// Fixed decimals at every step, with thousands separators (1,075). Numbers under 1000 read as before.
	const format = (n: number) =>
		n.toLocaleString('en-US', { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
	const finalText = $derived(`${format(value)}${suffix}`);
	const shownText = $derived(`${format(current ?? value)}${suffix}`);

	const countUp: Attachment<HTMLElement> = (node) => {
		if (typeof IntersectionObserver === 'undefined' || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
			return;
		}

		let frame: number | undefined;
		let hiddenAtStart = false;

		const observer = new IntersectionObserver(
			(entries) => {
				const entry = entries[entries.length - 1];
				if (!entry) return;

				if (!hiddenAtStart) {
					// First callback: content already in view, or already scrolled past, is never reset to 0.
					if (entry.isIntersecting || entry.boundingClientRect.top < 0) {
						observer.disconnect();
						return;
					}
					hiddenAtStart = true;
					current = 0;
					return;
				}

				if (entry.isIntersecting) {
					observer.disconnect();
					const target = value;
					const start = performance.now();

					const step = (now: number) => {
						const t = Math.min(1, (now - start) / DURATION_MS);
						current = target * cubicOut(t);
						if (t < 1) {
							frame = requestAnimationFrame(step);
						} else {
							current = null;
						}
					};

					frame = requestAnimationFrame(step);
				}
			},
			{ rootMargin: '0px 0px -10% 0px', threshold: 0 }
		);

		observer.observe(node);

		return () => {
			observer.disconnect();
			if (frame !== undefined) cancelAnimationFrame(frame);
		};
	};
</script>

<div class={cn('flex flex-col gap-2', className)} {@attach countUp}>
	<span
		aria-hidden="true"
		class="inline-block text-4xl font-bold tracking-tight tabular-nums md:text-5xl"
		style:min-width="{finalText.length}ch"
	>
		{shownText}
	</span>
	<span class="label" aria-hidden="true">{label}</span>
	<span class="sr-only">{finalText} {label}</span>
</div>
