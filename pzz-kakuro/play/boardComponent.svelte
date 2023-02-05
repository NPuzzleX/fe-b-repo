<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    type boardData = {
      v: string,
      /*
        -2: block
        -1: border
        0: empty
        1-9: number
      */
      f:boolean,
      dt1: string,
      dt2: string,
      w: boolean, // confirmed wrong
      w1: boolean,
      w2: boolean
    }

    let Val: boardData[][] = [[]];

    function mainPanelClick(e: HTMLElement) {
      if (blockInteraction) {
        blockInteraction = false;
        return;
      }

      e.focus();
    }

    function validateInput(i: number, j: number) {
      let check = parseInt(Val[i][j].v);

      if (isNaN(check)) {
        Val[i][j].v = "";
      } else if (check > 9) {
        Val[i][j].v = "";
      } else if (check < 1) {
        Val[i][j].v = "";
      } else {
        Val[i][j].v = check.toString();
      }
      dispatch("SaveState");
    }

    function selectAllText(e: Event) {
      window.getSelection().selectAllChildren((e.target as Element))
    }

    function forceRefresh() {
      Val = Val;
    }

    export const boardController = {
        getColnum(): number {
            return Val.length;
        },
        getRownum(): number {
            return Val[0].length;
        },
        cleanWrong(): void {
          for (let i = 0; i < Val.length; i++) {
            for (let j = 0; j < Val.length; j++) {
              Val[i][j].w = false;
              Val[i][j].w1 = false;
              Val[i][j].w2 = false;
            }
          }
        },
        initializeData(dt: any): void {
            Val = dt.map(e => {
              return (e.map(e2 => {
                let a: boardData = {
                  v: (e2.v == 0) ? "" : e2.v,
                  f: (e2.v != 0),
                  w: false,
                  w1: false,
                  w2: false,
                  dt1: e2.dt1 ? e2.dt1 : "",
                  dt2: e2.dt2 ? e2.dt2 : ""
                }
                return (a);
              }))
            });
        },
        resetState(dt: any): void {
            Val = dt.map(e => {
              return (e.map(e2 => {
                let a: boardData = {
                  v: (e2.v == 0) ? "" : e2.v,
                  f: (e2.v != 0),
                  w: false,
                  w1: false,
                  w2: false,
                  dt1: e2.dt1 ? e2.dt1 : "",
                  dt2: e2.dt2 ? e2.dt2 : ""
                }
                return (a);
              }))
            });
        },
        loadData(dt: any): void {
          for (let i = 0; i < dt.length; i++) {
            for (let j = 0; j < dt[i].length; j++){
              Val[i][j].v = dt[i][j];
            }
          }
          forceRefresh();
        },
        doubleClickMouse(e: HTMLElement): void {
          mainPanelClick(e as HTMLElement);
        },
        getSavingData(): any {
            return (Val.map(e => {
              return (e.map(e2 => {
                return e2.v;
              }));
            }));
        },
        checkAnswer(): boolean {
            let clear = true;

            for (let i = 0; i < Val.length; i++) {
              for (let j = 0; j < Val[i].length; j++) {
                if (!Val[i][j].f) {
                  if ((Val[i][j].v == "0") || (Val[i][j].v == "")) {
                    Val[i][j].w = true;
                    clear = false;
                  }

                  for (let x = i - 1; x > 0; x--){
                    if (Val[x][j].f) {
                      break;
                    } else if (Val[x][j].v == Val[i][j].v) {
                      Val[i][j].w = true;
                      Val[x][j].w = true;
                      clear = false;
                    }
                  }

                  for (let x = i + 1; x < Val.length; x++){
                    if (Val[x][j].f) {
                      break;
                    } else if (Val[x][j].v == Val[i][j].v) {
                      Val[i][j].w = true;
                      Val[x][j].w = true;
                      clear = false;
                    }
                  }

                  for (let y = j - 1; y > 0; y--){
                    if (Val[i][y].f) {
                      break;
                    } else if (Val[i][y].v == Val[i][j].v) {
                      Val[i][j].w = true;
                      Val[i][y].w = true;
                      clear = false;
                    }
                  }

                  for (let y = j + 1; y < Val.length[i]; y++){
                    if (Val[i][y].f) {
                      break;
                    } else if (Val[i][y].v == Val[i][j].v) {
                      Val[i][j].w = true;
                      Val[i][y].w = true;
                      clear = false;
                    }
                  }

                } else if (Val[i][j].v == "-1") {
                  if (Val[i][j].dt1 != "") {
                    let vSum = 0;
                    let hSum = 0;
                    
                    for (let x = i - 1; x > 0; x--){
                      if (Val[x][j].f) {
                        break;
                      } else {
                        vSum += parseInt(Val[x][j].v);
                      }
                    }

                    for (let y = j + 1; y < Val[i].length; y++){
                      if (Val[i][y].f) {
                        break;
                      } else {
                        hSum += parseInt(Val[i][y].v);
                      }
                    }

                    if ((parseInt(Val[i][j].dt1) != vSum) && (parseInt(Val[i][j].dt1) != hSum)) {
                      Val[i][j].w1 = true;
                      clear = false;
                    }
                  }

                  if (Val[i][j].dt2 != "") {
                    let vSum = 0;
                    let hSum = 0;
                    
                    for (let x = i + 1; x < Val.length; x++){
                      if (Val[x][j].f) {
                        break;
                      } else {
                        vSum += parseInt(Val[x][j].v);
                      }
                    }
                    
                    for (let y = j - 1; y > 0; y--){
                      if (Val[i][y].f) {
                        break;
                      } else {
                        hSum += parseInt(Val[i][y].v);
                      }
                    }

                    if ((parseInt(Val[i][j].dt2) != vSum) && (parseInt(Val[i][j].dt2) != hSum)) {
                      Val[i][j].w2 = true;
                      clear = false;
                    }
                  }
                }
              }
            }

            return clear;
        },
        getCheckingData(): any {
            return (Val.map(e => {
              return (e.map(e2 => {
                return (e2.f && (e2.v == "-1")) ? ({ dt1: parseInt(e2.dt1), dt2: parseInt(e2.dt2) }) : ({ v: parseInt(e2.v)});
              }));
            }));
        }
    }
  </script>

    <div
        id="mainBoard"
        class="kakuro"
        style="
            display: grid;
            grid-template-columns: repeat({Val.length}, 1fr);
            grid-template-rows: repeat({Val[0].length}, 1fr);
            height: {boardHeight}px; width: {boardWidth}px; 
            font-size: inherit;
        "
    >
    {#each Val as box, j}
    {#each box as e, i}
      {#if e.f}
        <div id={i.toString()} 
          class="boardCell kakuro" class:border={e.v == "-1"} class:wrong={e.w && (e.v == "0")}
        >
        {#if e.v == "-1"}
          <svg xmlns='http://www.w3.org/2000/svg' version='1.1' preserveAspectRatio='none' viewBox='0 0 10 10' style="position: absolute; height: {boardHeight/Val[0].length}px; width: {boardWidth/Val.length}px;">
            <line x1='0' y1='0' x2='10' y2='10' style='stroke-width:0.1px'/>
          </svg>

          <div class="cir1" class:empty={!e.w1 && (e.dt1 != "")} class:wrong={e.w1}>
            <div
              class="borderInner"
            >{e.dt1}
            </div>              
          </div>
          <div class="cir2" class:empty={!e.w2 && (e.dt2 != "")} class:wrong={e.w2}>
            <div
              class="borderInner"
            >{e.dt2}
            </div>              
          </div>
        {/if}
      </div>
      {:else}
      <div id={i.toString()} 
        class="boardCell kakuro empty" class:wrong={e.w}
        on:focusout={() => {validateInput(j, i)}}
        on:focusin={(e2) => {selectAllText(e2)}}
        contenteditable = "true"
        bind:innerHTML={e.v}
      ></div>
      {/if}
    {/each}
    {/each}
    </div>
  
<style>
.boardCell {
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: inherit;
  border-width: 2px;
  border-style: solid;
}

.boardCell.kakuro {
    border-width: 1px;
    border-style: solid;
}

.boardCell.kakuro.border {
  display: unset;
  font-size: 0.45em;
}

.boardCell.kakuro.border div { 
  height: 50%;
  width: 50%;
  border-radius: 50%;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;
}

.boardCell.kakuro.border div.cir1 {
  position: relative;
  left: 46%;
  top: 4%;
} 

.boardCell.kakuro.border div.cir2 {
  position: relative;
  bottom: 4%;
  left: 4%;
}   
</style>