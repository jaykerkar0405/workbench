<script lang="ts">
	import { cn } from '$lib/utils';
	import * as Avatar from '$lib/components/ui/avatar';

	type Member = {
		name: string;
		avatar: string;
		username: string;
		followers: number;
		profileUrl: string;
	};

	let {
		members,
		usernames = [],
		class: className
	}: { members: Member[]; usernames?: string[]; class?: string } = $props();

	const team = $derived.by(() => {
		const orderedUsernames = usernames.length ? usernames : members.map(({ username }) => username);

		return orderedUsernames.map((username) => {
			const member = members.find((member) => member.username === username);
			return {
				username,
				name: member?.name || username,
				href: member?.profileUrl || `https://github.com/${username}`,
				avatar: member?.avatar || `https://github.com/${username}.png?size=64`
			};
		});
	});

	const initials = (name: string) =>
		name
			.split(/\s+/)
			.filter(Boolean)
			.slice(0, 2)
			.map((part) => part[0]?.toUpperCase())
			.join('');
</script>

{#if team.length > 0}
	<ul class={cn('flex flex-wrap items-center gap-x-5 gap-y-2', className)}>
		{#each team as member (member.username)}
			<li class="flex max-w-full min-w-0">
				<a
					href={member.href}
					target="_blank"
					rel="noopener noreferrer"
					class="group/team inline-flex max-w-full items-center gap-2 rounded-sm font-sans text-sm font-medium text-foreground outline-none focus-visible:ring-3 focus-visible:ring-ring/50"
				>
					<Avatar.Root class="size-6" aria-hidden="true">
						<Avatar.Image src={member.avatar} alt="" width={24} height={24} loading="lazy" />
						<Avatar.Fallback class="text-[0.6rem] font-medium">{initials(member.name)}</Avatar.Fallback>
					</Avatar.Root>
					<span
						class="truncate link-underline group-hover/team:[background-size:100%_1px] group-focus-visible/team:[background-size:100%_1px] motion-reduce:transition-none"
						>{member.name}</span
					><span class="sr-only"> (opens in a new tab)</span>
				</a>
			</li>
		{/each}
	</ul>
{/if}
