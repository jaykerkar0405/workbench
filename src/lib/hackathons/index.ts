import type { Hackathon } from './types';

export const hackathons: Hackathon[] = [
	{
		id: 'hack-byte-3.0',
		duration: '36 Hours',
		date: 'Apr 4-6, 2025',
		title: 'HackByte 3.0',
		location: 'Jabalpur, India',
		organizer: 'IIITDM Jabalpur',
		website: 'https://hackbyte3.devfolio.co',
		prize: {
			label: 'GitHub Track Winner'
		}
	}
];

export type { Hackathon } from './types';
