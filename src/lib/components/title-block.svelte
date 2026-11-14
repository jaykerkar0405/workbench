<script lang="ts">
	import type { ComponentProps, Snippet } from 'svelte';
	import { cn } from '$lib/utils';
	import * as Breadcrumb from '$lib/components/ui/breadcrumb';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';

	let {
		icon,
		meta,
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
		meta?: Snippet;
		summary?: string;
		actions?: Snippet;
		iconFit?: 'cover' | 'contain';
		iconTransitionName?: string;
		titleTransitionName?: string;
		parent: { label: string; href: string };
		icon?: ComponentProps<typeof EnhancedImage>['src'];
	} = $props();
</script>

<header class={cn('flex flex-col gap-8', className)}>
	<Breadcrumb.Root>
		<Breadcrumb.List class="gap-2 font-mono text-[0.72rem] tracking-[0.08em] uppercase">
			<Breadcrumb.Item>
				<Breadcrumb.Link href={parent.href} class="link-underline">{parent.label}</Breadcrumb.Link>
			</Breadcrumb.Item>
			<Breadcrumb.Separator>/</Breadcrumb.Separator>
			<Breadcrumb.Item class="min-w-0">
				<Breadcrumb.Page>{title}</Breadcrumb.Page>
			</Breadcrumb.Item>
		</Breadcrumb.List>
	</Breadcrumb.Root>

	<div class="flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between lg:gap-12">
		<div class="flex min-w-0 flex-col gap-4">
			<div class="flex items-center gap-4 md:gap-5">
				{#if icon}
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
				{/if}

				<h1 class="min-w-0 text-page-title wrap-break-word" style:view-transition-name={titleTransitionName}>
					{title}
				</h1>
			</div>

			{#if meta}
				<div class="flex flex-wrap items-center gap-x-4 gap-y-2">
					{@render meta()}
				</div>
			{/if}

			{#if summary}
				<p class="max-w-2xl text-xl text-muted-foreground">{summary}</p>
			{/if}
		</div>

		{#if actions}
			<div class="flex shrink-0 flex-wrap items-center gap-3">
				{@render actions()}
			</div>
		{/if}
	</div>
</header>
