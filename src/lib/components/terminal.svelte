<!--
	The terminal frame, shared by the home page's wins table and the error page: a plain element (no shadcn Card, so no ring
	or shadow of its own) on `surface`, 12px corners, a 1px border, a 44px title bar with three 8px outlined dots and a
	mono title, and a mono 14px body at line-height 2. What is printed inside is the caller's (`children`).
-->
<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';

	let {
		title,
		children,
		class: className,
		bodyClass
	}: {
		title: string;
		children: Snippet;
		class?: string;
		bodyClass?: string;
	} = $props();
</script>

<div role="group" aria-label={title} class={cn('overflow-hidden rounded-lg border bg-surface', className)}>
	<div class="flex h-11 items-center gap-3 border-b px-4">
		<div class="flex gap-1.5" aria-hidden="true">
			<span class="size-2 rounded-full border border-muted-foreground/50"></span>
			<span class="size-2 rounded-full border border-muted-foreground/50"></span>
			<span class="size-2 rounded-full border border-muted-foreground/50"></span>
		</div>
		<span class="min-w-0 truncate font-mono text-xs text-muted-foreground">{title}</span>
	</div>

	<div
		class={cn(
			'p-6 font-mono [font-feature-settings:"calt"_0,"liga"_0] text-sm leading-[2] text-foreground [font-variant-ligatures:none] md:p-8',
			bodyClass
		)}
	>
		{@render children()}
	</div>
</div>
