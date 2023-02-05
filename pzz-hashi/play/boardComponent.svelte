<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    type boardData = {
      v: number
      /*
        -1: vertical single
        -2: vertical double
        -3: horizontal single
        -4: horizontal double
        0: empty
        1-8: number
      */
      w: boolean // confirmed wrong
    }

    let Val: boardData[][] = [[]];
    let selectedI: number = -1;
    let selectedJ: number = -1;

    function mainPanelClick(i: number, j : number, e:MouseEvent) {
      if (blockInteraction) {
        blockInteraction = false;
        return;
      }

      const colNum = Val.length;
      const rowNum = Val[0].length;

      if (Val[i][j].v > 0) {
        if ((selectedI == -1) && (selectedJ == -1)) {
          selectedI = i;
          selectedJ = j;
        } else if ((selectedI == i) && (selectedJ == j)) {
          selectedI = -1;
          selectedJ = -1;
        } else if ((selectedI == i) || (selectedJ == j)) {
          if (selectedI == i) {
            /*--- Horizontal ---*/
            if (j > selectedJ) {
              let check = true;
              for (let y = j - 1; y > selectedJ; y--) {
                if ((Val[i][y].v != 0) && (Val[i][y].v > -3)) {
                  check = false;
                  break;
                }
              }
              if (check) {
                for (let y = j - 1; y > selectedJ; y--) {
                  switch (Val[i][y].v) {
                    case 0: Val[i][y].v = -3; break;
                    case -3: Val[i][y].v = -4; break;
                    case -4: Val[i][y].v = 0; break;
                  }
                }
              }
            } else if (j < selectedJ) {
              let check = true;
              for (let y = j + 1; y < selectedJ; y++) {
                if ((Val[i][y].v != 0) && (Val[i][y].v > -3)) {
                  check = false;
                  break;
                }
              }
              if (check) {
                for (let y = j + 1; y < selectedJ; y++) {
                  switch (Val[i][y].v) {
                    case 0: Val[i][y].v = -3; break;
                    case -3: Val[i][y].v = -4; break;
                    case -4: Val[i][y].v = 0; break;
                  }
                }
              }
            }
          } else if (selectedJ == j) {
            /*--- Vertical ---*/
            if (i > selectedI) {
              let check = true;
              for (let x = i - 1; x > selectedI; x--) {
                if ((Val[x][j].v > 0) || (Val[x][j].v < -2)) {
                  check = false;
                  break;
                }
              }
              if (check) {
                for (let x = i - 1; x > selectedI; x--) {
                  switch (Val[x][j].v) {
                    case 0: Val[x][j].v = -1; break;
                    case -1: Val[x][j].v = -2; break;
                    case -2: Val[x][j].v = 0; break;
                  }
                }
              }
            } else if (i < selectedI) {
              let check = true;
              for (let x = i + 1; x < selectedI; x++) {
                if ((Val[x][j].v > 0) || (Val[x][j].v < -2)) {
                  check = false;
                  break;
                }
              }
              if (check) {
                for (let x = i + 1; x < selectedI; x++) {
                  switch (Val[x][j].v) {
                    case 0: Val[x][j].v = -1; break;
                    case -1: Val[x][j].v = -2; break;
                    case -2: Val[x][j].v = 0; break;
                  }
                }
              }
            }
          }
          dispatch("SaveState");
          selectedI = -1;
          selectedJ = -1;
        } else {
          selectedI = -1;
          selectedJ = -1;
        }    
      } else if (Val[i][j].v < 0) {
        if (Val[i][j].v == -1) {
          Val[i][j].v = -2;
          for (let x = i - 1; x >= 0; x--) {
            if (Val[x][j].v == -1) {
              Val[x][j].v = -2;
            } else {
              break;
            }        
          }
          for (let x = i + 1; x < rowNum; x++) {
            if (Val[x][j].v == -1) {
              Val[x][j].v = -2;
            } else {
              break;
            }        
          }
        } else if (Val[i][j].v == -2) {
          Val[i][j].v = 0;
          for (let x = i - 1; x >= 0; x--) {
            if (Val[x][j].v == -2) {
              Val[x][j].v = 0;
            } else {
              break;
            }        
          }
          for (let x = i + 1; x < rowNum; x++) {
            if (Val[x][j].v == -2) {
              Val[x][j].v = 0;
            } else {
              break;
            }        
          }      
        } else if (Val[i][j].v == -3) {
          Val[i][j].v = -4;
          for (let y = j - 1; y >= 0; y--) {
            if (Val[i][y].v == -3) {
              Val[i][y].v = -4;
            } else {
              break;
            }        
          }
          for (let y = j + 1; y < colNum; y++) {
            if (Val[i][y].v == -3) {
              Val[i][y].v = -4;
            } else {
              break;
            }        
          }      
        } else if (Val[i][j].v == -4) {
          Val[i][j].v = 0;
          for (let y = j - 1; y >= 0; y--) {
            if (Val[i][y].v == -4) {
              Val[i][y].v = 0;
            } else {
              break;
            }        
          }
          for (let y = j + 1; y < colNum; y++) {
            if (Val[i][y].v == -4) {
              Val[i][y].v = 0;
            } else {
              break;
            }        
          }
        }
        selectedI = -1;
        selectedJ = -1;
        dispatch("SaveState");
      } else {
        selectedI = -1;
        selectedJ = -1;
      }
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
            }
          }
        },
        initializeData(dt: any): void {
            Val = dt.map((e: number[]) => {
              return (e.map(e2 => {
                let a: boardData = {
                  v: e2,
                  w: false
                }
                return (a);
              }))
            });
        },
        resetState(dt: any): void {
            Val = dt.map((e: number[]) => {
              return (e.map(e2 => {
                let a: boardData = {
                  v: e2,
                  w: false
                }
                return (a);
              }));
            });
        },
        loadData(dt: any): void {
          Val = dt.map((e: number[]) => {
            return (e.map(e2 => {
              let a: boardData = {
                v: e2,
                w: false
              }
              return (a);
            }));
          });
        },
        doubleClickMouse(e: HTMLElement): void {
          const id = e.id.split(" ");
          if (id.length == 2) {
            mainPanelClick(Number(id[0]), Number(id[1]), null);
          }        
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

            for(let i = 0; i < Val.length; i++){
              for(let j = 0; j < Val[i].length; j++){
                if (Val[i][j].v > 0) {
                  /*--- CIRCLE CONNECTION CHECK ---*/
                  let connectedLines = 0;
                  if (j > 0) {
                    if (Val[i][j - 1].v == -3) {
                      connectedLines += 1;
                    } else if (Val[i][j - 1].v == -4) {
                      connectedLines += 2;
                    }
                  }
                  if (j < Val[i].length - 1) {
                    if (Val[i][j + 1].v == -3) {
                      connectedLines += 1;
                    } else if (Val[i][j + 1].v == -4) {
                      connectedLines += 2;
                    }
                  }
                  if (i > 0) {
                    if (Val[i - 1][j].v == -1) {
                      connectedLines += 1;
                    } else if (Val[i - 1][j].v == -2) {
                      connectedLines += 2;
                    }
                  }
                  if (i < Val.length - 1) {
                    if (Val[i + 1][j].v == -1) {
                      connectedLines += 1;
                    } else if (Val[i + 1][j].v == -2) {
                      connectedLines += 2;
                    }
                  }

                  if (connectedLines != Val[i][j].v) {
                    clear = false;
                    Val[i][j].w = true;
                  }
                } else if (Val[i][j].v < 0) {
                  /*--- LINE CONNECTION CHECK ---*/
                  if (Val[i][j].w) {
                    continue;
                  }
                  const ftx = Val[i][j].v;
                  if (ftx > -3) {
                    /* Vertical Checking */
                    let check = true;
                    for (let x = i - 1; x >= -1; x--) {
                      if (x == -1) {
                        check = false;
                      } else if (Val[x][j].v > 0) {
                        break;
                      } else if (Val[x][j].v != ftx) {
                        check = false;
                        break;
                      }
                    }
                    for (let x = i + 1; x <= Val.length; x++) {
                      if (x == Val.length) {
                        check = false;
                      } else if (Val[x][j].v > 0) {
                        break;
                      } else if (Val[x][j].v != ftx) {
                        check = false;
                        break;
                      }
                    }

                    if (!check) {
                      Val[i][j].w = true;
                      for (let x = i - 1; x >= 0; x--) {
                        if (Val[x][j].v != ftx) {
                          break;
                        } else {
                          Val[x][j].w = true;
                        }
                      }
                      for (let x = i + 1; x < Val.length; x++) {
                        if (Val[x][j].v != ftx) {
                          break;
                        } else {
                          Val[x][j].w = true;
                        }
                      }

                      clear = false;
                    }
                  } else {
                    /* Horizontal Checking */
                    let check = true;
                    for (let y = j - 1; y >= -1; y--) {
                      if (y == -1) {
                        check = false;
                      } else if (Val[i][y].v > 0) {
                        break;
                      } else if (Val[i][y].v != ftx){
                        check = false;
                        break;
                      }
                    }
                    for (let y = j + 1; y <= Val[i].length; y++) {
                      if (y == Val[i].length) {
                        check = false;
                      } else if (Val[i][y].v > 0) {
                        break;
                      } else if (Val[i][y].v != ftx) {
                        check = false;
                        break;
                      }
                    }

                    if (!check) {
                      Val[i][j].w = true;
                      for (let y = j - 1; y >= 0; y--) {
                        if (Val[i][y].v != ftx) {
                          break;
                        } else {
                          Val[i][y].w = true;
                        }
                      }
                      for (let y = j + 1; y < Val[i].length; y++) {
                        if (Val[i][y].v != ftx) {
                          break;
                        } else {
                          Val[i][y].w = true;
                        }
                      }

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
                return e2.v;
              }));
            }));
        }
    }
  </script>

    <div
        id="mainBoard"
        style="
            display: grid;
            grid-template-columns: repeat({Val.length}, 1fr);
            grid-template-rows: repeat({Val[0].length}, 1fr);
            height: {boardHeight}px; width: {boardWidth}px; 
            font-size: inherit;
        "
    >
    {#each Val as box, i}
    {#each box as e, j}
      <div id={i.toString() + " " + j.toString()} 
        class="boardCell empty" style="background-color: transparent;"
        on:click={(e) => mainPanelClick(i, j, null)}
      >
        <svg xmlns='http://www.w3.org/2000/svg' version='1.1' preserveAspectRatio='none' viewBox='0 0 10 10' 
          class:main={!e.w} class:wrong={e.w}
          style="position: absolute; height: {boardHeight/Val[0].length}px; width: {boardWidth/Val.length}px; z-index: 2; pointer-events: none;"
        >
          {#if e.v == -1}
            <line x1='5' y1='0' x2='5' y2='10' style='stroke-width:10%'/>
          {:else if e.v == -2}
            <line x1='3' y1='0' x2='3' y2='10' style='stroke-width:10%'/>
            <line x1='7' y1='0' x2='7' y2='10' style='stroke-width:10%'/>
          {:else if e.v == -3}
            <line x1='0' y1='5' x2='10' y2='5' style='stroke-width:10%'/>
          {:else if e.v == -4}
            <line x1='0' y1='3' x2='10' y2='3' style='stroke-width:10%'/>
            <line x1='0' y1='7' x2='10' y2='7' style='stroke-width:10%'/>
          {:else if e.v > 0}
            {#if i > 0}
              {#if Val[i -1][j].v == -1}
                <line x1='5' y1='0' x2='5' y2='4' style='stroke-width:10%'/>
              {:else if Val[i -1][j].v == -2}
                <line x1='3' y1='0' x2='3' y2='4' style='stroke-width:10%'/>
                <line x1='7' y1='0' x2='7' y2='4' style='stroke-width:10%'/>
              {/if}
            {/if}
            {#if i < Val[0].length - 1}
              {#if Val[i + 1][j].v == -1}
                <line x1='5' y1='6' x2='5' y2='10' style='stroke-width:10%'/>
              {:else if Val[i + 1][j].v == -2}
                <line x1='3' y1='6' x2='3' y2='10' style='stroke-width:10%'/>
                <line x1='7' y1='6' x2='7' y2='10' style='stroke-width:10%'/>
              {/if}
            {/if}
            {#if j > 0}
              {#if Val[i][j - 1].v == -3}
                <line x1='0' y1='5' x2='4' y2='5' style='stroke-width:10%'/>
              {:else if Val[i][j - 1].v == -4}
                <line x1='0' y1='3' x2='4' y2='3' style='stroke-width:10%'/>
                <line x1='0' y1='7' x2='4' y2='7' style='stroke-width:10%'/>
              {/if}
            {/if}
            {#if j < Val.length - 1}
              {#if Val[i][j + 1].v == -3}
                <line x1='6' y1='5' x2='10' y2='5' style='stroke-width:10%'/>
              {:else if Val[i][j + 1].v == -4}
                <line x1='6' y1='3' x2='10' y2='3' style='stroke-width:10%'/>
                <line x1='6' y1='7' x2='10' y2='7' style='stroke-width:10%'/>
              {/if}
            {/if}
          {/if}
        </svg>
        {#if e.v > 0}
          <div class="boardCell inner {(selectedI == i) && (selectedJ == j) ? "selected" : "empty"}" class:wrong={e.w}
            style="border-width: {(e.v > 0) ? "2px" : "0px"}; z-index: 3;" 
          >{e.v}
          </div> 
        {/if}
      </div>
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
    border-width: 0px;
    border-style: none;
}

.inner {
  border-radius: 50%;
  border-style: solid;
  width: 100%;
  height: 100%;
}
</style>