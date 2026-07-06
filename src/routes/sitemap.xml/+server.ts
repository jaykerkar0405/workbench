import { projects } from '$lib/projects';
import { hackathons } from '$lib/hackathons';
import { PUBLIC_SITE_URL } from '$env/static/public';

export const prerender = true;

const BASE_URL = PUBLIC_SITE_URL;

function buildUrl(path: string, lastmod: string, priority: string): string {
	return `
	<url>
		<loc>${BASE_URL}${path}</loc>
		<lastmod>${lastmod}</lastmod>
		<priority>${priority}</priority>
	</url>`;
}

export function GET() {
	const today = new Date().toISOString().split('T')[0];

	const staticRoutes = [
		buildUrl('', today, '1.0'),
		buildUrl('/projects', today, '0.8'),
		buildUrl('/hackathons', today, '0.8')
	];

	const projectRoutes = projects.map((project) => buildUrl(`/projects/${project.id}`, today, '0.6'));

	const hackathonRoutes = hackathons.map((hackathon) => buildUrl(`/hackathons/${hackathon.id}`, today, '0.6'));

	const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${staticRoutes.join('')}${projectRoutes.join('')}${hackathonRoutes.join('')}
</urlset>`;

	return new Response(sitemap.trim(), {
		headers: {
			'Content-Type': 'application/xml',
			'Cache-Control': 'max-age=0, s-maxage=3600'
		}
	});
}
