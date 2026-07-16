<script lang="ts">
	import Fuse from 'fuse.js';
	import { goto } from '$app/navigation';
	import { projects } from '$lib/projects';
	import { hackathons } from '$lib/hackathons';
	import type { Project } from '$lib/projects/types';
	import { Button } from '$lib/components/ui/button';
	import { navigationItems } from '$lib/config/navigation';
	import * as Command from '$lib/components/ui/command/index.js';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import { getProjectIcon, getHackathonIcon } from '$lib/assets/images';

	import StarIcon from '@lucide/svelte/icons/star';
	import CodeIcon from '@lucide/svelte/icons/code';
	import TrophyIcon from '@lucide/svelte/icons/trophy';
	import SearchIcon from '@lucide/svelte/icons/search';
	import MapPinIcon from '@lucide/svelte/icons/map-pin';
	import FileTextIcon from '@lucide/svelte/icons/file-text';
	import ExternalLinkIcon from '@lucide/svelte/icons/external-link';

	type SvgIcon = { viewBox: string; paths: string[] };

	const XBrandIcon: SvgIcon = {
		viewBox: '0 0 24 24',
		paths: [
			'M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z'
		]
	};

	const LinkedInIcon: SvgIcon = {
		viewBox: '0 0 24 24',
		paths: [
			'M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z'
		]
	};

	const GithubIcon: SvgIcon = {
		viewBox: '0 0 24 24',
		paths: [
			'M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z'
		]
	};

	const LeetCodeIcon: SvgIcon = {
		viewBox: '0 0 24 24',
		paths: [
			'M13.483 0a1.374 1.374 0 0 0-.961.438L7.116 6.226l-3.854 4.126a5.266 5.266 0 0 0-1.209 2.104 5.35 5.35 0 0 0-.125.513 5.527 5.527 0 0 0 .062 2.362 5.83 5.83 0 0 0 .349 1.017 5.938 5.938 0 0 0 1.271 1.818l4.277 4.193.039.038c2.248 2.165 5.852 2.133 8.063-.074l2.396-2.392c.54-.54.54-1.414.003-1.955a1.378 1.378 0 0 0-1.951-.003l-2.396 2.392a3.021 3.021 0 0 1-4.205.038l-.02-.019-4.276-4.193c-.652-.64-.972-1.469-.948-2.263a2.68 2.68 0 0 1 .066-.523 2.545 2.545 0 0 1 .619-1.164L9.13 8.114c1.058-1.134 3.204-1.27 4.43-.278l3.501 2.831c.593.48 1.461.387 1.94-.207a1.384 1.384 0 0 0-.207-1.943l-3.5-2.831c-.8-.647-1.766-1.045-2.774-1.202l2.015-2.158A1.384 1.384 0 0 0 13.483 0zm-2.866 12.815a1.38 1.38 0 0 0-1.38 1.382 1.38 1.38 0 0 0 1.38 1.382H20.79a1.38 1.38 0 0 0 1.38-1.382 1.38 1.38 0 0 0-1.38-1.382z'
		]
	};

	let open = $state(false);

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
			e.preventDefault();
			open = !open;
		}
	}

	function navigate(path: string) {
		open = false;
		goto(path);
	}

	function openExternal(url: string) {
		open = false;
		window.open(url, '_blank', 'noopener,noreferrer');
	}

	const hackathonTimestamp = (p: Project): number => {
		if (!p.hackathonId) return -Infinity;
		const h = hackathons.find((h) => h.id === p.hackathonId);
		return h ? new Date(h.timestamp).getTime() : -Infinity;
	};

	const sortByHackathon = (a: Project, b: Project) => hackathonTimestamp(b) - hackathonTimestamp(a);

	const featuredProjects = projects.filter((p) => p.featured).sort(sortByHackathon);
	const otherProjects = projects.filter((p) => !p.featured).sort(sortByHackathon);

	const sortedHackathons = [...hackathons].sort(
		(a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
	);

	const prizeHackathons = sortedHackathons.filter((h) => h.prize);
	const otherHackathonsList = sortedHackathons.filter((h) => !h.prize);

	interface SearchableItem {
		value: string;
		title: string;
		keywords: string[];
		description: string;
	}

	const searchableItems: SearchableItem[] = [
		...navigationItems.map((item) => ({
			description: '',
			title: item.label,
			value: `page-${item.href}`,
			keywords: ['page', 'navigate', item.label.toLowerCase()]
		})),
		{
			title: 'Resume',
			description: '',
			value: 'page-resume',
			keywords: ['page', 'resume', 'cv', 'pdf', 'document']
		},
		...featuredProjects.map((project) => ({
			title: project.title,
			value: `project-${project.id}`,
			description: project.shortDescription,
			keywords: ['project', 'featured', ...project.techStack.map((t) => t.title)]
		})),
		...otherProjects.map((project) => ({
			title: project.title,
			value: `project-${project.id}`,
			description: project.shortDescription,
			keywords: ['project', ...project.techStack.map((t) => t.title)]
		})),
		...prizeHackathons.map((hackathon) => ({
			title: hackathon.title,
			description: hackathon.organizer,
			value: `hackathon-${hackathon.id}`,
			keywords: [
				'prize',
				'winner',
				'hackathon',
				hackathon.location,
				hackathon.prize?.label ?? '',
				hackathon.prize?.rank ? `${hackathon.prize.rank} Place` : ''
			].filter(Boolean)
		})),
		...otherHackathonsList.map((hackathon) => ({
			title: hackathon.title,
			description: hackathon.organizer,
			value: `hackathon-${hackathon.id}`,
			keywords: ['hackathon', hackathon.location]
		})),
		{
			title: 'GitHub',
			description: '',
			value: 'social-github',
			keywords: ['social', 'git', 'code', 'repository', 'open source']
		},
		{
			description: '',
			title: 'LinkedIn',
			value: 'social-linkedin',
			keywords: ['social', 'professional', 'network', 'job', 'career']
		},
		{
			title: 'X',
			description: '',
			value: 'social-x',
			keywords: ['social', 'twitter', 'tweet', 'post']
		},
		{
			description: '',
			title: 'LeetCode',
			value: 'social-leetcode',
			keywords: ['social', 'coding', 'competitive', 'programming', 'dsa', 'algorithm']
		}
	];

	const fuse = new Fuse(searchableItems, {
		keys: [
			{ name: 'title', weight: 2 },
			{ name: 'keywords', weight: 1 },
			{ name: 'description', weight: 1.5 }
		],
		threshold: 0.4,
		includeScore: true,
		ignoreLocation: true
	});

	let cachedSearch = '';
	let cachedScoreMap = new Map<string, number>();

	function fuseFilter(value: string, search: string): number {
		if (!search) return 1;

		if (search !== cachedSearch) {
			cachedSearch = search;
			const results = fuse.search(search);
			cachedScoreMap = new Map<string, number>();
			for (const result of results) {
				cachedScoreMap.set(result.item.value, 1 - (result.score ?? 0));
			}
		}

		return cachedScoreMap.get(value) ?? 0;
	}
</script>

<svelte:document onkeydown={handleKeydown} />

<Button size="icon" class="relative" variant="outline" aria-label="Search (Ctrl+K)" onclick={() => (open = true)}>
	<SearchIcon class="size-[1.15rem]" />
	<span class="sr-only">Search</span>
</Button>

<Command.Dialog
	bind:open
	filter={fuseFilter}
	class="sm:max-w-137.5"
	title="Search Portfolio"
	description="Search across projects, hackathons, pages, and more."
>
	<Command.Input placeholder="Search projects, hackathons, pages..." />
	<Command.List>
		<Command.Empty>No results found.</Command.Empty>

		<Command.Group heading="Pages">
			{#each navigationItems as item (item.href)}
				<Command.Item value={`page-${item.href}`} onSelect={() => navigate(item.href)}>
					{@const Icon = item.icon}
					<Icon />
					<span>{item.label}</span>
				</Command.Item>
			{/each}
			<Command.Item value="page-resume" onSelect={() => openExternal('/docs/jay_kerkar_resume.pdf')}>
				<FileTextIcon />
				<span>Resume</span>
			</Command.Item>
		</Command.Group>

		<Command.Separator />

		<Command.Group heading="Featured Projects">
			{#each featuredProjects as project (project.id)}
				{@const icon = getProjectIcon(project.id)}
				<Command.Item value={`project-${project.id}`} onSelect={() => navigate(`/projects/${project.id}`)}>
					{#if icon}
						<EnhancedImage
							src={icon}
							alt={project.title}
							skeletonClass="rounded"
							containerClass="size-6 shrink-0"
							class="size-6 rounded object-cover"
						/>
					{:else}
						<StarIcon />
					{/if}
					<div class="flex flex-col">
						<span>{project.title}</span>
						<span class="text-xs text-muted-foreground">{project.shortDescription}</span>
					</div>
				</Command.Item>
			{/each}
		</Command.Group>

		<Command.Separator />

		<Command.Group heading="Projects">
			{#each otherProjects as project (project.id)}
				{@const icon = getProjectIcon(project.id)}
				<Command.Item value={`project-${project.id}`} onSelect={() => navigate(`/projects/${project.id}`)}>
					{#if icon}
						<EnhancedImage
							src={icon}
							alt={project.title}
							containerClass="size-6 shrink-0"
							skeletonClass="rounded"
							class="size-6 rounded object-cover"
						/>
					{:else}
						<CodeIcon />
					{/if}
					<div class="flex flex-col">
						<span>{project.title}</span>
						<span class="text-xs text-muted-foreground">{project.shortDescription}</span>
					</div>
				</Command.Item>
			{/each}
		</Command.Group>

		<Command.Separator />

		<Command.Group heading="Hackathon Wins">
			{#each prizeHackathons as hackathon (hackathon.id)}
				{@const icon = getHackathonIcon(hackathon.id)}
				<Command.Item value={`hackathon-${hackathon.id}`} onSelect={() => navigate(`/hackathons/${hackathon.id}`)}>
					{#if icon}
						<EnhancedImage
							src={icon}
							alt={hackathon.title}
							skeletonClass="rounded"
							containerClass="size-6 shrink-0"
							class="size-6 rounded object-contain"
						/>
					{:else}
						<TrophyIcon />
					{/if}
					<div class="flex flex-col">
						<span>{hackathon.title}</span>
						<span class="text-xs text-muted-foreground">
							{hackathon.prize?.rank ? `${hackathon.prize.rank} Place` : hackathon.prize?.label} · {hackathon.organizer}
						</span>
					</div>
				</Command.Item>
			{/each}
		</Command.Group>

		<Command.Separator />

		<Command.Group heading="Other Hackathons">
			{#each otherHackathonsList as hackathon (hackathon.id)}
				{@const icon = getHackathonIcon(hackathon.id)}
				<Command.Item value={`hackathon-${hackathon.id}`} onSelect={() => navigate(`/hackathons/${hackathon.id}`)}>
					{#if icon}
						<EnhancedImage
							src={icon}
							alt={hackathon.title}
							skeletonClass="rounded"
							containerClass="size-6 shrink-0"
							class="size-6 rounded object-contain"
						/>
					{:else}
						<MapPinIcon />
					{/if}
					<div class="flex flex-col">
						<span>{hackathon.title}</span>
						<span class="text-xs text-muted-foreground">
							{hackathon.organizer} · {hackathon.location}
						</span>
					</div>
				</Command.Item>
			{/each}
		</Command.Group>

		<Command.Separator />

		<Command.Group heading="Socials">
			<Command.Item value="social-github" onSelect={() => openExternal('https://github.com/jaykerkar0405')}>
				<svg
					fill="currentColor"
					class="size-4 shrink-0"
					viewBox={GithubIcon.viewBox}
					xmlns="http://www.w3.org/2000/svg"
				>
					{#each GithubIcon.paths as d (d)}
						<path {d} />
					{/each}
				</svg>
				<span>GitHub</span>
				<Command.Shortcut>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
			<Command.Item value="social-linkedin" onSelect={() => openExternal('https://in.linkedin.com/in/jaykerkar0405')}>
				<svg
					fill="currentColor"
					class="size-4 shrink-0"
					viewBox={LinkedInIcon.viewBox}
					xmlns="http://www.w3.org/2000/svg"
				>
					{#each LinkedInIcon.paths as d (d)}
						<path {d} />
					{/each}
				</svg>
				<span>LinkedIn</span>
				<Command.Shortcut>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
			<Command.Item value="social-x" onSelect={() => openExternal('https://x.com/jaykerkar0405')}>
				<svg
					fill="currentColor"
					class="size-4 shrink-0"
					viewBox={XBrandIcon.viewBox}
					xmlns="http://www.w3.org/2000/svg"
				>
					{#each XBrandIcon.paths as d (d)}
						<path {d} />
					{/each}
				</svg>
				<span>X</span>
				<Command.Shortcut>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
			<Command.Item value="social-leetcode" onSelect={() => openExternal('https://leetcode.com/u/jaykerkar0405')}>
				<svg
					fill="currentColor"
					class="size-4 shrink-0"
					viewBox={LeetCodeIcon.viewBox}
					xmlns="http://www.w3.org/2000/svg"
				>
					{#each LeetCodeIcon.paths as d (d)}
						<path {d} />
					{/each}
				</svg>
				<span>LeetCode</span>
				<Command.Shortcut>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
		</Command.Group>
	</Command.List>
</Command.Dialog>
