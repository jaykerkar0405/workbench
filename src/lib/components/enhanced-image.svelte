<script lang="ts">
	import { cn } from '$lib/utils.js';
	import { Skeleton } from '$lib/components/ui/skeleton';
	import type { HTMLImgAttributes, SvelteHTMLElements } from 'svelte/elements';

	type EnhancedSource = SvelteHTMLElements['enhanced:img']['src'];

	type EnhancedImageProps = Omit<HTMLImgAttributes, 'src' | 'onload' | 'onerror'> & {
		src: EnhancedSource;
		skeletonClass?: string;
		containerClass?: string;
		onload?: ((event: Event) => void) | null;
		onerror?: ((event: Event) => void) | null;
	};

	let {
		src,
		alt,
		onload,
		onerror,
		skeletonClass,
		containerClass,
		class: className,
		...restProps
	}: EnhancedImageProps = $props();

	let isLoaded = $state(false);

	const handleLoad = (event: Event) => {
		isLoaded = true;
		if (typeof onload === 'function') onload(event as never);
	};

	const handleError = (event: Event) => {
		isLoaded = true;
		if (typeof onerror === 'function') onerror(event as never);
	};
</script>

<div class={cn('relative', containerClass)}>
	{#if !isLoaded}
		<Skeleton
			aria-hidden="true"
			class={cn('pointer-events-none absolute inset-0 z-0 h-full w-full rounded-[inherit]', skeletonClass)}
		/>
	{/if}

	<enhanced:img
		{src}
		{alt}
		{...restProps}
		onload={handleLoad}
		onerror={handleError}
		class={cn('relative z-10 block transition-opacity duration-300', !isLoaded && 'opacity-0', className)}
	/>
</div>
