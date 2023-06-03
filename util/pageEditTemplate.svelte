<script lang="ts">
    import { onMount } from "svelte";
    import { postPuzzle, getPuzzle } from "./backend";
    import html2canvas from "html2canvas"
    import * as iconList from "./iconList";
    
    export let squarePuzzle: boolean;
    export let mainBoardComponent: any;
    export let hintString: string = "";

    let boardController: any;
    let mainDiv: HTMLDivElement;
    let hidden: boolean = false;
  
    let originalHeight = 1200;
    $: originalWidth = originalHeight*colNum/rowNum;

    let scaling = 1;
    let zoomFactor = 1;
  
    let cellFontSize = 12;
  
    $: {
      cellFontSize = (originalHeight > originalWidth ? (originalHeight * scaling/rowNum) : (originalWidth * scaling/colNum))/2;
    }
  
    let mainAreaHeight: number;
    let mainAreaWidth: number;
    let optionHeight: number;
    let fitPage:boolean = true;
    let optionHidden: boolean = false;
  
    $: isOverflowWidth = fitPage ? false : (!mainDiv ? false : (mainDiv.clientWidth < originalWidth*scaling));
    $: isOverflowheight = fitPage ? false : (!mainDiv ? false : (mainDiv.clientHeight < originalHeight*scaling));
  
    $: {
      if (fitPage) {
        if ((mainAreaWidth)/colNum > (mainAreaHeight - (optionHidden ? 0 : optionHeight))/rowNum) {
          zoomFactor = (mainAreaHeight - (optionHidden ? 0 : optionHeight))/mainAreaHeight;
          scaling = mainAreaHeight/originalHeight*zoomFactor;
        } else {
          zoomFactor = (mainAreaWidth)/mainAreaWidth;
          scaling = mainAreaWidth/originalWidth*zoomFactor;
        }
        cellFontSize = (originalHeight > originalWidth ? (originalHeight * scaling/rowNum) : (originalWidth * scaling/colNum))/2;
      } else {
        if (zoomFactor <= 0) {
          zoomFactor = 1;
        }
  
        if ((mainAreaWidth - 15)/colNum > (mainAreaHeight - 15)/rowNum) {
          scaling = mainAreaHeight/originalHeight*zoomFactor;
        } else {
          scaling = mainAreaWidth/originalWidth*zoomFactor;
        }
        cellFontSize = (originalHeight > originalWidth ? (originalHeight * scaling/rowNum) : (originalWidth * scaling/colNum))/2;
      }
    }

    let colNum: number = 5;
    let rowNum: number = 5;
    let sizeBox: number = 3;

    let isMouseDown:boolean = false;
    let isScrolled:boolean = false;
  
    function mouseMove(e: MouseEvent) {
      if (isMouseDown) {
        e.preventDefault();
  
        if (Math.abs(e.movementX) + Math.abs(e.movementY) > 2)  {
          mainDiv.scrollTop = mainDiv.scrollTop - e.movementY;
          mainDiv.scrollLeft = mainDiv.scrollLeft - e.movementX;
        }
      }
    }
  
    function mouseDown(e: MouseEvent) {
      isMouseDown = true;
    }
  
    function mouseUp() {
      if (isMouseDown) {
        isMouseDown = false;
      }
    }
  
    function mouseLeave () {
      if (isMouseDown) {
        isMouseDown = false;
      }
      isScrolled = false;
    }
  
    onMount(async () => {
      const target = document.getElementById("optionBoard");
  
      const observer = new MutationObserver(e => {
        if (e[0].attributeName == "style") {
          if (e[0].target.firstChild.parentElement.style.display == "none") {
            optionHidden = true;
          } else {
            optionHidden = false;
          }
        }
          })
  
        observer.observe(target, { attributeFilter: ["style"] });
  
      if (!sessionStorage.getItem("PuzzleId")) {
        return;
      }
  
      const tempData = await getPuzzle();
      if (!tempData) {
        console.log("INVALID PUZZLE_ID");
        window.postMessage("INVALID PUZZLE_ID", window.origin);
      }
  
      try {
        boardController.initializeData(tempData.data);
      } catch (error) {
        console.log("INVALID PUZZLE_ID");
        window.postMessage("INVALID PUZZLE_ID", window.origin);
      }
    });
  
    //------------- SAVING + THUMBNAIL GENERATOR -------------
    let thumbnailTarget: HTMLDivElement;
    const maxThumbnailSize: number = 400;
    let checking: boolean = false;
    
    async function check() {
      if (!checking) {
        checking = true;
  
        if (!boardController.checkPuzzle()) {
          setTimeout(() => {
            checking = false;
            boardController.cleanWrong();
          }, 2000);
        } else {

          await boardController.preparePrinting();
          
          let renderedWidth = maxThumbnailSize;
          let renderedHeight = renderedWidth*originalHeight/originalWidth;
  
          if (renderedHeight > maxThumbnailSize) {
            renderedHeight = maxThumbnailSize;
            renderedWidth = renderedHeight*originalWidth/originalHeight;
          }
  
          let cvs = await html2canvas(thumbnailTarget, {
            scale: renderedWidth/thumbnailTarget.clientWidth
          });
  
          if (await postPuzzle({
            game: boardController.getSavingData(),
            thumbnail: cvs.toDataURL("image/webp", 0.5),
            },
            hidden)) {
            console.log("UPLOADED NEW PUZZLE");
            window.postMessage("UPLOADED NEW PUZZLE", window.origin);
          }
        }
      }
    }
  </script>
  
  <div id="mainArea" bind:clientWidth={mainAreaWidth} bind:clientHeight={mainAreaHeight}>
    <div id="optionBoard" bind:clientHeight={optionHeight}>
      <div class="optionH">
        <div class="option">
          {#if squarePuzzle}
            <div class="icon">{@html iconList.sizeIco}</div>
            <input type=number style="width: 4em;" bind:value={sizeBox} min="1" max="100">
          {:else}
            <div class="icon">{@html iconList.colIco}</div>
            <input type=number style="width: 4em;" bind:value={colNum} min="1">
            <div class="icon">{@html iconList.rowIco}</div>
            <input type=number style="width: 4em;" bind:value={rowNum} min="1">
          {/if}
          <input type=checkbox bind:checked={hidden}>
          <div class="icon hiddenIcon">{@html iconList.hiddenIco}</div>Hidden
          <button on:click={() => {boardController.clearState();}} title="Clear"><div class="icon newIcon">{@html iconList.newIco}</div><p>Clear</p></button>
          <button on:click={check} title="Save"><div class="icon">{@html iconList.saveIco}</div><p>Upload</p></button>
        </div>
        <div class="option" style="padding-left: 5px; border-left: solid 3px black">
          <button on:click={() => {zoomFactor >= 2 ? zoomFactor-- : zoomFactor /= 2; fitPage = false;}} title="Zoom out"><div class="icon">{@html iconList.magMinIco}</div><p>Zoom Out</p></button>
          <input type=number on:input={() => {fitPage = false;}} style="width: 4em;" bind:value={zoomFactor} min="0">
          <button on:click={() => {zoomFactor >= 1 ? zoomFactor++ : zoomFactor *= 2; fitPage = false;}} title="Zoom in"><div class="icon">{@html iconList.magPlusIco}</div><p>Zoom In</p></button>
          <button on:click={() => {fitPage = true;}} title="Fit to page"><div class="icon">{@html iconList.maxIco}</div><p>Fit Page</p></button>
          <button on:click={() => {window.postMessage("TRIGGER FULLSCREEN", window.origin);}} title="Full Screen"><div class="icon">{@html iconList.enlargeIco}</div><p>Full Screen</p></button>
        </div>
      </div>
      {#if hintString != ""}
        <div class="option">
          <h3>{hintString}</h3>
        </div>        
      {/if}
    </div>    
    <div id="boardContainer" bind:this={mainDiv}
      on:scroll={() => {isScrolled = true;}}
      style="display: {isOverflowWidth ? "unset" : "flex"}; padding-left: { (isOverflowWidth ? 20 : 0)}px; padding-top: { (isOverflowheight ? 20 : 0)}px; overflow: {fitPage ? "hidden" : "scroll"};"
    >
      <div id="boardArea" bind:this={thumbnailTarget} style="height: {originalHeight*scaling + (isOverflowheight ? 20 : 0)}px; width: {originalWidth*scaling + (isOverflowWidth ? 20 : 0)}px;">
        <div id="mainBoard"
          style="z-index: 3; opacity: 1.0; height: {originalHeight*scaling}px; width: {originalWidth*scaling}px; font-size: {cellFontSize}px;"
          on:mousemove={mouseMove}
          on:mouseup={mouseUp}
          on:mousedown={mouseDown}
          on:mouseleave={mouseLeave}
        >
        <svelte:component
            this={mainBoardComponent}
            bind:boardController={boardController}
            bind:blockInteraction={isScrolled}
            bind:rowNum={rowNum}
            bind:colNum={colNum}
            bind:sizeBox={sizeBox}
            boardHeight={originalHeight*scaling - 10}
            boardWidth={originalWidth*scaling - 10}
        ></svelte:component>

        </div>
      </div>
    </div>
  </div>
  
  <style>
  #mainArea {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
  }
  
  #boardContainer {
    justify-content: center;
  }
  
  #mainBoard {
      position: absolute;
      top: 0px;
      left: 0px;
      display: grid;
      border-width: 5px;
      border-style: solid;
    }
  
  
  #boardArea {
    border-radius: 10px;
    position: relative;
    overflow: visible;
  }
  
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
  
  /* SVG CONTROL */
  button {
    display: flex;
    flex-direction: column;
    align-items: center;
    row-gap: 2px;
  }
  h3 {
    margin-top: 3px;
    font-weight: bold;
    color: red;
  }
  </style>