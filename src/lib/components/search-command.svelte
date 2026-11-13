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
	import { GithubIcon, LeetCodeIcon, LinkedInIcon, XBrandIcon } from '$lib/components/brand-icons';

	import StarIcon from '@lucide/svelte/icons/star';
	import CodeIcon from '@lucide/svelte/icons/code';
	import TrophyIcon from '@lucide/svelte/icons/trophy';
	import SearchIcon from '@lucide/svelte/icons/search';
	import MapPinIcon from '@lucide/svelte/icons/map-pin';
	import FileTextIcon from '@lucide/svelte/icons/file-text';
	import ExternalLinkIcon from '@lucide/svelte/icons/external-link';

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
