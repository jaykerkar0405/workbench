import { error } from '@sveltejs/kit';
import { projects } from '$lib/projects';
import { hackathons } from '$lib/hackathons';
import type { PageServerLoad } from './$types';
import { GITHUB_PAT } from '$env/static/private';

export const load: PageServerLoad = async ({ params, fetch }) => {
	const hackathon = hackathons.find((h) => h.id === params.id);

	if (!hackathon) {
		throw error(404, 'Hackathon not found');
	}

	const project = projects.find((p) => p.hackathonId === params.id) ?? null;

	const headers: HeadersInit = {};
	if (GITHUB_PAT) {
		headers['Authorization'] = `Bearer ${GITHUB_PAT}`;
	}

	const images: string[] = [];

	for (let i = 1; i <= 20; i++) {
		const imagePath = `/hackathons/${params.id}/image-${i}.webp`;
		try {
			const response = await fetch(imagePath, { method: 'HEAD' });
			if (response.ok) {
				images.push(imagePath);
			} else {
				break;
			}
		} catch {
			break;
		}
	}

	const teamMembersData = project
		? await Promise.all(
				project.teamMembers.map(async (member) => {
					try {
						const response = await fetch(`https://api.github.com/users/${member.githubUsername}`, { headers });
						if (response.ok) {
							const data = await response.json();
							return {
								avatar: data.avatar_url,
								followers: data.followers,
								profileUrl: data.html_url,
								username: member.githubUsername,
								name: data.name || member.githubUsername
							};
						}
					} catch (e) {
						console.error(`Failed to fetch data for ${member.githubUsername}`, e);
					}
					return null;
				})
			).then((r) => r.filter((m): m is NonNullable<typeof m> => m !== null))
		: [];

	return { images, teamMembersData };
};
