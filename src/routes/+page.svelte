<script lang="ts">
	import { cn } from '$lib/utils';
	import { browser } from '$app/environment';
	import Seo from '$lib/components/seo.svelte';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { Button } from '$lib/components/ui/button';
	import { reveal } from '$lib/components/reveal';
	import { hackathons } from '$lib/hackathons';
	import { projects } from '$lib/projects';
	import { hackathonFor } from '$lib/components/project-order';
	import { orderedHackathons } from '$lib/components/hackathon-order';
	import SectionHeading from '$lib/components/section-heading.svelte';
	import Stat from '$lib/components/stat.svelte';
	import Door from '$lib/components/door.svelte';
	import WinsTable from '$lib/components/wins-table.svelte';
	import ResumeActions from '$lib/components/resume-actions.svelte';
	import MumbaiTime from '$lib/components/mumbai-time.svelte';
	import { GithubIcon, LeetCodeIcon, LinkedInIcon, XBrandIcon } from '$lib/components/brand-icons';

	const socials = [
		{ name: 'GitHub', icon: GithubIcon, href: 'https://github.com/jaykerkar0405' },
		{ name: 'LinkedIn', icon: LinkedInIcon, href: 'https://in.linkedin.com/in/jaykerkar0405' },
		{ name: 'X', icon: XBrandIcon, href: 'https://x.com/jaykerkar0405' },
		{ name: 'LeetCode', icon: LeetCodeIcon, href: 'https://leetcode.com/u/jaykerkar0405' }
	];

	// The sentence, in its two halves (the text is exactly: Full-stack developer, exploring Web3. Active hackathon participant.).
	const sentence = ['Full-stack developer, exploring Web3.', 'Active hackathon participant.'];

	// The three facts, derived. A win is a prize with a rank or a label (the rule the hackathons page uses).
	// A win is a prize with a rank or a label (the rule the hackathons page and the wins table use).
	const isWin = (h: (typeof hackathons)[number]) => !!(h.prize && (h.prize.rank || h.prize.label));
	const winCount = hackathons.filter(isWin).length;

	const facts = [
		{ value: hackathons.length, label: 'Hackathons' },
		{ value: winCount, label: 'Wins' },
		{ value: projects.length, label: 'Projects' }
	];

	const cgpa = 9.87;

	// The doors' LATEST lines, derived. A project's date is its hackathon's timestamp (none sorts last).
	const dateOf = (p: (typeof projects)[number]) => {
		const h = hackathonFor(p);
		return h ? new Date(h.timestamp).getTime() : -Infinity;
	};
	const latestProjects = [...projects]
		.sort((a, b) => dateOf(b) - dateOf(a))
		.slice(0, 3)
		.map((p) => p.title);
	const latestHackathons = orderedHackathons.slice(0, 3).map((h) => h.title);

	const toolkit = [
		{ label: 'Languages', items: ['TypeScript', 'JavaScript', 'Python', 'Solidity'] },
		{ label: 'Frontend', items: ['React', 'Next.js', 'SvelteKit', 'Tailwind CSS'] },
		{ label: 'Backend & data', items: ['PostgreSQL', 'MongoDB'] },
		{ label: 'Web3 & infra', items: ['Docker'] }
	];

	const learning = [
		'Agentic AI systems and workflows',
		'Ethereum fundamentals and protocol basics',
		'Zero-knowledge proofs and ZK systems'
	];

	const container = 'mx-auto max-w-7xl px-5 md:px-10';

	// The name, one box per letter so the load sequence can lift each letter on its own. The browser does not kern across
	// boxes, so each letter carries the kerning of the pair it starts, in em: advance("ab") - advance("a") - advance("b") in
	// Akt 700 (measured with a canvas at 1000px; letter-spacing is applied by each box and is not part of this number).
	const kerning: Record<string, number> = { ay: -0.04, Ke: -0.06, ka: -0.04 };
	const kernAfter = (word: string, i: number) => {
		const k = kerning[word.slice(i, i + 2)];
		return k ? `${k}em` : undefined;
	};

	// The scroll scene (V17) runs only where CSS scroll-driven animations exist and motion is allowed; layout.css gates its
	// rules on the same two conditions (plus html.js and the track's attribute). Otherwise the page is the static hero.
	const sceneSupported =
		browser && CSS.supports('animation-timeline: scroll()') && !matchMedia('(prefers-reduced-motion: reduce)').matches;

	// The load sequence (V18) is switched on before first paint by app.html (html.intro) and runs in CSS, so it never waits for
	// this script. Here it is only cleaned up: the class comes off when the sequence is over (under a second), or at once, which
	// cancels the animations and leaves the final state, if the visitor scrolls, touches or types during it.
	$effect(() => {
		const root = document.documentElement;
		if (!root.classList.contains('intro')) return;
		const events = ['scroll', 'wheel', 'touchstart', 'pointerdown', 'keydown'] as const;
		const end = () => {
			root.classList.remove('intro');
			clearTimeout(timer);
			for (const e of events) window.removeEventListener(e, end);
		};
		const timer = setTimeout(end, 1100);
		for (const e of events) window.addEventListener(e, end, { passive: true });
		return end;
	});

	let track = $state<HTMLElement | null>(null);
	let winsTable = $state<{ play: () => void } | null>(null);

	// JavaScript only supplies end values; the motion itself is CSS. After the fonts load (and on resize) each word of the
	// name gets the translation and scale that put its baseline-left corner on the matching word of the header wordmark.
	$effect(() => {
		if (!sceneSupported || !track) return;
		const stage = track.querySelector<HTMLElement>('[data-scene-stage]');
		const words = [...track.querySelectorAll<HTMLElement>('[data-scene-word]')];
		const targets = [...document.querySelectorAll<HTMLElement>('[data-wordmark-word]')];
		if (!stage || words.length !== targets.length || !targets.length) return;

		// The bottom edge of a zero-size inline-block is the baseline of its line.
		const baselineOf = (el: HTMLElement) => {
			const strut = document.createElement('span');
			strut.style.cssText = 'display:inline-block;width:0;height:0';
			el.append(strut);
			const y = strut.getBoundingClientRect().bottom;
			strut.remove();
			return y;
		};

		const measure = () => {
			const pinTop = parseFloat(getComputedStyle(stage).top) || 0;
			// Measure the words at rest: no animation, so no transform.
			for (const w of words) w.style.animation = 'none';
			const stageTop = stage.getBoundingClientRect().top;
			const rest = words.map((w) => {
				const r = w.getBoundingClientRect();
				return {
					left: r.left,
					bottom: r.bottom - stageTop + pinTop,
					base: baselineOf(w) - stageTop + pinTop,
					size: parseFloat(getComputedStyle(w).fontSize)
				};
			});
			for (const w of words) w.style.removeProperty('animation');
			words.forEach((w, i) => {
				const t = targets[i];
				const tr = t.getBoundingClientRect();
				const tBase = baselineOf(t);
				const k = parseFloat(getComputedStyle(t).fontSize) / rest[i].size;
				// Scaling about the box's bottom-left corner O moves the baseline-left point B to O + k(B - O); translate the rest.
				w.style.setProperty('--tx', `${tr.left - rest[i].left}px`);
				w.style.setProperty('--ty', `${tBase - rest[i].bottom - k * (rest[i].base - rest[i].bottom)}px`);
				w.style.setProperty('--k', String(k));
			});
		};

		measure();
		document.fonts.ready.then(measure);
		window.addEventListener('resize', measure);
		return () => window.removeEventListener('resize', measure);
	});

	// The wins table prints when the scene completes. The sentinel sits at the scroll distance of the scene; it stops
	// intersecting (above the viewport) when the scroll passes it. play() is idempotent, so scrolling back changes nothing.
	$effect(() => {
		if (!sceneSupported || !track || !winsTable) return;
		const sentinel = track.querySelector('[data-scene-sentinel]');
		if (!sentinel) return;
		const observer = new IntersectionObserver((entries) => {
			const e = entries[entries.length - 1];
			if (e && !e.isIntersecting && e.boundingClientRect.top < 0) {
				// Below 768px the table is shown at once (its own rule), so there is nothing to print.
				if (matchMedia('(min-width: 768px)').matches) winsTable?.play();
				observer.disconnect();
			}
		});
		observer.observe(sentinel);
		return () => observer.disconnect();
	});
</script>

<Seo
	title="Jay Kerkar | Full-Stack Developer – Web, Mobile & Web3 Solutions"
	description="Full-stack developer specializing in scalable web applications, mobile development, and Web3 solutions. Explore my projects, hackathon wins, and technical expertise in modern frameworks."
/>

{#snippet nameWord(word: string, offset: number)}
	<span data-scene-word
		>{#each [...word] as letter, i (i)}<span
				class="intro-clip"
				style:--i={offset + i}
				style:margin-right={kernAfter(word, i)}><span class="intro-letter">{letter}</span></span
			>{/each}</span
	>
{/snippet}

<!-- The hero at rest (V14): type and space only. A top band (status line, Mumbai time), a middle band (the sentence, the
	actions, three derived facts) and the name on one line, sized so its ink spans columns 1 to 12. The hero is one screen
	tall (min-height, so it grows instead of overlapping on a short viewport) and the name's baseline is 64px above the
	bottom of the screen, or above the mobile dock's top edge below lg. Nothing animates here: V17 (the scroll transition)
	and V18 (the load sequence) come later. -->
<!-- The scene's markup (V17): a track, a sticky stage, and a spacer. Without the scene's CSS these are three plain blocks and
	the page is V14's static hero followed by the wins section. See the scene block in layout.css. -->
<div bind:this={track} data-scene-track>
	<div data-scene-stage>
		<section
			aria-label="Introduction"
			class="flex min-h-[calc(100svh-var(--header-h))] [--clear:calc(4.5rem+env(safe-area-inset-bottom))] lg:[--clear:0px]"
		>
			<div
				class="relative mx-auto flex w-full max-w-7xl flex-col px-5 pt-6 pb-[calc(var(--clear)+4rem)] md:px-10 md:pt-8"
			>
				<div class="@container flex flex-1 flex-col">
					<div class="min-h-6 flex-[2] md:min-h-10"></div>

					<div data-scene-band class="flex flex-col gap-6">
						<div class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
							<p class="label">Mumbai, India · Full-stack · Web3</p>
							<MumbaiTime class="ml-auto shrink-0 whitespace-nowrap" />
						</div>

						<div class="grid gap-x-6 gap-y-8 md:grid-cols-12 md:items-end">
							<div class="md:col-span-7 lg:col-span-8">
								<p class="text-[1.75rem] leading-[1.2] text-balance text-foreground xl:text-[2.25rem]">
									<span class="xl:whitespace-nowrap">{sentence[0]}</span>&#32;<span class="xl:whitespace-nowrap"
										>{sentence[1]}</span
									>
								</p>

								<div class="mt-6 flex flex-wrap items-center gap-x-4 gap-y-3 md:mt-8">
									<Button href="/projects" size="lg" class="group/cta rounded-md">
										View projects
										<span
											aria-hidden="true"
											class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/cta:translate-x-1 motion-safe:group-focus-visible/cta:translate-x-1"
											>→</span
										>
									</Button>
									<ResumeActions previewVariant="link" showDownload={false} />

									<Tooltip.Provider>
										<ul class="flex items-center gap-1">
											{#each socials as social (social.name)}
												<li>
													<Tooltip.Root>
														<Tooltip.Trigger>
															{#snippet child({ props })}
																<Button
																	{...props}
																	href={social.href}
																	target="_blank"
																	rel="noopener noreferrer"
																	variant="ghost"
																	size="icon-lg"
																	class="rounded-md text-muted-foreground hover:text-foreground"
																	aria-label="Jay Kerkar on {social.name}"
																>
																	<svg
																		viewBox={social.icon.viewBox}
																		fill="currentColor"
																		class="size-5"
																		aria-hidden="true"
																	>
																		{#each social.icon.paths as d (d)}
																			<path {d} />
																		{/each}
																	</svg>
																</Button>
															{/snippet}
														</Tooltip.Trigger>
														<Tooltip.Content>{social.name}</Tooltip.Content>
													</Tooltip.Root>
												</li>
											{/each}
										</ul>
									</Tooltip.Provider>
								</div>
							</div>

							<ul aria-label="Portfolio statistics" class="grid grid-cols-3 border-t md:col-span-5 lg:col-span-4">
								{#each facts as fact (fact.label)}
									<li class="pt-3 not-first:border-l not-first:pl-4">
										<Stat value={fact.value} label={fact.label} size="md" />
									</li>
								{/each}
							</ul>
						</div>
					</div>

					<div class="min-h-12 flex-[3] md:min-h-16"></div>

					<!-- Sized so the ink of the name spans the content box: font-size = content width / ratio, where ratio is the
				ink width of "Jay Kerkar" in Akt 700 at -0.04em divided by its font size (see NAME_RATIO below). -->
					<!-- The name is sized so its INK spans the content box: font-size = content width / ratio. Measured in Chromium with a
				canvas at 1000px, Akt 700, letter-spacing -40px (= -0.04em): "Jay Kerkar" has ink 4323.7 wide, starting 15.6 right of the
				pen origin (ratio 4.3237, left bearing 0.0156em). The negative left margin puts the ink, not the advance box, on the left edge; the right ink edge then
				falls on the right edge by construction. Akt's metrics are ascent 0.95em and descent 0.25em, so at line-height 0.8 the
				baseline is 0.05em above the box bottom, which -mb-[0.05em] cancels: the baseline is exactly the bottom padding
				(64px) above the bottom of the hero. The name is one line at every width. -->
					<h1
						aria-label="Jay Kerkar"
						class="-mb-[0.05em] ml-[calc(var(--bl)*-1em)] text-[length:calc(100cqw/var(--ratio))] leading-[0.8] font-bold tracking-[-0.04em] whitespace-nowrap text-foreground [--bl:0.0156] [--ratio:4.3237]"
					>
						{@render nameWord('Jay', 0)}&#32;{@render nameWord('Kerkar', 3)}
					</h1>
				</div>

				<p data-scene-cue aria-hidden="true" class="absolute bottom-[calc(var(--clear)+1.5rem)] label">
					<span data-intro-cue>Scroll ↓</span>
				</p>
			</div>
		</section>

		<!-- Wins: the second section. A label, title and one derived sentence in columns 1 to 4, the wins table (a terminal) in 5 to 12. -->
		<section data-scene-wins aria-labelledby="wins-title" class={cn(container, 'py-(--gap-section)')}>
			<div class="grid gap-x-6 gap-y-8 lg:grid-cols-12">
				<div class="lg:col-span-4">
					<p class="label tabular-nums">01</p>
					<h2 id="wins-title" class="mt-4 text-section-title">Wins</h2>
					<p class="mt-4 max-w-sm text-muted-foreground">
						{winCount} of {hackathons.length} hackathons ended on a podium or a track prize.
					</p>
					<a
						href="/hackathons"
						class="group/wins mt-6 inline-flex items-baseline gap-1 rounded-sm link-underline text-sm font-medium transition-none outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
					>
						All hackathons
						<span
							aria-hidden="true"
							class="inline-block motion-safe:transition-transform motion-safe:duration-(--dur-1) motion-safe:ease-(--ease-out) motion-safe:group-hover/wins:translate-x-1 motion-safe:group-focus-visible/wins:translate-x-1"
							>→</span
						>
					</a>
				</div>

				<WinsTable bind:this={winsTable} autoplay={!sceneSupported} class="lg:col-span-8" />
			</div>
		</section>
	</div>
	<div data-scene-spacer aria-hidden="true"></div>
	<div data-scene-sentinel aria-hidden="true"></div>
</div>

<!-- Doors: two panels, one link each, with a hairline above, below and between. No heading; the numbered sections resume after. -->
<section aria-label="Browse" class={container}>
	<div class="-mx-5 grid border-y md:-mx-10 md:grid-cols-2" {@attach reveal()}>
		<Door href="/projects" count={projects.length} title="Projects" latest={latestProjects} />
		<Door
			href="/hackathons"
			count={hackathons.length}
			title="Hackathons"
			latest={latestHackathons}
			class="max-md:border-t md:border-l"
		/>
	</div>
</section>

<!-- The headings below drop SectionHeading's own rule and top padding: the rows' hairlines already close the section above. -->
<section aria-label="Toolkit" class={cn(container, 'py-(--gap-section)')}>
	<div {@attach reveal()}>
		<SectionHeading index="02" title="Toolkit" rule={false} />
	</div>

	<dl class="mt-(--gap-heading) border-t" {@attach reveal({ stagger: true })}>
		{#each toolkit as group (group.label)}
			<div class="grid gap-x-6 gap-y-2 border-b py-4 md:grid-cols-12">
				<dt class="label md:col-span-3">{group.label}</dt>
				<dd class="md:col-span-9">
					<ul class="flex flex-wrap text-xl leading-snug">
						{#each group.items as name (name)}
							<li class="after:mx-2 after:text-muted-foreground after:content-['·'] last:after:content-none">{name}</li>
						{/each}
					</ul>
				</dd>
			</div>
		{/each}
	</dl>
</section>

<section id="about" aria-label="About" class={cn(container, 'pb-(--gap-section)')}>
	<div {@attach reveal()}>
		<SectionHeading index="03" title="About" rule={false} />
	</div>

	<div class="mt-(--gap-heading) grid items-start gap-12 lg:grid-cols-12 lg:gap-x-6">
		<div class="lg:col-span-7">
			<div class="flex flex-col gap-6 text-lg leading-relaxed text-foreground" {@attach reveal()}>
				<p>
					I'm a hackathon-driven developer who has participated in multiple national and global hackathons, building
					under real constraints and tight timelines.
				</p>
				<p>
					Earlier, I focused on building projects blindly for learning. Now, I intentionally design projects around real
					problems faced by people, aiming for practical impact.
				</p>
			</div>

			<blockquote
				class="mt-8 border-l-2 border-brand pl-6 text-[1.75rem] leading-tight font-medium text-balance"
				{@attach reveal()}
			>
				I strongly value quality code over quantity – writing clean, maintainable systems that scale beyond demos.
			</blockquote>
		</div>

		<div class="flex flex-col gap-12 lg:col-span-4 lg:col-start-9">
			<div {@attach reveal()}>
				<h3 class="label">Education</h3>
				<div class="mt-4 border-t pt-4">
					<p class="text-lg">VES Institute of Technology</p>
					<p class="mt-1 text-muted-foreground">Bachelor of Engineering – Information Technology</p>
					<p class="mt-4 label tabular-nums">2023 – 2027 · CGPA {cgpa.toFixed(2)}</p>
				</div>
			</div>

			<div {@attach reveal()}>
				<h3 class="label">Learning now</h3>
				<ol class="mt-4 border-t">
					{#each learning as item, i (item)}
						<li class="flex items-baseline gap-4 py-4 not-last:border-b">
							<span aria-hidden="true" class="label tabular-nums">{String(i + 1).padStart(2, '0')}</span>
							<span class="text-base">{item}</span>
						</li>
					{/each}
				</ol>
			</div>
		</div>
	</div>
</section>
