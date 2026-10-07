<script lang="ts">
   	import { page } from '$app/state';
	import SidebarLink from '#lib/components/SidebarLink.svelte';
	import { HomeIcon, BookOpenIcon, AlignLeftIcon, AlertTriangleIcon, InboxIcon, InfoIcon } from "svelte-feather-icons"

	const activeRoute = $derived(page.url.pathname.split("/").filter((x) => x)[0] ?? "")

    interface Page {
        name: string;
        href: string;
        Icon:  typeof HomeIcon;
    }

    const pages: Page[] = [
        { name: "Home", href: "/", Icon: HomeIcon },
        { name: "Rules", href: "/rules", Icon: BookOpenIcon },
        { name: "Definitions", href: "/definitions", Icon: AlignLeftIcon },
        { name: "Join Instructions", href: "/join-instructions", Icon: InfoIcon },
        { name: "CVs & CC2As", href: "/cvs-and-cc2as", Icon: InboxIcon },
        { name: "Reported Errors", href: "/errors", Icon: AlertTriangleIcon },
    ]
</script>

<aside class="sidebar">
    <div class="title">
        <h1>Test</h1>
    </div>
    <nav class="navbar">
        <ul class="navLinks">
            {#each pages as {name,href,Icon} (name)}
                <SidebarLink {name} {href} {Icon} active={href === `/${activeRoute}`} />
                {/each}
        </ul>
    </nav>
    <div class="logoutContainer">
        <button class="logoutButton">Log Out</button>
    </div>
</aside>

<style lang="scss">
    .sidebar {
        display: grid;
        grid-template-rows: min-content 1fr min-content;
        width: 100%;
        height: 100%;
        padding-block: $content-margin;
        padding-inline: $content-margin;
        align-items: center;
    }

    .navLinks {
        display: flex;
        flex-direction: column;
        list-style: none;
        grid-row: 2;
    }

    .logoutContainer {
        display: flex;
        justify-content: center;
        align-items: center;
        grid-row: 3;
    }

    .logoutButton {
        width: 100%;
    }
</style>
