export type RankedPrize = '1st' | '2nd' | '3rd';

export interface Prize {
	label?: string;
	rank?: RankedPrize;
}

export interface Hackathon {
	id: string;
	title: string;
	prize?: Prize;
	website: string;
	location: string;
	duration: number;
	timestamp: string;
	organizer: string;
}
