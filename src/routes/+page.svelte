<script lang="ts">
	import {
		siReact,
		siDocker,
		siPython,
		siSvelte,
		siMongodb,
		siSolidity,
		siNextdotjs,
		siTypescript,
		siJavascript,
		siPostgresql,
		siTailwindcss
	} from 'simple-icons';
	import { cn } from '$lib/utils';
	import Seo from '$lib/components/seo.svelte';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { Card, CardContent } from '$lib/components/ui/card';
	import { Button } from '$lib/components/ui/button';
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

	type BrandIcon = { title: string; hex: string; path: string };

	const brandColor = (hex: string) => {
		const normalized = hex.toLowerCase();
		if (normalized === '000000' || normalized === 'ffffff') return 'currentColor';
		return `#${hex}`;
	};

	const techStack: { name: string; icon: BrandIcon }[] = [
		{ name: 'React', icon: siReact },
		{ name: 'Python', icon: siPython },
		{ name: 'Docker', icon: siDocker },
		{ name: 'MongoDB', icon: siMongodb },
		{ name: 'SvelteKit', icon: siSvelte },
		{ name: 'Next.js', icon: siNextdotjs },
		{ name: 'Solidity', icon: siSolidity },
		{ name: 'TypeScript', icon: siTypescript },
		{ name: 'JavaScript', icon: siJavascript },
		{ name: 'PostgreSQL', icon: siPostgresql },
		{ name: 'Tailwind CSS', icon: siTailwindcss }
	];
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

<div class="container mx-auto max-w-7xl px-4 py-12">
	<div class="lg:flex lg:flex-col">
		<div class="space-y-6 lg:space-y-8">
			<div class="flex justify-center">
				<div class="w-full overflow-x-auto rounded-2xl border border-border bg-card">
					<Tooltip.Provider>
						<div class="flex min-h-20 items-center justify-between px-4">
							{#each techStack as tech (tech.name)}
								<Tooltip.Root>
									<Tooltip.Trigger
										aria-label={tech.name}
										class="flex size-14 shrink-0 items-center justify-center rounded-lg hover:scale-110"
									>
										<svg
											width="40"
											height="40"
											viewBox="0 0 24 24"
											fill="currentColor"
											xmlns="http://www.w3.org/2000/svg"
											style="color: {brandColor(tech.icon.hex)}"
										>
											<path d={tech.icon.path} />
										</svg>
									</Tooltip.Trigger>
									<Tooltip.Content>
										<p class="font-medium">{tech.name}</p>
									</Tooltip.Content>
								</Tooltip.Root>
							{/each}
						</div>
					</Tooltip.Provider>
				</div>
			</div>

			<div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
				<a
					target="_blank"
					rel="noopener noreferrer"
					href="https://github.com/jaykerkar0405"
					class="flex items-center gap-4 rounded-lg border border-border bg-card p-6"
				>
					<svg
						width="24"
						height="24"
						fill="currentColor"
						viewBox={GithubIcon.viewBox}
						xmlns="http://www.w3.org/2000/svg"
					>
						{#each GithubIcon.paths as d (d)}
							<path {d} />
						{/each}
					</svg>
					<div>
						<p class="font-medium">GitHub</p>
						<p class="text-sm text-muted-foreground">jaykerkar0405</p>
					</div>
				</a>

				<a
					target="_blank"
					rel="noopener noreferrer"
					href="https://in.linkedin.com/in/jaykerkar0405"
					class="flex items-center gap-4 rounded-lg border border-border bg-card p-6"
				>
					<svg
						width="24"
						height="24"
						fill="currentColor"
						viewBox={LinkedInIcon.viewBox}
						xmlns="http://www.w3.org/2000/svg"
					>
						{#each LinkedInIcon.paths as d (d)}
							<path {d} />
						{/each}
					</svg>
					<div>
						<p class="font-medium">LinkedIn</p>
						<p class="text-sm text-muted-foreground">jaykerkar0405</p>
					</div>
				</a>

				<a
					target="_blank"
					rel="noopener noreferrer"
					href="https://x.com/jaykerkar0405"
					class="flex items-center gap-4 rounded-lg border border-border bg-card p-6"
				>
					<svg
						width="24"
						height="24"
						fill="currentColor"
						viewBox={XBrandIcon.viewBox}
						xmlns="http://www.w3.org/2000/svg"
					>
						{#each XBrandIcon.paths as d (d)}
							<path {d} />
						{/each}
					</svg>
					<div>
						<p class="font-medium">X</p>
						<p class="text-sm text-muted-foreground">@jaykerkar0405</p>
					</div>
				</a>

				<a
					target="_blank"
					rel="noopener noreferrer"
					href="https://leetcode.com/u/jaykerkar0405"
					class="flex items-center gap-4 rounded-lg border border-border bg-card p-6"
				>
					<svg
						width="24"
						height="24"
						fill="currentColor"
						viewBox={LeetCodeIcon.viewBox}
						xmlns="http://www.w3.org/2000/svg"
					>
						{#each LeetCodeIcon.paths as d (d)}
							<path {d} />
						{/each}
					</svg>
					<div>
						<p class="font-medium">LeetCode</p>
						<p class="text-sm text-muted-foreground">jaykerkar0405</p>
					</div>
				</a>
			</div>
		</div>
	</div>

	<div id="about" class="mt-12 lg:mt-0">
		<h2 class="mb-8 text-3xl font-bold">About</h2>
		<div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
			<Card>
				<CardContent class="px-8 py-2">
					<h3 class="mb-4 text-xl font-semibold">My Approach</h3>
					<div class="space-y-4 leading-relaxed text-muted-foreground">
						<p>
							I'm a hackathon-driven developer who has participated in multiple national and global hackathons, building
							under real constraints and tight timelines.
						</p>
						<p>
							Earlier, I focused on building projects blindly for learning. Now, I intentionally design projects around
							real problems faced by people, aiming for practical impact.
						</p>
						<p>
							I strongly value quality code over quantity - writing clean, maintainable systems that scale beyond demos.
						</p>
					</div>
					<div class="mt-6">
						<ResumeActions resumeUrl="/docs/jay_kerkar_resume.pdf" downloadFileName="jay_kerkar_resume.pdf" />
					</div>
				</CardContent>
			</Card>

			<div class="flex flex-col gap-6">
				<Card class="flex-1">
					<CardContent class="px-8 py-2">
						<h3 class="mb-4 text-xl font-semibold">What I'm Learning Now</h3>
						<ul class="ml-4 list-outside list-disc space-y-3 text-muted-foreground marker:text-primary">
							<li class="pl-0.5">Agentic AI systems and workflows</li>
							<li class="pl-0.5">Ethereum fundamentals and protocol basics</li>
							<li class="pl-0.5">Zero-knowledge proofs and ZK systems</li>
						</ul>
					</CardContent>
				</Card>

				<Card class="flex-1">
					<CardContent class="px-8 py-2">
						<h3 class="mb-4 text-xl font-semibold">Education</h3>
						<div class="flex items-start justify-between gap-4">
							<div class="space-y-2">
								<p class="font-medium">VES Institute of Technology</p>
								<p class="text-sm text-muted-foreground">Bachelor of Engineering - Information Technology</p>
							</div>
							<div class="shrink-0 space-y-2 text-right">
								<p class="text-sm text-muted-foreground">2023 - 2027</p>
								<p class="text-sm font-medium">CGPA: 9.87 / 10</p>
							</div>
						</div>
					</CardContent>
				</Card>
			</div>
		</div>
	</div>
</div>
