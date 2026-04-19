import { error } from '@sveltejs/kit';
import { projects } from '$lib/projects';
import type { PageLoad } from './$types';
import { hackathons } from '$lib/hackathons';

export function entries() {
	return hackathons.map((h) => ({ id: h.id }));
}

export const load: PageLoad = ({ params, data }) => {
	const hackathon = hackathons.find((h) => h.id === params.id);

	if (!hackathon) {
		throw error(404, 'Hackathon not found');
	}

	const project = projects.find((p) => p.hackathonId === params.id) ?? null;

	return {
		project,
		hackathon,
		teamMembersData: data.teamMembersData
	};
};
