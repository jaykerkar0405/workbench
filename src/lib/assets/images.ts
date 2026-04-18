/* eslint-disable @typescript-eslint/no-explicit-any */

type ImageModule = { default: any };

const projectIconModules: Record<string, ImageModule> = import.meta.glob('$lib/assets/projects/*/icon.png', {
	eager: true,
	query: { enhanced: true }
});

const projectScreenshotModules: Record<string, ImageModule> = import.meta.glob(
	'$lib/assets/projects/*/screenshot-*.png',
	{ eager: true, query: { enhanced: true } }
);

const hackathonIconModules: Record<string, ImageModule> = import.meta.glob('$lib/assets/hackathons/*/icon.png', {
	eager: true,
	query: { enhanced: true }
});

const hackathonImageModules: Record<string, ImageModule> = import.meta.glob(
	'$lib/assets/hackathons/*/image-*.{png,jpg}',
	{ eager: true, query: { enhanced: true } }
);

export function getProjectIcon(projectId: string): any | undefined {
	const key = Object.keys(projectIconModules).find((k) => k.includes(`/${projectId}/icon.png`));
	return key ? projectIconModules[key].default : undefined;
}

export function getProjectScreenshots(projectId: string): any[] {
	return Object.entries(projectScreenshotModules)
		.filter(([key]) => key.includes(`/${projectId}/`))
		.sort(([a], [b]) => {
			const numA = parseInt(a.match(/screenshot-(\d+)/)?.[1] || '0');
			const numB = parseInt(b.match(/screenshot-(\d+)/)?.[1] || '0');
			return numA - numB;
		})
		.map(([, mod]) => mod.default);
}

export function getHackathonIcon(hackathonId: string): any | undefined {
	const key = Object.keys(hackathonIconModules).find((k) => k.includes(`/${hackathonId}/icon.png`));
	return key ? hackathonIconModules[key].default : undefined;
}

export function getHackathonImages(hackathonId: string): any[] {
	return Object.entries(hackathonImageModules)
		.filter(([key]) => key.includes(`/${hackathonId}/`))
		.sort(([a], [b]) => {
			const numA = parseInt(a.match(/image-(\d+)/)?.[1] || '0');
			const numB = parseInt(b.match(/image-(\d+)/)?.[1] || '0');
			return numA - numB;
		})
		.map(([, mod]) => mod.default);
}
