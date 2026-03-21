<script lang="ts">
	import { Download, Eye, X } from 'lucide-svelte';
	import { Button } from '$lib/components/ui/button';

	let {
		class: className = '',
		useDesktopModal = true,
		previewLabel = 'Preview Resume',
		downloadLabel = 'Download Resume',
		resumeUrl = '/docs/jay_kerkar_resume.pdf',
		downloadFileName = 'jay_kerkar_resume.pdf'
	}: {
		class?: string;
		resumeUrl?: string;
		previewLabel?: string;
		downloadLabel?: string;
		downloadFileName?: string;
		useDesktopModal?: boolean;
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

	const closePreview = () => {
		isPreviewOpen = false;
	};

	const handleWindowKeydown = (event: KeyboardEvent) => {
		if (isPreviewOpen && event.key === 'Escape') {
			closePreview();
		}
	};
</script>

<svelte:window onkeydown={handleWindowKeydown} />

<div class={`flex flex-col items-start gap-3 sm:flex-row sm:items-center ${className}`.trim()}>
	<Button
		type="button"
		onclick={previewResume}
		class="w-full sm:w-auto"
		aria-label="Preview resume in a new tab on mobile, or in a modal on desktop"
	>
		<Eye class="size-4" />
		{previewLabel}
	</Button>

	<Button
		href={resumeUrl}
		variant="outline"
		class="w-full sm:w-auto"
		download={downloadFileName}
		aria-label="Download resume as PDF"
	>
		<Download class="size-4" />
		{downloadLabel}
	</Button>
</div>

{#if useDesktopModal && isPreviewOpen}
	<div class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6" role="none">
		<button
			type="button"
			onclick={closePreview}
			aria-label="Close resume preview"
			class="absolute inset-0 bg-background/50 backdrop-blur-sm"
		></button>

		<div
			role="dialog"
			aria-modal="true"
			aria-labelledby="resume-preview-title"
			class="relative z-10 flex h-[80vh] w-full max-w-4xl flex-col overflow-hidden rounded-lg border border-border bg-background shadow-lg"
		>
			<div class="flex items-center justify-between border-b border-border px-4 py-3">
				<h3 id="resume-preview-title" class="text-base font-semibold">Resume Preview</h3>
				<Button
					size="icon"
					type="button"
					variant="ghost"
					onclick={closePreview}
					aria-label="Close resume preview modal"
				>
					<X class="size-4" />
				</Button>
			</div>

			<iframe src={resumeUrl} title="Resume PDF preview" class="h-full w-full" loading="lazy"></iframe>
		</div>
	</div>
{/if}
