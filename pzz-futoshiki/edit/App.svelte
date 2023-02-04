<script lang="ts">
  import { onMount } from "svelte";
  import { postPuzzle, getPuzzle } from "../../util/backend";
  import html2canvas from "html2canvas"
  import * as iconList from "../../util/iconList";

  let mainDiv: HTMLDivElement;
  let hidden: boolean = false;

  let originalHeight = 1200;
  let originalWidth = 1200;
  let scaling = 1;
  let zoomFactor = 1;

  let cellFontSize = 12;

  $: {
    cellFontSize = (originalHeight > originalWidth ? (originalHeight * scaling/rowNum) : (originalWidth * scaling/colNum))*0.25;
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
      cellFontSize = (originalHeight > originalWidth ? (originalHeight * scaling/rowNum) : (originalWidth * scaling/colNum))*0.25;
    } else {
      if (zoomFactor <= 0) {
        zoomFactor = 1;
      }

      if ((mainAreaWidth - 15)/colNum > (mainAreaHeight - 15)/rowNum) {
        scaling = mainAreaHeight/originalHeight*zoomFactor;
      } else {
        scaling = mainAreaWidth/originalWidth*zoomFactor;
      }
      cellFontSize = (originalHeight > originalWidth ? (originalHeight * scaling/rowNum) : (originalWidth * scaling/colNum))*0.25;
    }
  }

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
      Val = tempData.data.map((e: any[]) => {
        return (e.map(e2 => {
          let a: boardData = {
            v: e2.v,
            w: false,
            u: (e2.u != undefined) ? e2.u : undefined,
            l: (e2.l != undefined) ? e2.l : undefined,
          }
          return (a);
        }))
      });
    } catch (error) {
      console.log("INVALID PUZZLE_ID");
      window.postMessage("INVALID PUZZLE_ID", window.origin);
    }
    
    colNum = Val.length;
    rowNum = Val[0].length;    
  });

  //------------- PLAY BOARD -------------
  type boardData = {
    v: string
    w: boolean // confirmed wrong
    u: undefined | boolean,
    l: undefined | boolean,
  }

  let sizeBox : number = 3;
  let colNum = sizeBox;
  let rowNum = sizeBox;

  let Val: boardData[][] = [];

  while (Val.length < rowNum) {
    let a: boardData[] = [];
    while (a.length < colNum) {
      a.push({v: "", w: false, u: undefined, l: undefined});
    }
    Val.push(a);
  }

  $: {
    if (sizeBox < 2) {
      sizeBox = 2;
    } else if (Math.round(sizeBox) != sizeBox) {
      sizeBox = Math.round(sizeBox);
    }    

    colNum = sizeBox;
    rowNum = sizeBox;

    changeSizeCheck();

    originalWidth = 3600/13*sizeBox;
    originalHeight = 3600/13*sizeBox;
  }

  function changeSizeCheck() {
    while (Val.length > rowNum) {
      Val.pop();
    }

    while (Val.length < rowNum) {
      let a: boardData[] = [];
      while (a.length < colNum) {
        a.push({v: "", w: false, u: undefined, l: undefined});
      }
      Val.push(a);
    }

    Val.forEach(e => {
      while (e.length > colNum) {
        e.pop();
      }

      while (e.length < colNum) {
        e.push({v: "", w: false, u: undefined, l: undefined});
      }
    })

    for (let i = 0; i < Val.length; i++) {
      for (let j = 0; j < Val[i].length; j++) {
        validateInput(i, j);
      }
    }
    forceRefresh();
  }

  function validateInput(i: number, j: number) {
    let check = parseInt(Val[i][j].v);

    if (isNaN(check)) {
      Val[i][j].v = "";
    } else if (check > sizeBox) {
      Val[i][j].v = "";
    } else if (check < 1) {
      Val[i][j].v = "";
    } else {
      Val[i][j].v = check.toString();
    }
  }

  function selectAllText(e: Event) {
    window.getSelection().selectAllChildren((e.target as Element))
  }


  function forceRefresh() {
    Val = Val;
  }

  function clearState() {
    for(let i = 0; i < Val.length; i++) {
      for(let j = 0; j < Val[i].length; j++) {
        Val[i][j].v = "";
        Val[i][j].w = false;
      }
    }
  }

  function panelClick(i: number, j:number, up: boolean) {
    if (up) {
      if (Val[i][j].u == undefined) {
        Val[i][j].u = true;
      } else if (Val[i][j].u) {
        Val[i][j].u = false;
      } else {
        Val[i][j].u = undefined;
      }
    } else {
      if (Val[i][j].l == undefined) {
        Val[i][j].l = true;
      } else if (Val[i][j].l) {
        Val[i][j].l = false;
      } else {
        Val[i][j].l = undefined;
      }
    }
  }

  function clickMouse(e: MouseEvent) {
    const target = e.target as HTMLElement;
    if (target.firstChild) {
      if (target.firstChild.nodeName.toUpperCase() == "DIV") {
        (target.firstChild as HTMLElement).focus();
      }      
    }
  }

  //------------- SAVING + THUMBNAIL GENERATOR -------------
  let thumbnailTarget: HTMLDivElement;
  const maxThumbnailSize: number = 400;
  let checking: boolean = false;
  let printMode: boolean = false;

  async function check() {
    if (!checking) {
      checking = true;
      let clear = true;

      for (let i = 0; i < Val.length; i++) {
        for (let j = 0; j < Val[i].length; j++) {
          if (Val[i][j].v != "") {
            let check = parseInt(Val[i][j].v);

            if (isNaN(check)) {
              Val[i][j].w = true;
            } else if (check > sizeBox) {
              Val[i][j].w = true;
            } else if (check < 1) {
              Val[i][j].w = true;
            } 

            if (Val[i][j].w) {
              clear = false;
              continue;
            }

            for (let x = 0; x < Val.length; x++) {
              if (x == i) {
                continue;
              }

              if (Val[i][j].v == Val[x][j].v) {
                Val[i][j].w = true;
                break;
              }
            }

            if (Val[i][j].w) {
              clear = false;
              continue;
            }

            for (let y = 0; y < Val[i].length; y++) {
              if (y == j) {
                continue;
              }

              if (Val[i][j].v == Val[i][y].v) {
                Val[i][j].w = true;
                break;
              }
            }

            if (Val[i][j].w) {
              clear = false;
              continue;
            }

            if (i > 0) {
              if (Val[i][j].u != undefined) {
                let check2 = parseInt(Val[i - 1][j].v);
                if (isNaN(check2)) {
                  continue;
                }                

                if (Val[i][j].u) {
                  if (check2 > check) {
                    Val[i][j].w = true;
                    Val[i - 1][j].w = true;
                  } 
                } else {
                  if (check2 < check) {
                    Val[i][j].w = true;
                    Val[i - 1][j].w = true;
                  } 
                }
              }
            }

            if (Val[i][j].w) {
              clear = false;
              continue;
            }

            if (j > 0) {
              if (Val[i][j].l != undefined) {
                let check2 = parseInt(Val[i][j - 1].v);
                if (isNaN(check2)) {
                  continue;
                }                

                if (Val[i][j].l) {
                  if (check2 > check) {
                    Val[i][j].w = true;
                    Val[i][j - 1].w = true;
                  } 
                } else {
                  if (check2 < check) {
                    Val[i][j].w = true;
                    Val[i][j - 1].w = true;
                  } 
                }
              }
            }

            if (Val[i][j].w) {
              clear = false;
              continue;
            }
          }
        }
      }

      if (!clear) {
        setTimeout(() => {
          checking = false;
          for (let i = 0; i < Val.length; i++) {
            for (let j = 0; j < Val.length; j++) {
              Val[i][j].w = false;
            }
          }
        }, 2000);
      } else {
        printMode = true;
        await new Promise(resolve => setTimeout(resolve, 1000));

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
          game: Val.map(e => {
            return e.map(e2 => {
              return {
                v: e2.v,
                u: e2.u,
                l: e2.l
              };
            });
          }),
          thumbnail: cvs.toDataURL("image/webp", 0.5),
          },
          hidden)) {
          console.log("UPLAODED NEW PUZZLE");
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
        <div class="icon">{@html iconList.sizeIco}</div>
        <input type=number style="width: 4em;" bind:value={sizeBox} min="2" max="25">
        <input type=checkbox bind:checked={hidden}>
        <div class="icon hiddenIcon">{@html iconList.hiddenIco}</div>Hidden
        <button on:click={clearState} title="Clear"><div class="icon newIcon">{@html iconList.newIco}</div><p>Clear</p></button>
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
  </div>  
  <div id="boardContainer" bind:this={mainDiv}
    on:scroll={() => {isScrolled = true;}}
    style="display: {isOverflowWidth ? "unset" : "flex"}; padding-left: { (isOverflowWidth ? 20 : 0)}px; padding-top: { (isOverflowheight ? 20 : 0)}px; overflow: {fitPage ? "hidden" : "scroll"};"
  >
    <div id="boardArea" bind:this={thumbnailTarget} style="height: {originalHeight*scaling + (isOverflowheight ? 20 : 0)}px; width: {originalWidth*scaling + (isOverflowWidth ? 20 : 0)}px;">
      <div id="mainBoard"
        style="z-index: 1; opacity: 1.0; grid-template-columns: repeat({colNum}, 1fr); grid-template-rows: repeat({rowNum}, 1fr); height: {originalHeight*scaling}px; width: {originalWidth*scaling}px; font-size: {cellFontSize}px;"
        on:mousemove={mouseMove}
        on:mouseup={mouseUp}
        on:mousedown={mouseDown}
        on:mouseleave={mouseLeave}
      >
      {#each Val as box, j}
        {#each box as e, i}
          <div id={i + " " + j} 
            class="boardCell back"
          >
            <div class="boardCell middle empty"
              class:wrong={e.w}
              on:click={clickMouse}
            >
              <div class="front"
                on:focusout={() => {validateInput(j, i)}}
                on:focusin={(e2) => {selectAllText(e2)}}
                contenteditable = "true"
                bind:innerHTML={e.v}
              ></div>
            </div>
            {#if j > 0}
              <div
                class="boardCell empty sign t"
              >
              {#if Val[j][i].u == undefined}
                <div class="signCircle" class:printing={printMode} on:click={() => {panelClick(j, i, true);}}></div>
              {:else if Val[j][i].u}
                <div class="arrow" on:click={() => {panelClick(j, i, true);}}>▲</div>
              {:else}
                <div class="arrow" on:click={() => {panelClick(j, i, true);}}>▼</div>
              {/if}
              </div>
            {/if}
            {#if i > 0}
              <div
                class="boardCell empty sign l"
              >
              {#if Val[j][i].l == undefined}
                <div class="signCircle" class:printing={printMode} on:click={() => {panelClick(j, i, false);}}></div>
              {:else if Val[j][i].l}
                <div class="arrow" on:click={() => {panelClick(j, i, false);}}>◀</div>
              {:else}
                <div class="arrow" on:click={() => {panelClick(j, i, false);}}>▶</div>
              {/if}
              </div>
            {/if}            
          </div>
        {/each}
      {/each}
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

.boardCell {
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: inherit;
  position: relative;
}

.boardCell.back {
  padding: 18%;
  background-color: transparent;
}

.boardCell.middle {
  cursor: pointer;
  height: 100%;
  width: 100%;
  border-width: 3px;
}

.front {
  cursor: pointer;
  color: inherit;
  background-color: inherit;
  border-color: inherit;
}

.arrow {
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;  
  padding-bottom: 7%;
  color: inherit;
}

.sign {
  position: absolute;
  padding: 2px;
  z-index: 1;
}

.sign div {
  cursor: pointer;
  aspect-ratio: 1;
}

.signCircle {
  background-color: transparent;
  border-radius: 50%;
  border-width: 3px;
  border-color: inherit;
  border-style: dotted;
}

.signCircle.printing {
  border-width: 0px;
}


.sign.l div {
  width: 100%;
}

.sign.t div {
  height: 100%;
}

.sign.t {
  width: 100%;
  height: 36%;
  left: 0%;
  top: -18%;
  background-color: transparent;
}

.sign.l {
  width: 36%;
  height: 100%;
  left: -18%;
  top: 0%;
  background-color: transparent;
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
</style>