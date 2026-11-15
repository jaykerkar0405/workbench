// Presentation-side screenshot lookup for project pages, the counterpart of hackathon-photos.ts. Unlike
// loadProjectScreenshots in $lib/assets/images (async, so the page has to render skeletons first), this resolves
// synchronously: the page knows its screenshots, and their real dimensions, at render time, so they are part of the
// prerendered HTML and nothing shifts when they load.
import type { ComponentProps } from 'svelte';
import type EnhancedImage from '$lib/components/enhanced-image.svelte';

type Screenshot = ComponentProps<typeof EnhancedImage>['src'];

const modules = import.meta.glob('$lib/assets/projects/*/screenshot-*.jpg', {
	eager: true,
	query: { enhanced: true }
}) as Record<string, { default: Screenshot }>;

const byProject: Record<string, { n: number; screenshot: Screenshot }[]> = {};

for (const [path, mod] of Object.entries(modules)) {
	const id = path.match(/\/projects\/([^/]+)\//)?.[1];
	if (!id) continue;
	(byProject[id] ??= []).push({ n: parseInt(path.match(/screenshot-(\d+)/)?.[1] ?? '0'), screenshot: mod.default });
}

for (const list of Object.values(byProject)) list.sort((a, b) => a.n - b.n);

/** The project's screenshots in numeric order (screenshot-1, screenshot-2, …); empty when it has none. */
export function projectScreenshots(id: string): Screenshot[] {
	return (byProject[id] ?? []).map((entry) => entry.screenshot);
}
