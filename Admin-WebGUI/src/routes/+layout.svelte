<script lang="ts">
    import Sidebar from "#lib/components/Sidebar.svelte";
    import "../styles/global.scss"
    import favicon from '#lib/assets/favicon.svg';
    import type { LayoutProps } from './$types';

    let { children }: LayoutProps = $props();
</script>

<svelte:head>
    <link rel="icon" href={favicon} />
</svelte:head>

<div class="container">
    <div class="sidebarContainer">
        <Sidebar />
    </div>
    <main class="content">
        {@render children()}
    </main>
</div>

<style lang="scss">
    @use "sass:math";
    @use "sass:color";

    .container {
        display: grid;
        grid-template-columns: 1fr 5fr;
        grid-template-rows: 1fr;
        max-height: 100vh;
    }

    .content {
        margin: $content-margin;
        padding: $content-margin;
        border-radius: $radius-outer;
        background-color: rgba($white, 0.025);
        overflow: auto;
        min-height: calc(100vh - ($content-margin*2));

        border: 2px solid rgba($white, 0.25);
    }
</style>
