import type { Attachment } from 'svelte/attachments';

export type RevealOptions = { delay?: number; stagger?: boolean };

const TRANSITION_MS = 520;
const STAGGER_STEP_MS = 40;
const STAGGER_CAP = 8;
const MARGIN_MS = 80;

/**
 * Fades an element (or, with `stagger`, its direct children) in and up the first time
 * it scrolls into view. Elements already in view, or already scrolled past, on the first
 * observer callback are never hidden. Reveal attributes are removed once the transition
 * has finished so they don't fight later hover transitions. The CSS lives in layout.css.
 */
export function reveal(options: RevealOptions = {}): Attachment<HTMLElement> {
	const { delay, stagger = false } = options;

	return (node) => {
		if (typeof IntersectionObserver === 'undefined' || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
			return () => {};
		}

		let hidden = false;
		let timer: ReturnType<typeof setTimeout> | undefined;

		const clear = () => {
			node.removeAttribute('data-reveal');
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
					if (delay !== undefined) node.style.setProperty('--reveal-delay', `${delay}ms`);
					return;
				}

				if (entry.isIntersecting) {
					observer.disconnect();
					node.setAttribute('data-revealed', '');
					const total = (delay ?? 0) + TRANSITION_MS + (stagger ? STAGGER_CAP * STAGGER_STEP_MS : 0) + MARGIN_MS;
					timer = setTimeout(clear, total);
				}
			},
			{ rootMargin: '0px 0px -10% 0px', threshold: 0 }
		);

		observer.observe(node);

		return () => {
			observer.disconnect();
			clearTimeout(timer);
			clear();
		};
	};
}
