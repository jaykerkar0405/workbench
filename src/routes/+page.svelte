<script lang="ts">
	import { cn } from '$lib/utils';
	import Seo from '$lib/components/seo.svelte';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { Button } from '$lib/components/ui/button';
	import { reveal } from '$lib/components/reveal';
	import { hackathons } from '$lib/hackathons';
	import { projects } from '$lib/projects';
	import { featuredProjects, projectIndex, hackathonFor } from '$lib/components/project-order';
	import SectionHeading from '$lib/components/section-heading.svelte';
	import Stat from '$lib/components/stat.svelte';
	import SpecSheet from '$lib/components/spec-sheet.svelte';
	import ProjectSpotlight from '$lib/components/project-spotlight.svelte';
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

	const stats = [
		{ value: hackathons.length, label: 'Hackathons', decimals: 0 },
		{ value: hackathons.filter((h) => h.prize).length, label: 'Podiums & track wins', decimals: 0 },
		{ value: projects.length, label: 'Projects shipped', decimals: 0 },
		{ value: cgpa, label: 'CGPA', decimals: 2 }
	];

	const stack = [
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

<section aria-label="At a glance" class={container}>
	<div class="grid grid-cols-2 gap-x-6 border-y md:grid-cols-4 md:gap-x-0">
		{#each stats as stat (stat.label)}
			<div
				class="border-t py-8 first:border-t-0 md:border-t-0 md:border-l md:px-6 md:first:border-l-0 md:first:pl-0 [&:nth-child(2)]:border-t-0"
			>
				<Stat value={stat.value} label={stat.label} decimals={stat.decimals} />
			</div>
		{/each}
	</div>
</section>

<section aria-label="Selected work" class={cn(container, 'py-20 lg:py-28')}>
	<SectionHeading index="02" title="Selected work">
		<span class="label tabular-nums">{featuredProjects.length} of {projects.length}</span>
	</SectionHeading>

	<div class="mt-10 flex flex-col gap-20 lg:gap-28">
		{#each featuredProjects as project, i (project.id)}
			<div {@attach reveal()}>
				<ProjectSpotlight
					{project}
					index={projectIndex(project.id)}
					hackathon={hackathonFor(project)}
					reverse={i % 2 === 1}
				/>
			</div>
		{/each}
	</div>

	<div class="mt-16 lg:mt-20" {@attach reveal()}>
		<a
			href="/projects"
			class="group/row flex items-center justify-between gap-4 border-y py-6 text-lg font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
		>
			View all {projects.length} projects
			<span
				aria-hidden="true"
				class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) motion-safe:group-hover/row:translate-x-1 motion-safe:group-focus-visible/row:translate-x-1"
				>→</span
			>
		</a>
	</div>
</section>

<section aria-label="Stack" class={cn(container, 'pb-20 lg:pb-28')}>
	<SectionHeading index="03" title="Stack" />

	<div class="mt-10 grid gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-4" {@attach reveal({ stagger: true })}>
		{#each stack as group (group.label)}
			<div>
				<h3 class="border-b pb-3 label">{group.label}</h3>
				<ul class="divide-y">
					{#each group.items as name (name)}
						<li class="py-3 text-lg">{name}</li>
					{/each}
				</ul>
			</div>
		{/each}
	</div>
</section>

<section id="about" aria-label="About" class={cn(container, 'pb-20 lg:pb-28')}>
	<SectionHeading index="04" title="About" />

	<div class="mt-10 grid gap-12 lg:grid-cols-12 lg:gap-x-6">
		<div class="lg:sticky lg:top-24 lg:col-span-4 lg:self-start">
			<h3 class="mb-4 label">Education</h3>
			<SpecSheet
				columns={1}
				items={[
					{ label: 'Institute', value: 'VES Institute of Technology' },
					{ label: 'Degree', value: 'Bachelor of Engineering - Information Technology' },
					{ label: 'Years', value: '2023 - 2027' },
					{ label: 'CGPA', value: `${cgpa.toFixed(2)} / 10` }
				]}
			/>
		</div>

		<div class="flex flex-col gap-12 lg:col-span-8">
			<div class="flex max-w-[65ch] flex-col gap-6 text-lg leading-relaxed text-foreground" {@attach reveal()}>
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
				class="max-w-[40ch] border-l-2 border-brand pl-6 text-2xl leading-tight font-medium text-balance"
				{@attach reveal()}
			>
				I strongly value quality code over quantity - writing clean, maintainable systems that scale beyond demos.
			</blockquote>

			<div {@attach reveal()}>
				<h3 class="mb-4 label">Learning now</h3>
				<ol class="border-t">
					{#each learning as item, i (item)}
						<li class="flex items-baseline gap-5 border-b py-4">
							<span aria-hidden="true" class="label tabular-nums">{String(i + 1).padStart(2, '0')}</span>
							<span class="text-lg">{item}</span>
						</li>
					{/each}
				</ol>
			</div>
		</div>
	</div>
</section>
