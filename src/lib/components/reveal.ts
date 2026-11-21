import type { Attachment } from 'svelte/attachments';

export type RevealOptions = { delay?: number; stagger?: boolean; mask?: boolean };

const TRANSITION_MS = 400;
const MASK_TRANSITION_MS = 500;
const STAGGER_STEP_MS = 30;
const STAGGER_CAP = 6;
const MARGIN_MS = 80;
// The observer's root is extended this far upward, so anything above the viewport counts as intersecting.
// Without it, content jumped past (End key, anchor link, restored scroll) would stay hidden.
const ABOVE_PX = 1_000_000;

/**
 * Reveals an element (or, with `stagger`, its direct children) the first time it scrolls into view.
 * The default is a fade and rise. Media can opt into a mask. Elements already in view or scrolled past on the first
 * observer callback are never hidden. Reveal attributes are removed once the transition
 * has finished so they don't fight later hover transitions. The CSS lives in layout.css.
 */
export function reveal(options: RevealOptions = {}): Attachment<HTMLElement> {
	const { delay, stagger = false, mask = false } = options;

	return (node) => {
		if (typeof IntersectionObserver === 'undefined' || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
			return () => {};
		}

		let hidden = false;
		let timer: ReturnType<typeof setTimeout> | undefined;

		const clear = () => {
			node.removeAttribute('data-reveal');
			node.removeAttribute('data-reveal-kind');
			node.removeAttribute('data-revealed');
			node.style.removeProperty('--reveal-delay');
			if (!node.getAttribute('style')) node.removeAttribute('style');
		};

		const observer = new IntersectionObserver(
			(entries) => {
				const entry = entries[entries.length - 1];
				if (!entry) return;

				if (!hidden) {
					// First callback: decide whether the element ever needs hiding.
					if (entry.isIntersecting || entry.boundingClientRect.top < 0) {
						observer.disconnect();
						return;
					}
					hidden = true;
					node.setAttribute('data-reveal', stagger ? 'stagger' : '');
					if (mask) node.setAttribute('data-reveal-kind', 'mask');
					if (delay !== undefined) node.style.setProperty('--reveal-delay', `${delay}ms`);
					return;
				}

				if (entry.isIntersecting) {
					observer.disconnect();
					node.setAttribute('data-revealed', '');
					const duration = mask ? MASK_TRANSITION_MS : TRANSITION_MS;
					const total = (delay ?? 0) + duration + (stagger ? STAGGER_CAP * STAGGER_STEP_MS : 0) + MARGIN_MS;
					timer = setTimeout(clear, total);
				}
			},
			{ rootMargin: `${ABOVE_PX}px 0px -10% 0px`, threshold: 0 }
		);

		observer.observe(node);

		return () => {
			observer.disconnect();
			clearTimeout(timer);
			clear();
		};
	};
}
