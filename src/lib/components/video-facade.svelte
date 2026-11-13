<script lang="ts">
	import { cn } from '$lib/utils';
	import PlayIcon from '@lucide/svelte/icons/play';
	import { Button } from '$lib/components/ui/button';
	import { AspectRatio } from '$lib/components/ui/aspect-ratio';

	let {
		url,
		title,
		class: className
	}: {
		url: string;
		title: string;
		class?: string;
	} = $props();

	const parseId = (value: string): string | null => {
		let parsed: URL;
		try {
			parsed = new URL(value);
		} catch {
			return null;
		}

		const host = parsed.hostname.replace(/^(www|m)\./, '');
		let id: string | null = null;

		if (host === 'youtu.be') {
			id = parsed.pathname.split('/')[1] ?? null;
		} else if (host === 'youtube.com' || host === 'youtube-nocookie.com') {
			if (parsed.pathname === '/watch') {
				id = parsed.searchParams.get('v');
			} else if (parsed.pathname.startsWith('/embed/')) {
				id = parsed.pathname.split('/')[2] ?? null;
			}
		}

		return id && /^[\w-]{11}$/.test(id) ? id : null;
	};

	const id = $derived(parseId(url));
	let playing = $state(false);

	const play = (event: MouseEvent) => {
		// Without JavaScript the link still opens the video; with it, the facade becomes the player.
		event.preventDefault();
		playing = true;
	};
</script>

{#if id}
	<AspectRatio ratio={16 / 9} class={cn('overflow-hidden rounded-md border bg-muted', className)}>
		{#if playing}
			<iframe
				{title}
				allowfullscreen
				class="size-full"
				src={`https://www.youtube-nocookie.com/embed/${id}?autoplay=1`}
				allow="accelerometer; autoplay; encrypted-media; picture-in-picture"
			></iframe>
		{:else}
			<img alt="" loading="lazy" class="size-full object-cover" src={`https://i.ytimg.com/vi/${id}/hqdefault.jpg`} />
			<Button
				href={url}
				target="_blank"
				rel="noopener noreferrer"
				variant="ghost"
				onclick={play}
				aria-label={`Play video: ${title}`}
				class="absolute inset-0 h-full w-full rounded-none hover:bg-black/10 dark:hover:bg-black/10"
			>
				<span class="flex size-14 items-center justify-center rounded-full border bg-background/90 text-foreground">
					<PlayIcon class="size-6 translate-x-0.5 fill-current" />
				</span>
			</Button>
		{/if}
	</AspectRatio>
{:else}
	<a href={url} target="_blank" rel="noopener noreferrer" class={cn('link-underline text-sm font-medium', className)}>
		Watch video ↗
	</a>
{/if}
