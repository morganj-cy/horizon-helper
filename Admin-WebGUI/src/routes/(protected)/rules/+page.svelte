<script lang="ts">
    import type { PageProps } from "./$types";

    let { data }: PageProps = $props()
</script>

<h1>Rules</h1>

{#each data.json as rule (rule.id)}
    <h2>{rule.title}</h2>
    <p>{rule.description}</p>
    <p><b>Notes</b></p>
    <ul>
        {#each rule.additionalNotes as note (`${rule.id}-${note}`)}
            <li>{note}</li>
        {/each}
    </ul>
{/each}
