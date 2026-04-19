import Root from './skeleton.svelte';
import type { HTMLAttributes } from 'svelte/elements';

type SkeletonProps = HTMLAttributes<HTMLDivElement>;

export { Root, Root as Skeleton, type SkeletonProps };
