import { projects } from '$lib/projects';
import { hackathons } from '$lib/hackathons';
import type { Project } from '$lib/projects/types';
import type { Hackathon } from '$lib/hackathons/types';

const hackathonTimestamp = (p: Project): number => {
	if (!p.hackathonId) return -Infinity;
	const h = hackathons.find((h) => h.id === p.hackathonId);
	return h ? new Date(h.timestamp).getTime() : -Infinity;
};

const sortByHackathon = (a: Project, b: Project) => hackathonTimestamp(b) - hackathonTimestamp(a);

export const otherProjects: Project[] = projects.filter((p) => !p.featured).sort(sortByHackathon);
export const featuredProjects: Project[] = projects.filter((p) => p.featured).sort(sortByHackathon);

/** Featured projects, then the rest, each sorted by hackathon date (newest first). The index follows this order. */
export const orderedProjects: Project[] = [...featuredProjects, ...otherProjects];

const indexById: Record<string, string> = Object.fromEntries(
	orderedProjects.map((p, i) => [p.id, String(i + 1).padStart(2, '0')])
);

/** Two-digit number of a project from `01`, or an empty string for an unknown id. */
export const projectIndex = (id: string): string => indexById[id] ?? '';

export const hackathonFor = (project: Project): Hackathon | undefined =>
	project.hackathonId ? hackathons.find((h) => h.id === project.hackathonId) : undefined;
