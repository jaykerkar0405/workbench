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
	},
	{
		duration: 24,
		id: 'hackx3.0',
		organizer: 'NMIMS',
		title: 'HackX 3.0',
		timestamp: '2025-02-22',
		location: 'Navi Mumbai, India',
		website: 'https://unstop.com/hackathons/hackx-30-nmims-navi-mumbai-1374904',
		prize: {
			rank: '2nd'
		}
	},
	{
		duration: 504,
		location: 'Online',
		id: 'ethonline-2025',
		organizer: 'ETHGlobal',
		title: 'ETHOnline 2025',
		timestamp: '2025-10-10',
		website: 'https://ethglobal.com/events/ethonline2025',
		prize: {
			rank: '1st'
		}
	},
	{
		duration: 24,
		id: 'need-for-code-4.0',
		timestamp: '2025-08-05',
		location: 'Mumbai, India',
		title: 'Need For Code 4.0',
		organizer: 'TSEC CodeTantra',
		website: 'https://unstop.com/hackathons/need-for-code-40-tsec-codetantra-1522228'
	},
	{
		duration: 24,
		id: 'eth-india-villa',
		organizer: 'Devfolio',
		title: 'ETHIndiaVilla',
		timestamp: '2025-11-30',
		location: 'Bengaluru, India',
		website: 'https://ethindia-villa.devfolio.co',
		prize: {
			label: 'Project Submission Prize'
		}
	}
];

export type { Hackathon } from './types';
