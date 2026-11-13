<script lang="ts">
	import { reveal } from '$lib/components/reveal';
	import ResumeActions from '$lib/components/resume-actions.svelte';

	const currentYear = new Date().getFullYear();

	const linkedInUrl = 'https://in.linkedin.com/in/jaykerkar0405';

	const socials = [
		{ name: 'GitHub', handle: 'jaykerkar0405', href: 'https://github.com/jaykerkar0405' },
		{ name: 'LinkedIn', handle: 'jaykerkar0405', href: linkedInUrl },
		{ name: 'X', handle: '@jaykerkar0405', href: 'https://x.com/jaykerkar0405' },
		{ name: 'LeetCode', handle: 'jaykerkar0405', href: 'https://leetcode.com/u/jaykerkar0405' }
	];

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

	const metaLink =
		'group/link rounded-sm outline-none transition-colors duration-(--dur-1) ease-(--ease-out) hover:text-foreground focus-visible:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50';
	const arrow =
		'inline-block transition-transform duration-(--dur-1) ease-(--ease-out) group-hover/link:translate-x-0.5 group-hover/link:-translate-y-0.5 group-focus-visible/link:translate-x-0.5 group-focus-visible/link:-translate-y-0.5';
</script>

<footer aria-label="Footer" class="w-full border-t pb-[calc(5.5rem+env(safe-area-inset-bottom))] lg:pb-0">
	<div class="mx-auto max-w-7xl px-5 md:px-10">
		<div class="grid gap-10 py-20 lg:grid-cols-12 lg:items-end lg:gap-x-6 lg:py-28" {@attach reveal()}>
			<div class="lg:col-span-8">
				<p class="mb-4 label">Get in touch</p>
				<h2 class="text-display text-balance">Let’s build something.</h2>
			</div>

			<div class="flex flex-wrap items-center gap-x-6 gap-y-3 lg:col-span-4 lg:justify-end">
				<ResumeActions class="max-sm:w-full" />
				<a
					href={linkedInUrl}
					target="_blank"
					rel="noopener noreferrer"
					class="group/link rounded-sm link-underline text-sm font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
				>
					Message me on LinkedIn <span aria-hidden="true" class={arrow}>↗</span>
					<span class="sr-only">(opens in a new tab)</span>
				</a>
			</div>
		</div>

		<div
			class="grid gap-6 border-t pt-6 label tabular-nums md:grid-cols-[auto_1fr_auto] md:items-start md:gap-x-8 lg:pb-8"
		>
			<p>© {currentYear} Jay Kerkar</p>

			<nav aria-label="Social links" class="md:justify-self-center">
				<ul class="flex flex-wrap gap-x-6 gap-y-2 md:justify-center">
					{#each socials as social (social.name)}
						<li>
							<a href={social.href} target="_blank" rel="noopener noreferrer" class="link-underline {metaLink}">
								{social.name}
								<span class="text-foreground/70">{social.handle}</span>
								<span aria-hidden="true" class={arrow}>↗</span>
								<span class="sr-only">(opens in a new tab)</span>
							</a>
						</li>
					{/each}
				</ul>
			</nav>

			<div class="flex flex-col gap-2 md:min-w-[15.5em] md:items-end md:text-right">
				<p>
					Mumbai, IN · <time hidden={!time} datetime={stamp || undefined}>{time}</time> IST
				</p>
				<button
					type="button"
					onclick={() => window.scrollTo({ top: 0 })}
					class="{metaLink} cursor-pointer self-start uppercase md:self-end"
				>
					Back to top <span
						aria-hidden="true"
						class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) group-hover/link:-translate-y-0.5 group-focus-visible/link:-translate-y-0.5"
						>↑</span
					>
				</button>
			</div>
		</div>
	</div>
</footer>
