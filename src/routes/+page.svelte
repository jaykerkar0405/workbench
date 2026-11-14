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
	import Terminal from '$lib/components/terminal.svelte';
	import ResumeActions from '$lib/components/resume-actions.svelte';
	import { GithubIcon, LeetCodeIcon, LinkedInIcon, XBrandIcon } from '$lib/components/brand-icons';

	const achievements = [
		'$ achievements --list',
		'🏆 ETHOnline 2025 | Winner — Top 10 / 634 projects (Global)',
		'🏆 ETHMumbai 2026 | Winner — Main AI Track + BitGo Sponsor Track (National)',
		'🥇 HackByte 3.0 | Top 10 — 125 teams (Central India)',
		'🥈 HackX 3.0 | Runner-up — NMIMS Navi Mumbai',
		'🥈 HackX 4.0 | Runner-up — NMIMS Navi Mumbai',
		'🥈 GajShield Hack X | Runner-up — KJSSE, Mumbai'
	];

	const socials = [
		{ name: 'GitHub', icon: GithubIcon, href: 'https://github.com/jaykerkar0405' },
		{ name: 'LinkedIn', icon: LinkedInIcon, href: 'https://in.linkedin.com/in/jaykerkar0405' },
		{ name: 'X', icon: XBrandIcon, href: 'https://x.com/jaykerkar0405' },
		{ name: 'LeetCode', icon: LeetCodeIcon, href: 'https://leetcode.com/u/jaykerkar0405' }
	];

	// One CSS entrance shared by the hero's two columns: runs from the prerendered HTML, not under reduced motion.
	const enter =
		'motion-safe:animate-in motion-safe:fade-in motion-safe:slide-in-from-bottom-2 motion-safe:duration-(--dur-3) motion-safe:ease-(--ease-out)';

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

<section class="relative lg:flex lg:min-h-[calc(100svh-3.25rem)] lg:items-center" aria-label="Introduction">
	<div class="dot-grid pointer-events-none absolute inset-0" aria-hidden="true"></div>

	<div class="mx-auto w-full max-w-7xl px-5 py-12 md:px-10 lg:py-16">
		<div class="grid gap-12 xl:grid-cols-12 xl:items-center xl:gap-x-6">
			<div class={cn('xl:col-span-7', enter)}>
				<p class="mb-6 flex items-center gap-2.5 label">
					<span aria-hidden="true" class="size-1.5 rounded-full bg-brand motion-safe:animate-pulse"></span>
					Mumbai, India · Full-stack · Web3
				</p>

				<h1 class="text-display">
					<span class="block">Jay</span>
					<span class="block">Kerkar</span>
				</h1>

				<p class="mt-6 max-w-xl text-lg leading-relaxed text-muted-foreground">
					Full-stack developer specializing in scalable web applications, mobile development, and Web3 solutions.
					Explore my projects, hackathon wins, and technical expertise in modern frameworks.
				</p>

				<div class="mt-8 flex flex-wrap items-center gap-x-4 gap-y-3">
					<Button href="/projects" size="lg" class="group/cta">
						View projects
						<span
							aria-hidden="true"
							class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) group-hover/cta:translate-x-1 group-focus-visible/cta:translate-x-1"
							>→</span
						>
					</Button>
					<ResumeActions previewVariant="link" showDownload={false} />
				</div>

				<Tooltip.Provider>
					<ul class="mt-6 -ml-2 flex items-center gap-1">
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
												class="text-muted-foreground hover:text-foreground"
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

			<div class={cn('max-w-2xl xl:col-span-5 xl:max-w-none', enter)}>
				<Terminal title="jay@mumbai: ~/achievements" lines={achievements} />
			</div>
		</div>
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
	<SectionHeading index="01" title="Selected work">
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
				class="inline-block transition-transform duration-(--dur-1) ease-(--ease-out) group-hover/row:translate-x-1 group-focus-visible/row:translate-x-1"
				>→</span
			>
		</a>
	</div>
</section>

<section aria-label="Stack" class={cn(container, 'pb-20 lg:pb-28')}>
	<SectionHeading index="02" title="Stack" />

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
	<SectionHeading index="03" title="About" />

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
