<script lang="ts">
  import { onMount } from "svelte"
  import PageTemplate from "../../util/pagePlayTemplate.svelte";
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
  puzzleName={puzzleName}
  hintString="double click to put/remove line"
  doubleClickTarget="boardCell"
  bind:mainBoardComponent={boardComponent}
></PageTemplate>
{/if}