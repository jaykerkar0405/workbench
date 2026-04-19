import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { projects } from '$lib/projects';

export function entries() {
	return projects.map((project) => ({ id: project.id }));
}

export const load: PageLoad = async ({ params, data }) => {
	const project = projects.find((p) => p.id === params.id);

	if (!project) {
		throw error(404, 'Project not found');
	}

	let ExtendedDescription = null;
	try {
		const module = await import(`$lib/projects/extended_descriptions/${params.id}.svx`);
		ExtendedDescription = module.default;
	} catch (e) {
		console.log('No extended description found for this project');
	}

	return {
		project,
		ExtendedDescription,
		repoData: data.repoData,
		teamMembersData: data.teamMembersData
	};
};
