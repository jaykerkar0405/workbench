<script lang="ts">
	import { page } from '$app/state';
	import { prefersReducedMotion } from 'svelte/motion';
	import { toggleMode } from 'mode-watcher';
	import SunIcon from '@lucide/svelte/icons/sun';
	import MoonIcon from '@lucide/svelte/icons/moon';
	import { cn } from '$lib/utils';
	import { Button } from '$lib/components/ui/button';
	import { segmentedContainer, segmentedIndicator, segmentedItem } from '$lib/components/segmented';
	import { navigationItems } from '$lib/config/navigation';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import SearchCommand from '$lib/components/search-command.svelte';
	import logo from '$lib/assets/icons/apple-touch-icon.png?enhanced';

	let scrollY = $state(0);

	// The bar's bottom hairline fades in over the first 24px of scroll.
	const hairline = $derived(Math.min(Math.max(scrollY / 24, 0), 1));

	const isActive = (href: string) => {
		if (href === '/') {
			return page.url.pathname === '/';
		}
		return page.url.pathname.startsWith(href);
	};

	// On the home page the logo and wordmark scroll back to the top (which plays the hero scene in reverse); on every other
	// page they are an ordinary link home. A modified click (new tab) is left alone.
	const goTop = (event: MouseEvent) => {
		if (page.url.pathname !== '/') return;
		if (
			event.defaultPrevented ||
			event.button !== 0 ||
			event.metaKey ||
			event.ctrlKey ||
			event.shiftKey ||
			event.altKey
		)
			return;
		event.preventDefault();
		window.scrollTo({ top: 0, behavior: prefersReducedMotion.current ? 'auto' : 'smooth' });
	};

	let themeTransition: ViewTransition | undefined;

	const toggleTheme = (event: MouseEvent) => {
		if (typeof document.startViewTransition !== 'function' || prefersReducedMotion.current) {
			toggleMode();
			return;
		}

		const root = document.documentElement;
		const wasDark = root.classList.contains('dark');
		const button = event.currentTarget as HTMLButtonElement;
		const rect = button.getBoundingClientRect();
		const x = rect.left + rect.width / 2;
		const y = rect.top + rect.height / 2;
		const radius = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y));

		root.style.setProperty('--theme-x', `${x}px`);
		root.style.setProperty('--theme-y', `${y}px`);
		root.style.setProperty('--theme-r', `${radius}px`);
		root.setAttribute('data-theme-switch', '');

		const transition = document.startViewTransition(
			() =>
				new Promise<void>((resolve) => {
					// mode-watcher applies the class a frame after toggleMode(); wait for it so the new
					// snapshot is the new theme.
					const observer = new MutationObserver(() => {
						if (root.classList.contains('dark') !== wasDark) done();
					});
					const timeout = setTimeout(done, 250);
					function done() {
						observer.disconnect();
						clearTimeout(timeout);
						resolve();
					}
					observer.observe(root, { attributes: true, attributeFilter: ['class'] });
					toggleMode();
				})
		);

		themeTransition = transition;
		transition.ready.catch(() => {});
		transition.updateCallbackDone.catch(() => {});
		transition.finished
			.catch(() => {})
			.finally(() => {
				if (themeTransition !== transition) return;
				themeTransition = undefined;
				root.removeAttribute('data-theme-switch');
				root.style.removeProperty('--theme-x');
				root.style.removeProperty('--theme-y');
				root.style.removeProperty('--theme-r');
			});
	};
</script>

<svelte:window bind:scrollY />

<!-- The bar: the header element itself, edge to edge, sticky so it stays in normal flow (no padding on any page). It holds
	the page colour at 85% with a 12px blur, and a hairline whose opacity follows the scroll position. -->
<header data-site-header class="sticky top-0 z-40 h-(--header-h) w-full">
	<!-- The bar's fill and blur live on their own layer so the home scene can fade them in without touching the content. -->
	<div
		data-header-bar
		aria-hidden="true"
		class="pointer-events-none absolute inset-0 bg-background/85 backdrop-blur-md"
	></div>
	<div
		data-header-hairline
		aria-hidden="true"
		class="pointer-events-none absolute inset-x-0 bottom-0 h-px bg-border"
		style:opacity={hairline}
	></div>

	<!-- The view-transition name is on this wrapper, not on the header: a named ancestor is a backdrop root, which would
		stop the bar's blur from seeing the page behind it (readable text showed through the bar). -->
	<div class="h-full [view-transition-name:site-header]">
		<div
			class="mx-auto flex h-full max-w-7xl items-center justify-between px-5 md:px-10 lg:grid lg:grid-cols-[1fr_auto_1fr]"
		>
			<a
				href="/"
				aria-label="Jay Kerkar, home"
				onclick={goTop}
				class="relative flex h-9 items-center gap-2.5 justify-self-start rounded-sm focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:outline-none"
			>
				<EnhancedImage src={logo} alt="" class="size-8 rounded-sm border" skeletonClass="rounded-sm" />
				<!-- Two spans with a real space, so the home scene can land each word of the hero name on its own word. The
				tracking matches the hero name (-0.04em) so the swap at the end of the scene is invisible. -->
				<span data-wordmark class="text-lg font-bold tracking-[-0.04em]"
					><span data-wordmark-word>Jay</span>&#32;<span data-wordmark-word>Kerkar</span></span
				>
			</a>

			<nav
				aria-label="Primary"
				{@attach segmentedIndicator}
				class={cn(segmentedContainer, 'relative hidden h-9 items-center lg:flex')}
			>
				{#each navigationItems as item (item.href)}
					<a href={item.href} aria-current={isActive(item.href) ? 'page' : undefined} class={segmentedItem}>
						{item.label}
					</a>
				{/each}
			</nav>

			<div class="flex h-9 items-center gap-1 justify-self-end">
				<SearchCommand />

				<Button onclick={toggleTheme} variant="ghost" size="icon" class="relative size-9 rounded-md">
					<SunIcon class="size-[1.15rem] scale-100 rotate-0 dark:scale-0 dark:-rotate-90" />
					<MoonIcon class="absolute size-[1.15rem] scale-0 rotate-90 dark:scale-100 dark:rotate-0" />
					<span class="sr-only">Toggle theme</span>
				</Button>
			</div>
		</div>
	</div>
</header>

<nav
	data-site-dock
	aria-label="Primary"
	{@attach segmentedIndicator}
	class={cn(
		segmentedContainer,
		'fixed inset-x-4 bottom-[calc(1rem+env(safe-area-inset-bottom))] z-40 mx-auto grid h-14 max-w-md grid-cols-3 gap-0 rounded-lg bg-background/85 backdrop-blur-md [view-transition-name:site-dock] lg:hidden'
	)}
>
	{#each navigationItems as item (item.href)}
		{@const Icon = item.icon}
		<a
			href={item.href}
			aria-current={isActive(item.href) ? 'page' : undefined}
			class={cn(segmentedItem, 'h-auto min-h-11 flex-col gap-0.5 rounded-md px-0 text-xs')}
		>
			<Icon class="size-5" />
			<span>{item.label}</span>
		</a>
	{/each}
</nav>
