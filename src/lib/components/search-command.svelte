<script lang="ts">
	import Fuse from 'fuse.js';
	import { goto } from '$app/navigation';
	import { projects } from '$lib/projects';
	import { hackathons } from '$lib/hackathons';
	import type { Project } from '$lib/projects/types';
	import { Kbd } from '$lib/components/ui/kbd';
	import { Button } from '$lib/components/ui/button';
	import { navigationItems } from '$lib/config/navigation';
	import * as Command from '$lib/components/ui/command/index.js';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import { getProjectIcon, getHackathonIcon } from '$lib/assets/images';
	import { GithubIcon, LeetCodeIcon, LinkedInIcon, XBrandIcon } from '$lib/components/brand-icons';

	import CodeIcon from '@lucide/svelte/icons/code';
	import TrophyIcon from '@lucide/svelte/icons/trophy';
	import SearchIcon from '@lucide/svelte/icons/search';
	import FileTextIcon from '@lucide/svelte/icons/file-text';
	import ExternalLinkIcon from '@lucide/svelte/icons/external-link';

	let open = $state(false);

	// Rendered as ⌘K on the server; switched after mount on non-Apple platforms.
	let shortcut = $state('⌘K');

	$effect(() => {
		if (!/Mac|iPhone|iPad/i.test(navigator.userAgent)) shortcut = 'Ctrl K';
	});

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

	const pageCount = navigationItems.length + 1;
	const projectCount = featuredProjects.length + otherProjects.length;
	const hackathonCount = prizeHackathons.length + otherHackathonsList.length;
	const socialCount = searchableItems.filter((item) => item.value.startsWith('social-')).length;

	// Slice rather than new Date(): a bare YYYY-MM-DD parses as UTC and can shift year by timezone.
	const yearOf = (timestamp: string) => timestamp.slice(0, 4);

	const rowClass =
		'relative h-10 gap-3 overflow-hidden before:absolute before:inset-y-0 before:left-0 before:w-0.5 before:bg-brand before:opacity-0 data-selected:before:opacity-100';
	const metaClass =
		'flex shrink-0 items-center gap-1.5 font-mono text-[0.72rem] tracking-normal uppercase tabular-nums';
	const headingClass =
		'**:[[data-command-group-heading]]:font-mono **:[[data-command-group-heading]]:text-[0.72rem] **:[[data-command-group-heading]]:font-normal **:[[data-command-group-heading]]:tracking-[0.08em] **:[[data-command-group-heading]]:uppercase';
</script>

<svelte:document onkeydown={handleKeydown} />

<Button
	size="icon"
	variant="outline"
	aria-label="Search"
	aria-keyshortcuts="Control+K Meta+K"
	onclick={() => (open = true)}
	class="relative size-9 max-lg:border-transparent max-lg:bg-transparent max-lg:hover:bg-muted lg:w-56 lg:justify-start lg:gap-2 lg:px-3 dark:max-lg:border-transparent dark:max-lg:bg-transparent dark:max-lg:hover:bg-muted/50"
>
	<SearchIcon class="size-[1.15rem] lg:size-4" />
	<span class="hidden font-normal text-muted-foreground lg:inline">Search</span>
	<Kbd class="ml-auto hidden lg:inline-flex">{shortcut}</Kbd>
</Button>

<Command.Dialog
	bind:open
	filter={fuseFilter}
	title="Search Portfolio"
	description="Search across projects, hackathons, pages, and more."
	class="top-[14vh] rounded-lg! duration-(--dur-2) ease-(--ease-out) sm:max-w-[min(42rem,calc(100%-2rem))] data-open:zoom-in-100! data-open:slide-in-from-bottom-2 data-closed:duration-(--dur-1) data-closed:zoom-out-100! [&_[data-slot=command-input-wrapper]]:flex [&_[data-slot=command-input-wrapper]]:h-12 [&_[data-slot=command-input-wrapper]]:items-center [&_[data-slot=command-input-wrapper]]:border-b [&_[data-slot=command-input-wrapper]]:px-2 [&_[data-slot=command-input-wrapper]]:pb-0 [&_[data-slot=input-group]]:h-full! [&_[data-slot=input-group]]:border-0 [&_[data-slot=input-group]]:bg-transparent! [&_[data-slot=input-group]]:shadow-none"
>
	<Command.Input placeholder="Search projects, hackathons, pages..." />
	<Command.List class="max-h-[min(26rem,60dvh)]">
		<Command.Empty class="py-8 font-mono text-[0.72rem] text-muted-foreground">No results found.</Command.Empty>

		<Command.Group value="pages" heading={`Pages · ${pageCount}`} class={headingClass}>
			{#each navigationItems as item (item.href)}
				<Command.Item value={`page-${item.href}`} onSelect={() => navigate(item.href)} class={rowClass}>
					{@const Icon = item.icon}
					<Icon />
					<span class="min-w-0 flex-1 truncate">{item.label}</span>
					<Command.Shortcut class={metaClass}>{item.href}</Command.Shortcut>
				</Command.Item>
			{/each}
			<Command.Item value="page-resume" onSelect={() => openExternal('/docs/jay_kerkar_resume.pdf')} class={rowClass}>
				<FileTextIcon />
				<span class="min-w-0 flex-1 truncate">Resume</span>
				<Command.Shortcut class={metaClass}>PDF ↗</Command.Shortcut>
			</Command.Item>
		</Command.Group>

		<Command.Separator />

		<Command.Group value="projects" heading={`Projects · ${projectCount}`} class={headingClass}>
			{#each [...featuredProjects, ...otherProjects] as project (project.id)}
				{@const icon = getProjectIcon(project.id)}
				<Command.Item
					value={`project-${project.id}`}
					onSelect={() => navigate(`/projects/${project.id}`)}
					class={rowClass}
				>
					{#if icon}
						<EnhancedImage
							src={icon}
							alt=""
							skeletonClass="rounded"
							containerClass="size-6 shrink-0"
							class="size-6 rounded object-cover"
						/>
					{:else}
						<CodeIcon />
					{/if}
					<span class="min-w-0 flex-1 truncate">{project.title}</span>
					<Command.Shortcut class={metaClass}>
						{#if project.featured}
							<span class="text-[color-mix(in_oklab,var(--brand)_90%,var(--foreground))] dark:text-brand">Featured</span
							>
						{/if}
					</Command.Shortcut>
				</Command.Item>
			{/each}
		</Command.Group>

		<Command.Separator />

		<Command.Group value="hackathons" heading={`Hackathons · ${hackathonCount}`} class={headingClass}>
			{#each [...prizeHackathons, ...otherHackathonsList] as hackathon (hackathon.id)}
				{@const icon = getHackathonIcon(hackathon.id)}
				<Command.Item
					value={`hackathon-${hackathon.id}`}
					onSelect={() => navigate(`/hackathons/${hackathon.id}`)}
					class={rowClass}
				>
					{#if icon}
						<EnhancedImage
							src={icon}
							alt=""
							skeletonClass="rounded"
							containerClass="size-6 shrink-0"
							class="size-6 rounded object-contain"
						/>
					{:else}
						<TrophyIcon />
					{/if}
					<span class="min-w-0 flex-1 truncate">{hackathon.title}</span>
					<Command.Shortcut class={metaClass}>
						{#if hackathon.prize}
							<span aria-hidden="true" class="size-1.5 rounded-full bg-brand"></span>
							<span class="sr-only">Winner</span>
						{/if}
						{yearOf(hackathon.timestamp)}
					</Command.Shortcut>
				</Command.Item>
			{/each}
		</Command.Group>

		<Command.Separator />

		<Command.Group value="socials" heading={`Socials · ${socialCount}`} class={headingClass}>
			<Command.Item
				value="social-github"
				onSelect={() => openExternal('https://github.com/jaykerkar0405')}
				class={rowClass}
			>
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
				<span class="min-w-0 flex-1 truncate">GitHub</span>
				<Command.Shortcut class={metaClass}>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
			<Command.Item
				value="social-linkedin"
				onSelect={() => openExternal('https://in.linkedin.com/in/jaykerkar0405')}
				class={rowClass}
			>
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
				<span class="min-w-0 flex-1 truncate">LinkedIn</span>
				<Command.Shortcut class={metaClass}>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
			<Command.Item value="social-x" onSelect={() => openExternal('https://x.com/jaykerkar0405')} class={rowClass}>
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
				<span class="min-w-0 flex-1 truncate">X</span>
				<Command.Shortcut class={metaClass}>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
			<Command.Item
				value="social-leetcode"
				onSelect={() => openExternal('https://leetcode.com/u/jaykerkar0405')}
				class={rowClass}
			>
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
				<span class="min-w-0 flex-1 truncate">LeetCode</span>
				<Command.Shortcut class={metaClass}>
					<ExternalLinkIcon class="size-3" />
				</Command.Shortcut>
			</Command.Item>
		</Command.Group>
	</Command.List>

	<div
		aria-hidden="true"
		class="-mx-1 -mb-1 hidden items-center gap-4 border-t px-3 py-2 font-mono text-[0.72rem] text-muted-foreground sm:flex"
	>
		<span class="inline-flex items-center gap-1.5"><Kbd class="font-mono">↑↓</Kbd> navigate</span>
		<span class="inline-flex items-center gap-1.5"><Kbd class="font-mono">↵</Kbd> open</span>
		<span class="inline-flex items-center gap-1.5"><Kbd class="font-mono">esc</Kbd> close</span>
		<span class="ml-auto tabular-nums">{searchableItems.length} entries</span>
	</div>
</Command.Dialog>
