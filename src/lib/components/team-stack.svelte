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

	let { members, class: className }: { members: Member[]; class?: string } = $props();

	const initials = (name: string) =>
		name
			.split(/\s+/)
			.filter(Boolean)
			.slice(0, 2)
			.map((part) => part[0]?.toUpperCase())
			.join('');

	const firstNames = $derived(members.map((m) => m.name.split(/\s+/)[0]).join(', '));
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
									aria-label={`${member.name} on GitHub`}
									class="block rounded-full outline-none focus-visible:z-10 focus-visible:ring-3 focus-visible:ring-ring/50"
								>
									<Avatar.Root class="size-8 ring-2 ring-background">
										<Avatar.Image src={member.avatar} alt="" width={32} height={32} loading="lazy" />
										<Avatar.Fallback class="text-[0.7rem] font-medium">{initials(member.name)}</Avatar.Fallback>
									</Avatar.Root>
								</a>
							{/snippet}
						</HoverCard.Trigger>

						<HoverCard.Content side="bottom" align="start" class="flex w-64 items-center gap-3 p-3">
							<Avatar.Root class="size-12 shrink-0">
								<Avatar.Image src={member.avatar} alt="" width={48} height={48} loading="lazy" />
								<Avatar.Fallback>{initials(member.name)}</Avatar.Fallback>
							</Avatar.Root>

							<div class="flex min-w-0 flex-col gap-1">
								<p class="truncate font-semibold">{member.name}</p>
								<p class="truncate font-mono text-[0.78rem] text-muted-foreground">@{member.username}</p>
								<p class="label tabular-nums">{member.followers} followers</p>
								<a
									href={member.profileUrl}
									target="_blank"
									rel="noopener noreferrer"
									class="w-fit rounded-sm link-underline text-sm font-medium outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
								>
									Profile ↗
								</a>
							</div>
						</HoverCard.Content>
					</HoverCard.Root>
				</li>
			{/each}
		</ul>

		{#if members.length <= 3}
			<span class="text-sm text-muted-foreground">{firstNames}</span>
		{/if}
	</div>
{/if}
