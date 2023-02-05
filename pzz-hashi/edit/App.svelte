<script lang="ts">
  import { onMount } from "svelte"
  import PageTemplate from "../../util/pageEditTemplate.svelte";
  const puzzleName = process.env.puzzleName ? process.env.puzzleName.charAt(0).toUpperCase() + process.env.puzzleName.substring(1) : "";
  let boardComponent;
  let loaded:boolean = false;

  onMount(async() => {
    boardComponent =  (await import('./boardComponent.svelte')).default;
    loaded = true;
  })

</script>

{#if loaded} 
<PageTemplate
  bind:mainBoardComponent={boardComponent}
  squarePuzzle={false}
></PageTemplate>
{/if}