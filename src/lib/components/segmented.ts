import type { Attachment } from 'svelte/attachments';

/**
 * The segmented-control look, defined once: the header nav and the mobile dock use it now, and the projects filter
 * (a shadcn ToggleGroup) adopts it in V11.
 *
 * Markup contract: a container whose direct children are the segments. The active segment is `aria-current="page"`
 * (links) or `data-state="on"` (toggle items). Apply `segmentedIndicator` to the container with `{@attach ...}`;
 * the container also needs a positioning context (`relative` or `fixed`), which the caller adds.
 *
 * The indicator is the container's `::before` (see the "Segmented control" block in layout.css), clipped to the active
 * segment with `clip-path: inset(... round r)`. The attachment only measures the active segment and writes the inset
 * values as custom properties, so the corners keep the segment's own radius for the whole slide and nothing but
 * `clip-path` animates.
 *
 * Before JavaScript (prerendered HTML) the active segment carries its own fill through `segmentedItem`. Once the
 * indicator has been measured the container gets `data-segmented-ready`, which makes that fill transparent in the same
 * frame the indicator appears, so the hand-over is invisible. The slide is only enabled two frames later
 * (`data-segmented-animate`), so nothing animates on load.
 */

/** Container: 1px border, 8px corners, 4px inner padding, no fill, shadow or blur. Add size and display as needed. */
export const segmentedContainer = 'isolate gap-1 rounded-md border p-1';

/** A segment: 4px corners, sans, medium, 14px. The `aria-current` / `data-state` rules are the pre-JavaScript fill. */
export const segmentedItem =
	'relative inline-flex h-6.5 items-center justify-center rounded-sm px-4 text-sm font-medium whitespace-nowrap text-muted-foreground outline-none transition-colors duration-(--dur-2) ease-(--ease-out) hover:text-foreground focus-visible:ring-3 focus-visible:ring-ring/50 aria-[current=page]:bg-foreground aria-[current=page]:text-background aria-[current=page]:hover:text-background data-[state=on]:bg-foreground data-[state=on]:text-background data-[state=on]:hover:text-background';

const ACTIVE = '[aria-current="page"], [data-state="on"]';

export const segmentedIndicator: Attachment<HTMLElement> = (container) => {
	let animateFrame = 0;

	const apply = () => {
		const box = container.getBoundingClientRect();
		if (box.width === 0 || box.height === 0) return; // display: none; the resize observer fires when it shows

		const active = container.querySelector<HTMLElement>(`:scope > :is(${ACTIVE})`);
		if (!active) {
			container.toggleAttribute('data-segmented-empty', true);
			return;
		}

		const seg = active.getBoundingClientRect();
		if (seg.width === 0) return;

		// Insets are relative to the container's padding box, which is what the absolutely positioned ::before spans.
		// Border widths come from computed style because clientLeft / clientWidth are rounded to whole pixels.
		const style = getComputedStyle(container);
		const left = box.left + parseFloat(style.borderLeftWidth);
		const top = box.top + parseFloat(style.borderTopWidth);
		const right = box.right - parseFloat(style.borderRightWidth);
		const bottom = box.bottom - parseFloat(style.borderBottomWidth);
		const set = (name: string, value: string) => container.style.setProperty(name, value);
		set('--seg-t', `${seg.top - top}px`);
		set('--seg-l', `${seg.left - left}px`);
		set('--seg-r', `${right - seg.right}px`);
		set('--seg-b', `${bottom - seg.bottom}px`);
		set('--seg-radius', getComputedStyle(active).borderTopLeftRadius);
		container.toggleAttribute('data-segmented-empty', false);
		container.setAttribute('data-segmented-ready', '');
	};

	const enableAnimation = () => {
		cancelAnimationFrame(animateFrame);
		animateFrame = requestAnimationFrame(() => {
			animateFrame = requestAnimationFrame(() => container.setAttribute('data-segmented-animate', ''));
		});
	};

	// Size and font changes move the block without sliding it; only an active-segment change animates.
	const snap = () => {
		container.removeAttribute('data-segmented-animate');
		apply();
		enableAnimation();
	};

	apply();
	enableAnimation();

	const mutations = new MutationObserver(apply);
	mutations.observe(container, { subtree: true, attributes: true, attributeFilter: ['aria-current', 'data-state'] });
	const sizes = new ResizeObserver(snap);
	sizes.observe(container);
	document.fonts?.ready.then(snap);

	return () => {
		cancelAnimationFrame(animateFrame);
		mutations.disconnect();
		sizes.disconnect();
		for (const name of ['--seg-t', '--seg-r', '--seg-b', '--seg-l', '--seg-radius'])
			container.style.removeProperty(name);
		for (const name of ['data-segmented-ready', 'data-segmented-animate', 'data-segmented-empty']) {
			container.removeAttribute(name);
		}
	};
};
