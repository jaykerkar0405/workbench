<script lang="ts">
	import { page } from '$app/state';
	import { PUBLIC_SITE_URL } from '$env/static/public';

	interface Props {
		title: string;
		description: string;
	}

	let { title, description }: Props = $props();

	const BASE_URL = PUBLIC_SITE_URL;

	const canonicalUrl = $derived(`${BASE_URL}${page.url.pathname}`);
</script>

<svelte:head>
	<title>{title}</title>
	<meta name="title" content={title} />
	<link rel="canonical" href={canonicalUrl} />
	<meta name="description" content={description} />

	<!-- Open Graph -->
	<meta property="og:title" content={title} />
	<meta property="og:url" content={canonicalUrl} />
	<meta property="og:description" content={description} />

	<!-- Twitter -->
	<meta name="twitter:title" content={title} />
	<meta name="twitter:url" content={canonicalUrl} />
	<meta name="twitter:description" content={description} />
</svelte:head>
