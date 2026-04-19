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

<div class={cn('grid', containerClass)}>
	{#if !isLoaded}
		<Skeleton aria-hidden="true" class={cn('z-0 col-start-1 row-start-1 rounded-[inherit]', skeletonClass)} />
	{/if}

	<enhanced:img
		{src}
		{alt}
		{...restProps}
		onload={handleLoad}
		onerror={handleError}
		class={cn('z-10 col-start-1 row-start-1 transition-opacity duration-300', !isLoaded && 'opacity-0', className)}
	/>
</div>
