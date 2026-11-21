import { hackathons } from '$lib/hackathons';
import { projects } from '$lib/projects';
import type { Hackathon } from '$lib/hackathons/types';
import type { Project } from '$lib/projects/types';

/** Every hackathon, newest first. */
export const orderedHackathons: Hackathon[] = [...hackathons].sort(
	(a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
);

const indexById: Record<string, string> = Object.fromEntries(
	orderedHackathons.map((h, i) => [h.id, String(i + 1).padStart(2, '0')])
);

/** Two-digit number from `01` (the newest), or an empty string for an unknown id. */
export const hackathonIndex = (id: string): string => indexById[id] ?? '';

/** The project that was built at this hackathon, if any. */
export const projectFor = (hackathon: Hackathon): Project | undefined =>
	projects.find((p) => p.hackathonId === hackathon.id);

/** Years newest first, each with its hackathons newest first. The year comes from `timestamp`. */
export const hackathonsByYear: { year: number; items: Hackathon[] }[] = (() => {
	const groups: Record<number, Hackathon[]> = {};
	for (const h of orderedHackathons) {
		const year = Number(h.timestamp.slice(0, 4));
		(groups[year] ??= []).push(h);
	}
	return Object.keys(groups)
		.map(Number)
		.sort((a, b) => b - a)
		.map((year) => ({ year, items: groups[year] }));
})();
