<script lang="ts">
	import { page } from '$app/state';
	import { toggleMode } from 'mode-watcher';
	import SunIcon from '@lucide/svelte/icons/sun';
	import MoonIcon from '@lucide/svelte/icons/moon';
	import { Button } from '$lib/components/ui/button';
	import { navigationItems } from '$lib/config/navigation';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import SearchCommand from '$lib/components/search-command.svelte';
	import logo from '$lib/assets/icons/apple-touch-icon.png?enhanced';

	const isActive = (href: string) => {
		if (href === '/') {
			return page.url.pathname === '/';
		}
		return page.url.pathname.startsWith(href);
	};
</script>

<header
	class="sticky top-0 z-50 w-full border-b-2 bg-background/95 backdrop-blur [view-transition-name:site-header] supports-backdrop-filter:bg-background/60"
>
	<div class="mx-auto flex h-16 max-w-7xl items-center justify-between px-6 md:px-16 xl:px-6">
		<a href="/" class="flex items-center gap-2.5">
			<EnhancedImage src={logo} alt="Logo" class="size-8 rounded-lg" skeletonClass="rounded-lg" />
			<span class="text-lg font-bold">Jay Kerkar</span>
		</a>

		<div class="flex items-center gap-4">
			<nav class="hidden items-center space-x-1 lg:flex">
				{#each navigationItems as item (item.href)}
					<a
						href={item.href}
						class="px-5 py-2.5 text-base font-medium hover:text-foreground {isActive(item.href)
							? 'border-b-[1.75px] border-foreground text-foreground'
							: 'text-muted-foreground hover:border-b-[1.75px] hover:border-foreground'}"
					>
						{item.label}
					</a>
				{/each}
			</nav>

			<SearchCommand />

			<Button onclick={toggleMode} variant="outline" size="icon" class="relative">
				<SunIcon class="size-[1.15rem] scale-100 rotate-0 dark:scale-0 dark:-rotate-90" />
				<MoonIcon class="absolute size-[1.15rem] scale-0 rotate-90 dark:scale-100 dark:rotate-0" />
				<span class="sr-only">Toggle theme</span>
			</Button>
		</div>
	</div>
</header>

<div class="fixed bottom-0 left-0 z-50 h-20 w-full border-t-2 bg-background [view-transition-name:site-dock] lg:hidden">
	<div class="mx-auto grid h-full max-w-lg grid-cols-3 font-medium">
		{#each navigationItems as item (item.href)}
			<a
				href={item.href}
				class="inline-flex flex-col items-center justify-center gap-0.5 px-5 py-2 {isActive(item.href)
					? 'bg-primary text-primary-foreground'
					: 'hover:bg-primary hover:text-primary-foreground'}"
			>
				<span class="flex size-5.5 items-center justify-center">
					<svelte:component this={item.icon} />
				</span>
				<span class="text-[0.85rem]">{item.label}</span>
			</a>
		{/each}
	</div>
</div>
