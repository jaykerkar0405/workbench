import sharp from 'sharp';
import { join, extname, basename } from 'path';
import { readdirSync, statSync, existsSync } from 'fs';

const EXTENSIONS: string[] = ['.png', '.jpg', '.jpeg'];
const DIRS: string[] = ['./static/hackathons', './static/projects'];

let totalConverted = 0;
let totalSavedBytes = 0;

async function processDir(dir: string): Promise<void> {
	let entries: string[];

	try {
		entries = readdirSync(dir);
	} catch {
		console.warn(`⚠ Skipping missing directory: ${dir}`);
		return;
	}

	for (const entry of entries) {
		const fullPath = join(dir, entry);
		const stat = statSync(fullPath);

		if (stat.isDirectory()) {
			await processDir(fullPath);
			continue;
		}

		const ext = extname(entry).toLowerCase();
		if (!EXTENSIONS.includes(ext)) continue;

		const webpPath = join(dir, basename(entry, ext) + '.webp');
		if (existsSync(webpPath)) {
			console.log(`⏭ Already exists, skipping: ${webpPath}`);
			continue;
		}

		const isIcon = basename(entry, ext).toLowerCase() === 'icon';
		const quality: number = isIcon ? 90 : 80;

		try {
			await sharp(fullPath).webp({ quality }).toFile(webpPath);

			const originalSize = stat.size;
			const newSize = statSync(webpPath).size;
			const saved = originalSize - newSize;

			totalSavedBytes += saved;
			totalConverted++;

			console.log(
				`✓ ${fullPath} → .webp  (${(originalSize / 1024).toFixed(1)}KB → ${(newSize / 1024).toFixed(1)}KB, saved ${(saved / 1024).toFixed(1)}KB)`
			);
		} catch (err) {
			console.error(`✗ Failed: ${fullPath}`, (err as Error).message);
		}
	}
}

console.log('Starting image optimization...\n');

for (const dir of DIRS) {
	await processDir(dir);
}

console.log(`
   Done!
   Converted:   ${totalConverted} files
   Total saved: ${(totalSavedBytes / 1024 / 1024).toFixed(2)} MB
`);
