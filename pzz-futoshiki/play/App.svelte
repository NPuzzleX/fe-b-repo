<script lang="ts">
  import { onMount } from "svelte";
  import { loadState, getPuzzle, postAnswer } from "../../util/backend";
  import ScribbleCanvas from "../../util/scribbleCanvas.svelte";
  import OptionBoard from "../../util/optionBoard.svelte";

  const puzzleName = process.env.puzzleName ? process.env.puzzleName.charAt(0).toUpperCase() + process.env.puzzleName.substring(1) : "";

  //------------- SCRIBBLE BOARD CONTROL -------------
  let SBController: any;
  let mainDiv: HTMLDivElement;

  let isMouseDown: boolean = false;
  let isScrolled:boolean = false;

  let pointSize: number = 2;

  let brushColour: string = '#000000';
  let writeMode: number = 2;
  /*
    0 : erase
    1 : write
    2 : move
  */

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

  let scribbleBoard: boolean = false;
  let originalBoard: any = undefined;

  function mouseMoveMain(e: MouseEvent) {
    if (isMouseDown) {
      e.preventDefault();

      if (Math.abs(e.movementX) + Math.abs(e.movementY) > 2)  {
        mainDiv.scrollTop = mainDiv.scrollTop - e.movementY;
        mainDiv.scrollLeft = mainDiv.scrollLeft - e.movementX;
      }
    }
  }

  function mouseDownMain(e: MouseEvent) {
    isMouseDown = true;
  }

  function mouseUpMain() {
    if (isMouseDown) {
      isMouseDown = false;
    }
  }

  function mouseLeaveMain () {
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
      console.log("INVALID PUZZLE_ID");
      window.postMessage("INVALID PUZZLE_ID", window.origin);
      return;
    }

    const tempData = await getPuzzle();
    if (!tempData) {
      console.log("INVALID PUZZLE_ID");
      window.postMessage("INVALID PUZZLE_ID", window.origin);
      return;
    }

    if (tempData.type != puzzleName) {
      console.log("INVALID PUZZLE_ID");
      window.postMessage("INVALID PUZZLE_ID", window.origin);
      return;
    }

    try {
      ptype = tempData.type;
      originalBoard = JSON.parse(JSON.stringify(tempData.data));
      Val = tempData.data.map((e: any[]) => {
        return (e.map(e2 => {
          let a: boardData = {
            v: e2.v,
            w: false,
            u: (e2.u != undefined) ? e2.u : undefined,
            l: (e2.l != undefined) ? e2.l : undefined,
            f: (e2.v != "")
          }
          return (a);
         }))
      });
    } catch (error) {
      console.log("INVALID PUZZLE_ID");
      window.postMessage("INVALID PUZZLE_ID", window.origin);
    }
    
    sizeBox = Val.length;

    SBController.setImageHW(originalHeight, originalWidth);
    load();
  });

  //------------- PLAY BOARD -------------
  type boardData = {
    v: string
    w: boolean // confirmed wrong
    u: undefined | boolean,
    l: undefined | boolean,
    f: boolean,
  }

  let sizeBox : number = 3;
  let colNum = sizeBox;
  let rowNum = sizeBox;

  $: {
    if (sizeBox < 2) {
      sizeBox = 2;
    } else if (Math.round(sizeBox) != sizeBox) {
      sizeBox = Math.round(sizeBox);
    }    

    colNum = sizeBox;
    rowNum = sizeBox;

    originalWidth = 1200;
    originalHeight = 1200;
  }

  let Val: boardData[][] = [];
  let ptype: string = "";

  function clickMouse(e: any) {
    const target = e.target as HTMLElement;
    if (target.firstChild) {
      if (target.firstChild.nodeName.toUpperCase() == "DIV") {
        (target.firstChild as HTMLElement).focus();
      }      
    }
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
    saveStorageState();
  }

  function selectAllText(e: Event) {
    window.getSelection().selectAllChildren((e.target as Element))
  }

  function forceRefresh() {
    Val = Val;
  }

  //------------- SAVE LOAD STATE -------------
  let processing: boolean = false;

  function load() {
    if (!processing) {
      processing = true;
      loadState().then((e) => {
        if (!e) {
          console.log("NO DATA");
          processing = false;
          saveStorageState();
          SBController.saveToStorage();
        } else {
          SBController.clearCanvas();
          var image = new Image();
          image.onload = function() {
            SBController.loadImage(image);
          };
          image.src = e["cvs"];
          
          for (let i = 0; i < e["game"].length; i++) {
            for (let j = 0; j < e["game"][i].length; j++){
              Val[i][j].v = e["game"][i][j];
            }
          }

          forceRefresh();

          saveStorageState();
          sessionStorage.setItem("TEMPSCRIBBLE", e["cvs"]);

          processing = false;       
        }
      }).catch(err => {
        console.log("ERROR LOADING" + err);
        processing = false;
      })
    }
  }

  function resetState() {
    if (scribbleBoard) {
      SBController.clearCanvas();
    }
    
    Val = originalBoard.map((e: any[]) => {
      return (e.map(e2 => {
          let a: boardData = {
            v: e2.v,
            w: false,
            u: (e2.u != undefined) ? e2.u : undefined,
            l: (e2.l != undefined) ? e2.l : undefined,
            f: (e2.v != ""),
          }
        return (a);
      }))
    });

    saveStorageState();
  }

  function saveStorageState() {
    sessionStorage.setItem("TEMPSTATE", JSON.stringify(Val.map(e => {
      return (e.map(e2 => {
        return e2.v;
      }));
    })));
    sessionStorage.setItem("save", "Y");
  }

  //------------- CHECK ANSWER -------------
  let checking: boolean = false;
  function checkAnswer() {
    if (!checking) {
      checking = true;
      let clear = true;

      for (let i = 0; i < Val.length; i++) {
        for (let j = 0; j < Val[i].length; j++) {
          if (Val[i][j].v == "") {
            Val[i][j].w = true;
            clear = false;
            continue;          
          } else {
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
        postAnswer(Val.map(e => {
          return (e.map(e2 => {
            return {
              v: parseInt(e2.v),
              u: e2.u,
              l: e2.l
            };
          }));
        }), ptype).then(e => {
          if (e.resStatus == 200) {
            if (e.res) {
              console.log("PUZZLE DONE!");
              window.postMessage("PUZZLE DONE!", window.origin);
            } else {
              console.log("BACKEND CHECKING ANSWER: WRONG");
              window.postMessage("BACKEND CHECKING ANSWER: WRONG", window.origin);
              checking = false;
            }
          } else {
            console.log("ERROR CHECKING ANSWER");
            window.postMessage("ERROR CHECKING ANSWER", window.origin);
            checking = false;
          }
        }).catch(err => {
          console.log("ERROR CHECKING ANSWER " + err);
          window.postMessage("ERROR CHECKING ANSWER", window.origin);
          checking = false;
        })
      }
    }
  }
</script>

<div id="mainArea" bind:clientWidth={mainAreaWidth} bind:clientHeight={mainAreaHeight}>
  <OptionBoard
    bind:pointSize={pointSize}
    bind:brushColour={brushColour}
    bind:writeMode={writeMode}
    bind:zoomFactor={zoomFactor}
    bind:fitPage={fitPage}
    bind:scribbleBoard={scribbleBoard}
    bind:optionHeight={optionHeight}
    hint="double click to edit number"
    on:CheckAnswer={checkAnswer}
    on:ClearCanvas={SBController.clearCanvas}
    on:Reset={resetState}
  ></OptionBoard>
  <div id="boardContainer" bind:this={mainDiv} 
    on:scroll={() => {isScrolled = true;}}
    style="display: {isOverflowWidth ? "unset" : "flex"}; padding-left: { (isOverflowWidth ? 20 : 0)}px; padding-top: { (isOverflowheight ? 20 : 0)}px; overflow: {fitPage ? "hidden" : "scroll"};"
  >
    <div id="boardArea" style="height: {originalHeight*scaling + (isOverflowheight ? 20 : 0)}px; width: {originalWidth*scaling + (isOverflowWidth ? 20 : 0)}px;">
      <ScribbleCanvas
        bind:show={scribbleBoard}
        bind:canvasControl={SBController} 
        bind:brushColour={brushColour}
        bind:writeMode={writeMode}
        bind:pointSize={pointSize}
        bind:scaling={scaling}
        mainDiv={mainDiv}
        doubleClickTarget="boardCell middle"
        on:doubleClickEv={(e) => {clickMouse(e.detail);}}
      ></ScribbleCanvas>
      <div id="mainBoard"
        style="z-index: 1; opacity: 1.0; grid-template-columns: repeat({colNum}, 1fr); grid-template-rows: repeat({rowNum}, 1fr);height: {originalHeight*scaling}px; width: {originalWidth*scaling}px; font-size: {cellFontSize}px;"
        on:mousemove={mouseMoveMain}
        on:mouseup={mouseUpMain}
        on:mousedown={mouseDownMain}
        on:mouseleave={mouseLeaveMain}
      >
      {#each Val as box, j}
        {#each box as e, i}
          <div id={i + " " + j} 
            class="boardCell back"
          >
            <div class="boardCell middle"
              class:fix={e.f}
              class:empty={!e.f}
              class:wrong={e.w}
              on:click={clickMouse}
            >
              {#if e.f}
                <div class="front"
                  contenteditable = "false"
                  bind:innerHTML={e.v}
                ></div>
              {:else}
                <div class="front"
                  on:focusout={() => {validateInput(j, i)}}
                  on:focusin={(e2) => {selectAllText(e2)}}
                  contenteditable = "true"
                  bind:innerHTML={e.v}
                ></div>
              {/if}
            </div>
            {#if j > 0}
              <div
                class="boardCell empty sign t"
              >
              {#if Val[j][i].u == undefined}
                <div class="signCircle"></div>
              {:else if Val[j][i].u}
                <div class="arrow">▲</div>
              {:else}
                <div class="arrow">▼</div>
              {/if}
              </div>
            {/if}
            {#if i > 0}
              <div
                class="boardCell empty sign l"
              >
              {#if Val[j][i].l == undefined}
                <div class="signCircle"></div>
              {:else if Val[j][i].l}
                <div class="arrow">◀</div>
              {:else}
                <div class="arrow">▶</div>
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

/*   MAIN PANEL   */
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
  aspect-ratio: 1;
}

.signCircle {
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

</style>