<script lang="ts">
	import { cn } from '$lib/utils';

	// A number over a label. The number is its final text in the prerendered HTML: no count-up, no observer.
	let {
		value,
		label,
		suffix = '',
		decimals = 0,
		size = 'lg',
		class: className
	}: {
		value: number;
		label: string;
		class?: string;
		suffix?: string;
		decimals?: number;
		size?: 'lg' | 'md';
	} = $props();

	const numberClasses = {
		lg: 'text-4xl font-bold tracking-tight tabular-nums md:text-5xl',
		md: 'text-[2.5rem] leading-none font-bold tracking-tight tabular-nums'
	};

	// Fixed decimals with thousands separators (1,075). Numbers under 1000 read as before.
	const text = $derived(
		`${value.toLocaleString('en-US', { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}${suffix}`
	);
</script>

<div class={cn('flex flex-col gap-2', className)}>
	<span class={numberClasses[size]}>{text}</span>
	<span class="label">{label}</span>
</div>
