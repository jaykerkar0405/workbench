<script lang="ts">
	import { page } from '$app/state';
	import { cn } from '$lib/utils';
	import { reveal } from '$lib/components/reveal';
	import ResumeActions from '$lib/components/resume-actions.svelte';

	const currentYear = new Date().getFullYear();

	const linkedInUrl = 'https://in.linkedin.com/in/jaykerkar0405';

	const socials = [
		{ name: 'GitHub', href: 'https://github.com/jaykerkar0405' },
		{ name: 'LinkedIn', href: linkedInUrl },
		{ name: 'X', href: 'https://x.com/jaykerkar0405' },
		{ name: 'LeetCode', href: 'https://leetcode.com/u/jaykerkar0405' }
	];

	// The sign-off is the homepage's; every other route gets the compact row only. The footer lives in the layout and
	// persists across routes, so the variant follows the current path (also correct in each route's prerendered HTML).
	const isHome = $derived(page.url.pathname === '/');

	// Mumbai local time, whatever the visitor's own zone is. IST has no DST and a whole-minute offset,
	// so a minute boundary in UTC is also one in IST.
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

	// Stays null until mounted so the prerendered HTML and the hydrated DOM agree.
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

	const link =
		'group/link cursor-pointer rounded-sm link-underline text-sm font-medium text-muted-foreground outline-none transition-colors duration-(--dur-1) ease-(--ease-out) hover:text-foreground focus-visible:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50';
	const arrowBase =
		'inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-focus-visible/link:-translate-y-0.5 motion-safe:group-hover/link:-translate-y-0.5';
	// ↗ moves 2px up and right; ↑ moves 2px up.
	const arrowOut = cn(
		arrowBase,
		'motion-safe:group-focus-visible/link:translate-x-0.5 motion-safe:group-hover/link:translate-x-0.5'
	);
</script>

<footer aria-label="Footer" class="w-full border-t">
	<div class="mx-auto max-w-7xl px-5 md:px-10">
		{#if isHome}
			<!-- items-baseline-last: the actions sit on the baseline of the heading's last line, not on a box edge. -->
			<div
				class="grid gap-8 py-(--gap-section) lg:grid-cols-[1fr_auto] lg:items-baseline-last lg:gap-x-12"
				{@attach reveal()}
			>
				<div>
					<p class="mb-4 label">Get in touch</p>
					<h2 class="text-page-title">Let’s build something.</h2>
				</div>

				<div class="flex flex-wrap items-baseline gap-x-6 gap-y-3 lg:flex-nowrap">
					<!-- The buttons' first flex item is their icon, so the browser reports the icon's bottom edge as the button's
						baseline, 4px below the text baseline. The 4px offset puts their text on the heading's baseline. -->
					<ResumeActions class="relative top-1" />
					<a
						href={linkedInUrl}
						target="_blank"
						rel="noopener noreferrer"
						class="group/link rounded-sm link-underline text-sm font-medium whitespace-nowrap outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
					>
						Message me on LinkedIn <span aria-hidden="true" class={arrowOut}>↗</span>
						<span class="sr-only">(opens in a new tab)</span>
					</a>
				</div>
			</div>
		{/if}

		<div
			class={cn(
				'flex flex-wrap items-baseline justify-between gap-x-4 gap-y-4 pt-6 lg:grid lg:grid-cols-[1fr_auto_1fr] lg:gap-x-6 lg:pb-6',
				isHome && 'border-t'
			)}
		>
			<p class="label tabular-nums">© {currentYear} Jay Kerkar</p>

			<nav aria-label="Social links" class="order-first w-full lg:order-none lg:w-auto">
				<ul class="flex flex-wrap gap-x-6 gap-y-2">
					{#each socials as social (social.name)}
						<li>
							<a href={social.href} target="_blank" rel="noopener noreferrer" class={link}>
								{social.name}
								<span aria-hidden="true" class={arrowOut}>↗</span>
								<span class="sr-only">(opens in a new tab)</span>
							</a>
						</li>
					{/each}
				</ul>
			</nav>

			<div class="flex items-baseline gap-4 lg:justify-self-end">
				<!-- The invisible sizer reserves the width of the full time, so nothing moves when the clock appears. -->
				<p class="inline-grid label tabular-nums">
					<span aria-hidden="true" class="invisible col-start-1 row-start-1 select-none">Mumbai · 00:00 IST</span>
					<span class="col-start-1 row-start-1"
						>Mumbai · {#if time}<time datetime={stamp}>{time}</time>{/if} IST</span
					>
				</p>
				<button type="button" onclick={() => window.scrollTo({ top: 0 })} class={link}>
					Top <span aria-hidden="true" class={arrowBase}>↑</span>
				</button>
			</div>
		</div>
	</div>
</footer>
