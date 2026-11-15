<script lang="ts">
	import { cn } from '$lib/utils';
	import Seo from '$lib/components/seo.svelte';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { Button } from '$lib/components/ui/button';
	import { reveal } from '$lib/components/reveal';
	import { hackathons } from '$lib/hackathons';
	import { projects } from '$lib/projects';
	import { hackathonFor } from '$lib/components/project-order';
	import { orderedHackathons } from '$lib/components/hackathon-order';
	import SectionHeading from '$lib/components/section-heading.svelte';
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
</script>

<Seo
	title="Jay Kerkar | Full-Stack Developer – Web, Mobile & Web3 Solutions"
	description="Full-stack developer specializing in scalable web applications, mobile development, and Web3 solutions. Explore my projects, hackathon wins, and technical expertise in modern frameworks."
/>

<!-- The hero at rest (V14): type and space only. A top band (status line, Mumbai time), a middle band (the sentence, the
	actions, three derived facts) and the name on one line, sized so its ink spans columns 1 to 12. The hero is one screen
	tall (min-height, so it grows instead of overlapping on a short viewport) and the name's baseline is 64px above the
	bottom of the screen, or above the mobile dock's top edge below lg. Nothing animates here: V17 (the scroll transition)
	and V18 (the load sequence) come later. -->
<section
	aria-label="Introduction"
	class="flex min-h-[calc(100svh-var(--header-h))] [--clear:calc(4.5rem+env(safe-area-inset-bottom))] lg:[--clear:0px]"
>
	<div class="relative mx-auto flex w-full max-w-7xl flex-col px-5 pt-6 pb-[calc(var(--clear)+4rem)] md:px-10 md:pt-8">
		<div class="@container flex flex-1 flex-col">
			<div class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
				<p class="label">Mumbai, India · Full-stack · Web3</p>
				<MumbaiTime class="shrink-0 whitespace-nowrap" />
			</div>

			<div class="min-h-4 flex-[7] md:min-h-12"></div>

			<div class="grid gap-x-6 gap-y-8 md:grid-cols-12">
				<div class="md:col-span-6">
					<!-- Each sentence is kept whole from xl up, so the line breaks after "Web3." there; below that it balances. -->
					<p class="text-[1.75rem] leading-[1.3] text-balance text-foreground">
						<span class="xl:whitespace-nowrap">{sentence[0]}</span>&#32;<span class="xl:whitespace-nowrap"
							>{sentence[1]}</span
						>
					</p>

					<ul class="mt-6 grid w-fit grid-cols-[2ch_auto] gap-x-3 gap-y-1 label tabular-nums md:hidden">
						{#each facts as fact (fact.label)}
							<li class="contents">
								<span class="text-right text-foreground">{fact.value}</span>
								<span>{fact.label}</span>
							</li>
						{/each}
					</ul>

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
														<svg viewBox={social.icon.viewBox} fill="currentColor" class="size-5" aria-hidden="true">
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

				<ul
					class="hidden grid-cols-[2ch_auto] content-start gap-x-3 gap-y-1 label tabular-nums md:col-span-3 md:col-start-10 md:grid md:pt-2"
				>
					{#each facts as fact (fact.label)}
						<li class="contents">
							<span class="text-right text-foreground">{fact.value}</span>
							<span>{fact.label}</span>
						</li>
					{/each}
				</ul>
			</div>

			<div class="min-h-12 flex-[3] md:min-h-16"></div>

			<!-- Sized so the ink of the name spans the content box: font-size = content width / ratio, where ratio is the
				ink width of "Jay Kerkar" in Akt 700 at -0.04em divided by its font size (see NAME_RATIO below). -->
			<!-- The name is sized so its INK spans the content box: font-size = content width / ratio. Measured in Chromium with a
				canvas at 1000px, Akt 700, letter-spacing -40px (= -0.04em): "Jay Kerkar" has ink 4323.7 wide, starting 15.6 right of the
				pen origin (ratio 4.3237, left bearing 0.0156em); "Kerkar" alone has ink 2696.9 wide starting 62.5 in (ratio 2.6969, left
				bearing 0.0625em). The negative left margin puts the ink, not the advance box, on the left edge; the right ink edge then
				falls on the right edge by construction. Akt's metrics are ascent 0.95em and descent 0.25em, so at line-height 0.8 the
				baseline is 0.05em above the box bottom, which -mb-[0.05em] cancels: the baseline is exactly the bottom padding
				(64px) above the bottom of the hero. Below 640px the name is two lines and "Kerkar" is what spans the width. -->
			<h1
				class="-mb-[0.05em] ml-[calc(var(--bl)*-1em)] text-[length:calc(100cqw/var(--ratio))] leading-[0.8] font-bold tracking-[-0.04em] whitespace-nowrap text-foreground [--bl:0.0156] [--ratio:4.3237] max-sm:[--bl:0.0625] max-sm:[--ratio:2.6969]"
			>
				<span class="block sm:inline">Jay</span>&#32;<span class="block sm:inline">Kerkar</span>
			</h1>
		</div>

		<p aria-hidden="true" class="absolute bottom-[calc(var(--clear)+1.5rem)] label">Scroll ↓</p>
	</div>
</section>

<!-- Wins: the second section. A label, title and one derived sentence in columns 1 to 4, the wins table (a terminal) in 5 to 12. -->
<section aria-labelledby="wins-title" class={cn(container, 'py-(--gap-section)')}>
	<div class="grid gap-x-6 gap-y-8 lg:grid-cols-12">
		<div class="lg:col-span-4">
			<p class="label tabular-nums">01</p>
			<h2 id="wins-title" class="mt-4 text-section-title">Wins</h2>
			<p class="mt-4 max-w-sm text-muted-foreground">
				{winCount} of {hackathons.length} hackathons ended on a podium or a track prize.
			</p>
		</div>

		<WinsTable class="lg:col-span-8" />
	</div>
</section>

<!-- Doors: two panels, one link each, with a hairline above, below and between. No heading; the numbered sections resume after. -->
<section aria-label="Browse" class={container}>
	<div class="grid border-y md:grid-cols-2" {@attach reveal()}>
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
	<SectionHeading index="02" title="Toolkit" class="[&>[data-slot=separator]]:hidden [&>div]:pt-0" />

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
	<SectionHeading index="03" title="About" class="[&>[data-slot=separator]]:hidden [&>div]:pt-0" />

	<div class="mt-(--gap-heading) grid gap-12 lg:grid-cols-12 lg:gap-x-6">
		<div class="lg:sticky lg:top-24 lg:col-span-4 lg:self-start">
			<h3 class="label">Education</h3>
			<p class="mt-4 text-lg">VES Institute of Technology</p>
			<p class="mt-1 text-muted-foreground">Bachelor of Engineering - Information Technology</p>
			<p class="mt-4 label tabular-nums">2023 – 2027 · CGPA {cgpa.toFixed(2)}</p>
		</div>

		<div class="flex flex-col lg:col-span-8">
			<div class="flex max-w-[31rem] flex-col gap-6 text-lg leading-relaxed text-foreground" {@attach reveal()}>
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
				class="my-8 max-w-[40ch] border-l-2 border-brand pl-6 text-[1.75rem] leading-tight font-medium text-balance"
				{@attach reveal()}
			>
				I strongly value quality code over quantity - writing clean, maintainable systems that scale beyond demos.
			</blockquote>

			<div {@attach reveal()}>
				<h3 class="mb-4 label">Learning now</h3>
				<ol class="border-t">
					{#each learning as item, i (item)}
						<li class="flex items-baseline gap-5 py-4 not-last:border-b">
							<span aria-hidden="true" class="label tabular-nums">{String(i + 1).padStart(2, '0')}</span>
							<span class="text-lg">{item}</span>
						</li>
					{/each}
				</ol>
			</div>
		</div>
	</div>
</section>
