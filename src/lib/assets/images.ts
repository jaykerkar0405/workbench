/* eslint-disable @typescript-eslint/no-explicit-any */

type ImageModule = { default: any };

const projectIconModules: Record<string, ImageModule> = import.meta.glob('$lib/assets/projects/*/icon.png', {
	eager: true,
	query: { enhanced: true }
});

const projectScreenshotModules = import.meta.glob('$lib/assets/projects/*/screenshot-*.jpg', {
	eager: false,
	query: { enhanced: true }
});

const hackathonIconModules: Record<string, ImageModule> = import.meta.glob('$lib/assets/hackathons/*/icon.png', {
	eager: true,
	query: { enhanced: true }
});

const hackathonImageModules = import.meta.glob('$lib/assets/hackathons/*/image-*.jpg', {
	eager: false,
	query: { enhanced: true }
});

export function getProjectIcon(projectId: string): any | undefined {
	const key = Object.keys(projectIconModules).find((k) => k.includes(`/${projectId}/icon.png`));
	return key ? projectIconModules[key].default : undefined;
}

export function getHackathonIcon(hackathonId: string): any | undefined {
	const key = Object.keys(hackathonIconModules).find((k) => k.includes(`/${hackathonId}/icon.png`));
	return key ? hackathonIconModules[key].default : undefined;
}

export async function loadProjectScreenshots(projectId: string): Promise<any[]> {
	const entries = Object.entries(projectScreenshotModules)
		.filter(([key]) => key.includes(`/${projectId}/`))
		.sort(([a], [b]) => {
			const numA = parseInt(a.match(/screenshot-(\d+)/)?.[1] || '0');
			const numB = parseInt(b.match(/screenshot-(\d+)/)?.[1] || '0');
			return numA - numB;
		});

	const modules = await Promise.all(entries.map(([, loader]) => loader()));
	return modules.map((m) => (m as ImageModule).default);
}

export async function loadHackathonImages(hackathonId: string): Promise<any[]> {
	const entries = Object.entries(hackathonImageModules)
		.filter(([key]) => key.includes(`/${hackathonId}/`))
		.sort(([a], [b]) => {
			const numA = parseInt(a.match(/image-(\d+)/)?.[1] || '0');
			const numB = parseInt(b.match(/image-(\d+)/)?.[1] || '0');
			return numA - numB;
		});

	const modules = await Promise.all(entries.map(([, loader]) => loader()));
	return modules.map((m) => (m as ImageModule).default);
}
