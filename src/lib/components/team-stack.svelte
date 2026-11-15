<script lang="ts">
	import { cn } from '$lib/utils';
	import * as Avatar from '$lib/components/ui/avatar';
	import * as HoverCard from '$lib/components/ui/hover-card';

	type Member = {
		name: string;
		avatar: string;
		username: string;
		followers: number;
		profileUrl: string;
	};

	// `members` is the GitHub data (avatar, name). `usernames` is the fallback for when that data is missing: the
	// same people as plain links, so the component still says who is on the team.
	let {
		members,
		usernames = [],
		class: className
	}: { members: Member[]; usernames?: string[]; class?: string } = $props();

	const initials = (name: string) =>
		name
			.split(/\s+/)
			.filter(Boolean)
			.slice(0, 2)
			.map((part) => part[0]?.toUpperCase())
			.join('');

	const count = $derived(members.length > 0 ? members.length : usernames.length);
	const countLabel = $derived(`${count} ${count === 1 ? 'person' : 'people'}`);

	const linkClass =
		'rounded-sm link-underline text-sm font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50';
</script>

{#if members.length > 0}
	<div class={cn('flex flex-wrap items-center gap-x-3 gap-y-2', className)}>
		<ul class="flex items-center -space-x-2">
			{#each members as member (member.username)}
				<li>
					<HoverCard.Root openDelay={150} closeDelay={80}>
						<HoverCard.Trigger>
							{#snippet child({ props })}
								<!-- bits-ui marks the trigger as a popup button; here it is a plain external link. -->
								<a
									{...props}
									href={member.profileUrl}
									target="_blank"
									rel="noopener noreferrer"
									role={undefined}
									aria-haspopup={undefined}
									aria-expanded={undefined}
									aria-label={`${member.name} on GitHub (opens in a new tab)`}
									class="block rounded-full outline-none focus-visible:z-10 focus-visible:ring-3 focus-visible:ring-ring/50"
								>
									<!-- The 2px ring in the background colour is a cut-out between overlapping avatars, not a border. -->
									<Avatar.Root class="size-7 ring-2 ring-background">
										<Avatar.Image src={member.avatar} alt="" width={28} height={28} loading="lazy" />
										<Avatar.Fallback class="text-[0.65rem] font-medium">{initials(member.name)}</Avatar.Fallback>
									</Avatar.Root>
								</a>
							{/snippet}
						</HoverCard.Trigger>

						<!-- The default zoom and 8px slide are replaced by a fade and a 4px rise over 180ms; none of it under reduced motion. -->
						<HoverCard.Content
							side="bottom"
							align="start"
							class="flex w-64 items-center gap-3 p-3 duration-180 ease-(--ease-out) motion-reduce:animate-none! data-open:zoom-in-100! data-[side=bottom]:data-open:slide-in-from-bottom-1 data-closed:zoom-out-100! data-[side=bottom]:data-closed:slide-out-to-bottom-1"
						>
							<Avatar.Root class="size-12 shrink-0">
								<Avatar.Image src={member.avatar} alt="" width={48} height={48} loading="lazy" />
								<Avatar.Fallback>{initials(member.name)}</Avatar.Fallback>
							</Avatar.Root>

							<div class="flex min-w-0 flex-col gap-1">
								<p class="truncate font-semibold">{member.name}</p>
								<p class="truncate text-sm text-muted-foreground">@{member.username}</p>
								<a href={member.profileUrl} target="_blank" rel="noopener noreferrer" class={cn('w-fit', linkClass)}>
									Profile ↗<span class="sr-only"> (opens in a new tab)</span>
								</a>
							</div>
						</HoverCard.Content>
					</HoverCard.Root>
				</li>
			{/each}
		</ul>

		<span class="label tabular-nums">{countLabel}</span>
	</div>
{:else if usernames.length > 0}
	<!-- Inline, so the count and the names fill each line instead of the whole list dropping under the count. -->
	<div class={cn('text-sm leading-5', className)}>
		<span class="mr-3 label tabular-nums">{countLabel}</span>
		<ul class="inline">
			{#each usernames as username (username)}
				<li class="mr-3 inline">
					<a
						href={`https://github.com/${username}`}
						target="_blank"
						rel="noopener noreferrer"
						class={cn('text-muted-foreground hover:text-foreground', linkClass)}
					>
						{username}<span class="sr-only"> (opens in a new tab)</span>
					</a><wbr />
				</li>
			{/each}
		</ul>
	</div>
{/if}
