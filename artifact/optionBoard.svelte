<script lang="ts">
    import * as iconList from "./iconList";
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    //------------- SCRIBBLE BOARD CONTROL -------------
    export let hint: string = "";
    export let pointSize: number = 2;
    export let brushColour: string = '#000000';
    export let writeMode: number = 2;
    /*
      0 : erase
      1 : write
      2 : move
    */
  
    export let zoomFactor = 1;
    export let scribbleBoard: boolean = false;
    export let fitPage:boolean = true;
    export let optionHeight: number;
        
    function eraserBtn() {
      writeMode = 0;
      pointSize *= 25;
    }
  
    function writeBtn(bColour: string) {
      if (bColour != "") {
        brushColour = bColour;
      }
      pointSize = 2;
      writeMode = 1;
    }
</script>

<div id="optionBoard" bind:clientHeight={optionHeight}>
    <div class="optionH">
      <div class="option" style="display: { scribbleBoard ? "flex" : "none" }; padding-right: 5px; border-right: solid 3px black">
        <div class="palette">
          <button style="background-color:#000000" on:click={() => {writeBtn("#000000");}}/>
          <button style="background-color:#d00404" on:click={() => {writeBtn("#d00404");}}/>
        </div>
        <div class="palette">
          <button style="background-color:#00bcc0" on:click={() => {writeBtn("#00bcc0");}}/>
          <button style="background-color:#32cd32" on:click={() => {writeBtn("#32cd32");}}/>
        </div>
        <button disabled={writeMode == 0} on:click={eraserBtn} title="Erase"><div class="icon">{@html iconList.eraserIco}</div><p>Eraser</p></button>
        <button disabled={writeMode == 2} on:click={() => {writeMode = 2}} title="Move" ><div class="icon">{@html iconList.arrowMoveIco}</div><p>Move</p></button>
        <button on:click={() => {{dispatch("ClearCanvas");}}} title="Clear"><div class="icon newIcon">{@html iconList.newIco}</div><p>Clear</p></button>
      </div>
      <div class="option">
        <div class="option" style="position: relative; top: -0.2em;">
          <input type=checkbox bind:checked={scribbleBoard}>
          <div style="flex-direction: column; display: flex; align-items: center">
            <div class="icon boardIcon" style="margin-bottom: 10px;">{@html iconList.boardIco}</div>
            <p>Scribble Board</p>
          </div>            
        </div>
        <button on:click={() => {dispatch("Reset")}} title="Reset"><div class="icon">{@html iconList.arrowRotateIco}</div><p>Reset</p></button>
        <button on:click={() => {dispatch("CheckAnswer");}} title="Check Answer"><div class="icon">{@html iconList.checkSolidIco}</div><p>Check</p></button>
      </div>
      <div class="option" style="padding-left: 5px; border-left: solid 3px black">
        <button on:click={() => {zoomFactor >= 2 ? zoomFactor-- : zoomFactor /= 2; fitPage = false;}} title="Zoom out"><div class="icon">{@html iconList.magMinIco}</div><p>Zoom Out</p></button>
        <input type=number on:input={() => {fitPage = false;}} style="width: 4em;" bind:value={zoomFactor} min="0">
        <button on:click={() => {zoomFactor >= 1 ? zoomFactor++ : zoomFactor *= 2; fitPage = false;}} title="Zoom in"><div class="icon">{@html iconList.magPlusIco}</div><p>Zoom In</p></button>
        <button on:click={() => {fitPage = true;}} title="Fit to page"><div class="icon">{@html iconList.maxIco}</div><p>Fit Page</p></button>
        <button on:click={() => {window.postMessage("TRIGGER FULLSCREEN", window.origin);}} title="Full Screen"><div class="icon">{@html iconList.enlargeIco}</div><p>Full Screen</p></button>
      </div>
    </div>
    {#if scribbleBoard}
      <div class="option">
        <h3>{hint}</h3>
      </div> 
    {/if}  
</div>

<style>
/*   MISC  */
#optionBoard {
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: sticky;
}

.optionH {
  display: flex;
  column-gap: 5px;
  align-items: baseline;
  justify-content: center;
}

.option {
  display: flex;
  column-gap: 5px;
  align-items: baseline;
  justify-content: center;
}

.option button {
  padding: 0.5em;
}

.option button[disabled] {
  cursor: not-allowed;
}

.palette {
    display: flex;
    flex-direction: column;
    justify-content: space-evenly;
    height: 100%;
  }

/* SVG CONTROL */
button {
  display: flex;
  flex-direction: column;
  align-items: center;
  row-gap: 2px;
}    
</style>