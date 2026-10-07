<script lang="ts">
	import type { HomeIcon } from "svelte-feather-icons";

    interface Props {
        name: string;
        href: string;
        Icon:  typeof HomeIcon;
        active: boolean
    }
    const { name, href, Icon, active }: Props = $props()
</script>

<li class="navLinkContainer">
    <a {href} class:active class="navLink"><Icon size="20" />{name}</a>
</li>

<style lang="scss">
    .navLink {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 1rem;
        border-radius: 8px;
        text-decoration: none;
        color: $white;
        transition: transform 0.25s ease-out;

        &:hover, &:active {
            transform: translateX(10px);
        }
    }

    .active {
        color: $accent;
    }
</style>
