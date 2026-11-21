<script lang="ts">
	import type { ComponentProps, Snippet } from 'svelte';
	import { cn } from '$lib/utils';
	import * as Breadcrumb from '$lib/components/ui/breadcrumb';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';

	let {
		icon,
		badge,
		title,
		parent,
		summary,
		actions,
		iconFit = 'cover',
		iconTransitionName,
		titleTransitionName,
		class: className
	}: {
		title: string;
		class?: string;
		badge?: Snippet;
		summary?: string;
		actions?: Snippet;
		iconFit?: 'cover' | 'contain';
		iconTransitionName?: string;
		titleTransitionName?: string;
		parent: { label: string; href: string };
		icon?: ComponentProps<typeof EnhancedImage>['src'];
	} = $props();
</script>

<header
	class={cn('grid grid-cols-[minmax(0,1fr)]', actions && 'md:grid-cols-[minmax(0,1fr)_auto] md:gap-x-6', className)}
>
	<Breadcrumb.Root class="md:col-span-full">
		<Breadcrumb.List class="gap-2 font-mono text-xs tracking-[0.06em] uppercase">
			<Breadcrumb.Item>
				<Breadcrumb.Link href={parent.href} class="link-underline">{parent.label}</Breadcrumb.Link>
			</Breadcrumb.Item>
			<Breadcrumb.Separator>/</Breadcrumb.Separator>
			<Breadcrumb.Item class="min-w-0">
				<Breadcrumb.Page>{title}</Breadcrumb.Page>
			</Breadcrumb.Item>
		</Breadcrumb.List>
	</Breadcrumb.Root>

	<div class="mt-6 flex items-start gap-4 md:mt-8 md:gap-5">
		{#if icon}
			<!-- The wrapper has the title's font size and line height, so h-lh is exactly one title line: the icon is
				centred on the title's first line, however many lines the title wraps to. -->
			<div class="flex h-lh shrink-0 items-center text-page-title">
				<div
					class="size-14 shrink-0 overflow-hidden rounded-md border bg-muted"
					style:view-transition-name={iconTransitionName}
				>
					<EnhancedImage
						src={icon}
						alt=""
						containerClass="size-14"
						skeletonClass="rounded-md"
						class={cn('size-14', iconFit === 'contain' ? 'object-contain' : 'object-cover')}
					/>
				</div>
			</div>
		{/if}

		<!-- The badge follows the title on the baseline of its last line. It is not inside the <h1>, so the heading's name
			and its view transition stay the title alone. When it does not fit it wraps under the title's left edge. -->
		<div class="flex min-w-0 flex-1 flex-wrap items-baseline-last gap-x-4 gap-y-3">
			<h1 class="min-w-0 text-page-title wrap-break-word" style:view-transition-name={titleTransitionName}>
				{title}
			</h1>
			{#if badge}
				{@render badge()}
			{/if}
		</div>
	</div>

	{#if summary}
		<p class="mt-4 max-w-2xl text-lead md:col-span-full">{summary}</p>
	{/if}

	{#if actions}
		<!-- One title line sets the alignment even when the heading wraps. -->
		<div
			class="mt-6 flex flex-wrap items-center gap-3 md:col-start-2 md:row-start-2 md:mt-8 md:h-lh md:self-start md:justify-self-end md:text-page-title md:font-normal md:tracking-normal"
		>
			{@render actions()}
		</div>
	{/if}
</header>
