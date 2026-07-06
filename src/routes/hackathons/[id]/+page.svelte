<script lang="ts">
	import {
		X,
		Clock,
		Users,
		Trophy,
		MapPin,
		Calendar,
		ImageOff,
		Building2,
		ChevronUp,
		ExternalLink
	} from 'lucide-svelte';
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import Seo from '$lib/components/seo.svelte';
	import { formatDateRange } from '$lib/utils.js';
	import { Button } from '$lib/components/ui/button';
	import type { Hackathon } from '$lib/hackathons/types';
	import ProjectCard from '$lib/components/project-card.svelte';
	import EnhancedImage from '$lib/components/enhanced-image.svelte';
	import { getHackathonIcon, loadHackathonImages } from '$lib/assets/images';
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';

	let { data } = $props();

	let images = $state<any[]>([]);
	const project = $derived(data.project);
	const hackathon = $derived(data.hackathon);
	const icon = $derived(getHackathonIcon(hackathon.id));
	const teamMembersData = $derived(data.teamMembersData || []);

	$effect(() => {
		loadHackathonImages(hackathon.id).then((imgs) => {
			images = imgs;
		});
	});

	let fullHeight = $state(0);
	let mounted = $state(false);
	let leftColHeight = $state(0);
	let isExpanded = $state(false);
	let needsExpansion = $state(false);
	let lightboxIndex = $state<number | null>(null);
	let leftColRef: HTMLDivElement | undefined = $state();
	let imagesInnerRef: HTMLDivElement | undefined = $state();

	function openLightbox(index: number) {
		lightboxIndex = index;
		document.body.style.overflow = 'hidden';
	}

	function closeLightbox() {
		lightboxIndex = null;
		document.body.style.overflow = '';
	}

	function handleWindowKeydown(e: KeyboardEvent) {
		if (e.key === 'Escape') closeLightbox();
	}

	onMount(() => {
		mounted = true;
	});

	$effect(() => {
		if (leftColRef && imagesInnerRef) {
			const leftCol = leftColRef;
			const imagesInner = imagesInnerRef;

			leftColHeight = leftCol.scrollHeight - 9.3;

			const checkHeight = () => {
				const iHeight = imagesInner.scrollHeight;
				fullHeight = iHeight;
				needsExpansion = iHeight > leftColHeight;
			};

			checkHeight();

			const ro = new ResizeObserver(checkHeight);
			ro.observe(imagesInner);
			return () => ro.disconnect();
		}
	});

	const dateRange = $derived(formatDateRange(hackathon.timestamp, hackathon.duration));

	const prizeLabel = (h: Hackathon): string | null => {
		if (!h.prize) return null;
		if (h.prize.rank) {
			const map = { '1st': '🥇 1st Place', '2nd': '🥈 2nd Place', '3rd': '🥉 3rd Place' };
			return map[h.prize.rank];
		}
		return h.prize.label ?? null;
	};

	const badge = $derived(prizeLabel(hackathon));

	const seoDescription = $derived(() => {
		const durationUnit = Number(hackathon.duration) === 1 ? 'hour' : 'hours';
		const prize = hackathon.prize
			? hackathon.prize.rank
				? ` Achieved ${hackathon.prize.rank} place.`
				: hackathon.prize.label
					? ` Won ${hackathon.prize.label}.`
					: ''
			: '';
		return `${hackathon.title} hackathon by ${hackathon.organizer} in ${hackathon.location}. ${hackathon.duration} ${durationUnit} event.${prize}`;
	});
</script>

<Seo description={seoDescription()} title="{hackathon.title} | Hackathons | Jay Kerkar" />

<svelte:window onkeydown={handleWindowKeydown} />

{#if lightboxIndex !== null}
	<div
		role="dialog"
		tabindex="-1"
		aria-modal="true"
		onclick={closeLightbox}
		aria-label="Image fullscreen view"
		onkeydown={(e) => e.key === 'Escape' && closeLightbox()}
		class="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm"
	>
		<button
			type="button"
			onclick={closeLightbox}
			aria-label="Close fullscreen"
			class="absolute top-4 right-4 cursor-pointer rounded-full bg-white/10 p-2 text-white transition-colors hover:bg-white/20"
		>
			<X class="size-5" />
		</button>
		<div
			role="presentation"
			onclick={(e) => e.stopPropagation()}
			onkeydown={(e) => e.stopPropagation()}
			class="flex items-center justify-center"
		>
			<EnhancedImage
				src={images[lightboxIndex]}
				alt="{hackathon.title} Image {lightboxIndex + 1}"
				containerClass="max-h-[90vh] max-w-[90vw]"
				skeletonClass="h-[70vh] w-[70vw] rounded-lg"
				class="max-h-[90vh] max-w-[90vw] rounded-lg object-contain shadow-2xl"
			/>
		</div>
	</div>
{/if}

{#key mounted}
	<div class="container mx-auto max-w-7xl px-4 py-12">
		<div class="mb-8" in:fly={{ y: -20, duration: 600, delay: 0 }}>
			<div class="flex flex-wrap items-start justify-between gap-4">
				<div class="flex items-start gap-4">
					{#if icon}
						<EnhancedImage
							src={icon}
							alt={hackathon.title}
							containerClass="shrink-0"
							skeletonClass="rounded-lg"
							class="size-15 rounded-lg border border-border object-contain"
						/>
					{/if}
					<div class="-mt-1 flex flex-col lg:gap-1">
						<h1 class="text-[1.675rem] font-bold">{hackathon.title}</h1>
						<div class="flex flex-wrap items-center gap-x-3 gap-y-1 text-[0.9rem] text-muted-foreground">
							<span class="flex items-center gap-1">
								<MapPin class="size-3.5 shrink-0" />
								{hackathon.location}
							</span>
							<span class="flex items-center gap-1">
								<Calendar class="size-3.5 shrink-0" />
								{dateRange}
							</span>
							<span class="flex items-center gap-1">
								<Clock class="size-3.5 shrink-0" />
								{hackathon.duration} Hours
							</span>
							<span class="flex items-center gap-1">
								<Building2 class="size-3.5 shrink-0" />
								{hackathon.organizer}
							</span>
						</div>
					</div>
				</div>

				<div class="flex flex-wrap items-center gap-3">
					{#if badge}
						<div
							class="flex items-center gap-1.5 rounded-full border border-border bg-secondary/50 px-3 py-1.5 text-sm font-medium"
						>
							<Trophy class="size-3.5 shrink-0" />
							{badge}
						</div>
					{/if}
					<a target="_blank" rel="noopener noreferrer" href={hackathon.website}>
						<Button variant="outline" size="icon" aria-label="Visit hackathon website">
							<ExternalLink class="size-4" />
						</Button>
					</a>
				</div>
			</div>
		</div>

		<div class="grid grid-cols-1 gap-6 lg:grid-cols-3 lg:items-start">
			<div bind:this={leftColRef} class="flex flex-col gap-5" in:fly={{ y: -20, duration: 600, delay: 300 }}>
				{#if project}
					<ProjectCard {project} />
				{/if}

				{#if teamMembersData.length > 0}
					<Card>
						<CardHeader>
							<CardTitle class="flex items-center gap-2 text-lg">
								<Users class="size-5" />
								Team
							</CardTitle>
						</CardHeader>
						<CardContent class="-mt-2 py-0">
							<div class="grid gap-4">
								{#each teamMembersData as member (member.username)}
									<a
										target="_blank"
										href={member.profileUrl}
										rel="noopener noreferrer"
										class="flex items-center gap-4 rounded-lg border border-border bg-secondary/30 p-4 transition-colors hover:bg-secondary/50"
									>
										<img src={member.avatar} alt={member.name} class="size-12 rounded-full border-2 border-border" />
										<div class="flex flex-col gap-1">
											<span class="font-semibold">{member.name}</span>
											<span class="text-sm text-muted-foreground">@{member.username}</span>
										</div>
									</a>
								{/each}
							</div>
						</CardContent>
					</Card>
				{/if}
			</div>

			{#if images.length > 0}
				<div class="lg:col-span-2" in:fly={{ y: -20, duration: 600, delay: 450 }}>
					<div class="relative">
						<div
							style:max-height={isExpanded ? `${fullHeight}px` : `${leftColHeight}px`}
							class="overflow-hidden rounded-xl transition-all duration-700 ease-in-out"
						>
							<div bind:this={imagesInnerRef} class="columns-2 gap-3">
								{#each images as image, i (i)}
									<div class="mb-3 break-inside-avoid overflow-hidden rounded-xl border border-border">
										<div class="relative">
											<button
												type="button"
												onclick={() => openLightbox(i)}
												aria-label="View image {i + 1} fullscreen"
												class="group block w-full cursor-zoom-in border-0 bg-transparent p-0"
											>
												<EnhancedImage
													src={image}
													class="h-auto w-full transition-transform duration-300 group-hover:scale-105"
													skeletonClass="aspect-video w-full"
													alt="{hackathon.title} Image {i + 1}"
												/>
											</button>
										</div>
									</div>
								{/each}
							</div>
						</div>

						{#if needsExpansion && !isExpanded}
							<div
								class="pointer-events-none absolute inset-x-0 -bottom-1 h-32 rounded-xl bg-linear-to-t from-background via-background/95 to-transparent backdrop-blur-[px] transition-opacity duration-700"
							></div>
						{/if}

						{#if needsExpansion}
							<div class="flex justify-center {isExpanded ? 'pt-4 pb-4' : 'absolute inset-x-0 bottom-1.5'}">
								<Button
									variant="default"
									onclick={() => (isExpanded = !isExpanded)}
									class="relative z-10 gap-2 shadow-lg backdrop-blur-sm transition-all duration-300"
								>
									{isExpanded ? 'Show Less' : 'See More'}
									<div
										class="transition-transform duration-300"
										style:transform={isExpanded ? 'rotate(0deg)' : 'rotate(180deg)'}
									>
										<ChevronUp class="size-4" />
									</div>
								</Button>
							</div>
						{/if}
					</div>
				</div>
			{:else}
				<div class="flex h-full lg:col-span-2" in:fly|global={{ y: -20, duration: 600, delay: 450 }}>
					<div
						class="flex h-full w-full flex-col items-center justify-center gap-4 rounded-xl border border-dashed border-border bg-secondary/20 p-8 text-center lg:gap-6 lg:p-12"
					>
						<ImageOff class="size-12 text-muted-foreground/60 lg:size-20" />
						<div class="flex flex-col gap-2 lg:gap-3">
							<p class="text-lg font-bold tracking-tight lg:text-2xl">404: Photos Not Found</p>
							<p class="max-w-xs text-sm text-muted-foreground lg:text-base">
								Too busy shipping code to open the camera app.
							</p>
						</div>
					</div>
				</div>
			{/if}
		</div>
	</div>
{/key}
