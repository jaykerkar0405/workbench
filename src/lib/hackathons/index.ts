import type { Hackathon } from './types';

export const hackathons: Hackathon[] = [
	{
		duration: 48,
		id: 'hack-byte-3.0',
		title: 'HackByte 3.0',
		timestamp: '2025-04-04',
		location: 'Jabalpur, India',
		organizer: 'IIITDM Jabalpur',
		website: 'https://hackbyte3.devfolio.co',
		prize: {
			label: 'GitHub Track Winner'
		}
	}
];

export type { Hackathon } from './types';
