import type { PageLoad } from './$types';
import { projects } from '$lib/projects';

export function entries() {
	const hackathonIds = projects
		.filter((p) => p.hackathonId)
		.map((p) => p.hackathonId as string)
		.filter((id, index, self) => self.indexOf(id) === index);
	return hackathonIds.map((id) => ({ id }));
}

export const load: PageLoad = ({ params }) => {
	return {
		id: params.id
	};
};
