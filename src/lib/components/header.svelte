<script lang="ts">
	import { page } from '$app/state';
	import { expoOut } from 'svelte/easing';
	import { crossfade } from 'svelte/transition';
	import { prefersReducedMotion } from 'svelte/motion';
	import { toggleMode } from 'mode-watcher';
	import SunIcon from '@lucide/svelte/icons/sun';
	import MoonIcon from '@lucide/svelte/icons/moon';
	import { Button } from '$lib/components/ui/button';
	import { navigationItems } from '$lib/config/navigation';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import SearchCommand from '$lib/components/search-command.svelte';
	import logo from '$lib/assets/icons/apple-touch-icon.png?enhanced';

	let scrollY = $state(0);

	const scrolled = $derived(scrollY > 8);
	const wordmarkHidden = $derived(scrollY > 80);

	const isActive = (href: string) => {
		if (href === '/') {
			return page.url.pathname === '/';
		}
		return page.url.pathname.startsWith(href);
	};

	// One crossfade pair per dock so the (hidden) mobile pills never pair with the desktop ones.
	const pillOptions = {
		duration: () => (prefersReducedMotion.current ? 0 : 280),
		easing: expoOut
	};
	const [sendDesktop, receiveDesktop] = crossfade(pillOptions);
	const [sendMobile, receiveMobile] = crossfade(pillOptions);

	const toggleTheme = () => {
		if (typeof document.startViewTransition !== 'function' || prefersReducedMotion.current) {
			toggleMode();
			return;
		}

		const root = document.documentElement;
		const wasDark = root.classList.contains('dark');

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

		transition.ready.catch(() => {});
		transition.updateCallbackDone.catch(() => {});
		transition.finished.catch(() => {});
	};
</script>

<svelte:window bind:scrollY />

<header
	class="sticky top-0 z-40 w-full [view-transition-name:site-header] max-lg:bg-background/80 max-lg:backdrop-blur lg:pointer-events-none lg:pt-4"
>
	<div
		class="mx-auto flex h-14 max-w-7xl items-center justify-between px-5 md:px-10 lg:grid lg:h-9 lg:grid-cols-[1fr_auto_1fr]"
	>
		<a
			href="/"
			aria-label="Jay Kerkar, home"
			class="pointer-events-auto flex items-center gap-2.5 justify-self-start rounded-lg focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:outline-none"
		>
			<EnhancedImage src={logo} alt="" class="size-8 rounded-lg" skeletonClass="rounded-lg" />
			<span
				class="text-lg font-bold transition-opacity duration-(--dur-2) ease-(--ease-out) {wordmarkHidden
					? 'lg:pointer-events-none lg:opacity-0'
					: ''}"
			>
				Jay Kerkar
			</span>
		</a>

		<nav
			aria-label="Primary"
			class="pointer-events-auto hidden items-center gap-1 rounded-full border bg-background/70 p-1 backdrop-blur-md transition-shadow duration-(--dur-2) ease-(--ease-out) lg:flex {scrolled
				? 'shadow-md'
				: 'shadow-sm'}"
		>
			{#each navigationItems as item (item.href)}
				{@const active = isActive(item.href)}
				<Button
					href={item.href}
					variant="ghost"
					size="sm"
					aria-current={active ? 'page' : undefined}
					class="relative isolate rounded-full px-5 text-sm hover:bg-transparent dark:hover:bg-transparent {active
						? 'text-primary-foreground hover:text-primary-foreground'
						: 'text-muted-foreground hover:text-foreground'}"
				>
					{#if active}
						<span
							aria-hidden="true"
							class="pointer-events-none absolute inset-0 -z-10 rounded-full bg-primary"
							in:receiveDesktop={{ key: 'pill' }}
							out:sendDesktop={{ key: 'pill' }}
						></span>
						<!-- The accent: a small brand dot marks the current page. Absolutely placed in the button's padding so
							nothing shifts when the active item changes. -->
						<span
							aria-hidden="true"
							class="pointer-events-none absolute top-1/2 left-2.5 size-1.5 -translate-y-1/2 rounded-full bg-brand dark:bg-[oklch(0.545_0.16_240)]"
						></span>
					{/if}
					{item.label}
				</Button>
			{/each}
		</nav>

		<div class="pointer-events-auto flex items-center gap-1 justify-self-end">
			<SearchCommand />

			<Button onclick={toggleTheme} variant="ghost" size="icon" class="relative size-9">
				<SunIcon class="size-[1.15rem] scale-100 rotate-0 dark:scale-0 dark:-rotate-90" />
				<MoonIcon class="absolute size-[1.15rem] scale-0 rotate-90 dark:scale-100 dark:rotate-0" />
				<span class="sr-only">Toggle theme</span>
			</Button>
		</div>
	</div>
</header>

<nav
	aria-label="Primary"
	class="fixed inset-x-4 bottom-[calc(1rem+env(safe-area-inset-bottom))] z-40 mx-auto h-14 max-w-md rounded-full border bg-background/80 backdrop-blur [view-transition-name:site-dock] lg:hidden"
>
	<div class="grid h-full grid-cols-3 p-1">
		{#each navigationItems as item (item.href)}
			{@const Icon = item.icon}
			{@const active = isActive(item.href)}
			<a
				href={item.href}
				aria-current={active ? 'page' : undefined}
				class="relative isolate flex min-h-11 flex-col items-center justify-center gap-0.5 rounded-full text-[0.7rem] font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50 {active
					? 'text-primary-foreground'
					: 'text-muted-foreground hover:text-foreground'}"
			>
				{#if active}
					<span
						aria-hidden="true"
						class="pointer-events-none absolute inset-0 -z-10 rounded-full bg-primary"
						in:receiveMobile={{ key: 'pill' }}
						out:sendMobile={{ key: 'pill' }}
					></span>
					<span
						aria-hidden="true"
						class="pointer-events-none absolute top-1.5 left-1/2 ml-3 size-1.5 rounded-full bg-brand dark:bg-[oklch(0.545_0.16_240)]"
					></span>
				{/if}
				<Icon class="size-5" />
				<span>{item.label}</span>
			</a>
		{/each}
	</div>
</nav>
