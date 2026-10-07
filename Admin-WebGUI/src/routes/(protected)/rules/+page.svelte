<script lang="ts">
    import type { PageProps } from "./$types";

    let { data }: PageProps = $props()
    const { json } = data
</script>

<h1>Rules</h1>

{#each json as rule}
    <h2>{rule.title}</h2>
    <p>{rule.description}</p>
    <p><b>Notes</b></p>
    <ul>
        {#each rule.additionalNotes as note}
            <li>{note}</li>
        {/each}
    </ul>
{/each}
