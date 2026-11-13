<script lang="ts">
	import EyeIcon from '@lucide/svelte/icons/eye';
	import DownloadIcon from '@lucide/svelte/icons/download';
	import { Button } from '$lib/components/ui/button';
	import * as Dialog from '$lib/components/ui/dialog';

	let {
		class: className = '',
		showDownload = true,
		useDesktopModal = true,
		previewVariant = 'default',
		previewLabel = 'Preview Resume',
		downloadLabel = 'Download Resume',
		resumeUrl = '/docs/jay_kerkar_resume.pdf',
		downloadFileName = 'jay_kerkar_resume.pdf'
	}: {
		class?: string;
		resumeUrl?: string;
		previewLabel?: string;
		showDownload?: boolean;
		downloadLabel?: string;
		downloadFileName?: string;
		useDesktopModal?: boolean;
		previewVariant?: 'default' | 'link';
	} = $props();

	let isPreviewOpen = $state(false);

	const previewResume = () => {
		const shouldOpenInNewTab = !useDesktopModal || window.matchMedia('(max-width: 639px)').matches;

		if (shouldOpenInNewTab) {
			window.open(resumeUrl, '_blank', 'noopener,noreferrer');
			return;
		}

		isPreviewOpen = true;
	};

	const metaLinkClass =
		'rounded-sm font-mono text-[0.72rem] tracking-[0.08em] text-muted-foreground uppercase transition-colors duration-(--dur-1) outline-none hover:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50';
</script>

<div class={`flex flex-col items-start gap-3 sm:flex-row sm:items-center ${className}`.trim()}>
	<Button type="button" variant={previewVariant} onclick={previewResume} class="w-full sm:w-auto">
		<EyeIcon class="size-4" />
		{previewLabel}
	</Button>

	{#if showDownload}
		<Button href={resumeUrl} variant="link" download={downloadFileName}>
			<DownloadIcon class="size-4" />
			{downloadLabel}
		</Button>
	{/if}
</div>

{#if useDesktopModal}
	<Dialog.Root bind:open={isPreviewOpen}>
		<Dialog.Content
			showCloseButton
			class="flex h-[80vh] flex-col gap-0 overflow-hidden rounded-lg! p-0 duration-(--dur-2) ease-(--ease-out) sm:max-w-[min(56rem,calc(100%-2rem))] data-open:zoom-in-100! data-open:slide-in-from-bottom-2 data-closed:duration-(--dur-1) data-closed:zoom-out-100!"
		>
			<Dialog.Header class="flex-row items-center justify-between gap-4 border-b py-3 pr-14 pl-4">
				<Dialog.Title class="text-base font-semibold">Resume</Dialog.Title>
				<Dialog.Description class="sr-only">Preview of Jay Kerkar's resume as a PDF.</Dialog.Description>

				<div class="flex items-center gap-4">
					<a href={resumeUrl} download={downloadFileName} class={metaLinkClass}>Download ↓</a>
					<a href={resumeUrl} target="_blank" rel="noopener noreferrer" class={metaLinkClass}>Open in new tab ↗</a>
				</div>
			</Dialog.Header>

			<div class="min-h-0 flex-1 bg-muted">
				<iframe src={resumeUrl} title="Resume PDF preview" class="size-full"></iframe>
			</div>
		</Dialog.Content>
	</Dialog.Root>
{/if}
