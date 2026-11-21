// Presentation-side photo lookup for hackathon pages. Unlike loadHackathonImages in $lib/assets/images
// (async, so the page has to render a placeholder first), this resolves synchronously: a page knows its
// photos, and their real dimensions, at render time, so they are part of the prerendered HTML.
import type { ComponentProps } from 'svelte';
import type EnhancedImage from '$lib/components/enhanced-image.svelte';

type Photo = ComponentProps<typeof EnhancedImage>['src'];

const modules = import.meta.glob('$lib/assets/hackathons/*/image-*.jpg', {
	eager: true,
	query: { enhanced: true }
}) as Record<string, { default: Photo }>;

const byEvent: Record<string, { n: number; photo: Photo }[]> = {};

for (const [path, mod] of Object.entries(modules)) {
	const id = path.match(/\/hackathons\/([^/]+)\//)?.[1];
	if (!id) continue;
	(byEvent[id] ??= []).push({ n: parseInt(path.match(/image-(\d+)/)?.[1] ?? '0'), photo: mod.default });
}

for (const list of Object.values(byEvent)) list.sort((a, b) => a.n - b.n);

/** The event's photos in numeric order (image-1, image-2, … image-10); empty when it has none. */
export function hackathonPhotos(id: string): Photo[] {
	return (byEvent[id] ?? []).map((entry) => entry.photo);
}
