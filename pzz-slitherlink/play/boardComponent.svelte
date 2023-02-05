<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    type boardData = {
        v: number
        /*
        -1: empty
        0-3: number
        */
        w: boolean // confirmed wrong
    }  
    let Val: boardData[][] = [[]];
    let hBar: number[][] = [[]];
    let hBarw: boolean[][] = [[]];
    let vBar: number[][] = [[]];
    let vBarw: boolean[][] = [[]];

    function mainPanelClick(e: HTMLElement) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }
        e.focus();
    }

  function barEnter(i: number, j: number, horizontal: boolean) {
    if (horizontal) {
      if (hBar[i][j] != 1.0) {
        hBar[i][j] = 0.3;
      }
    } else {
      if (vBar[i][j] != 1.0) {
        vBar[i][j] = 0.3;
      }
    }
  }

  function barLeave(i: number, j: number, horizontal: boolean) {
    if (horizontal) {
      if (hBar[i][j] != 1.0) {
        hBar[i][j] = 0.0;
      }
    } else {
      if (vBar[i][j] != 1.0) {
        vBar[i][j] = 0.0;
      }
    }
  }

  function barClick(i: number, j: number, horizontal: boolean) {
    if (blockInteraction) {
      blockInteraction = false;
      return;
    }

    if (horizontal) {
      if (hBar[i][j] != 1.0) {
        hBar[i][j] = 1.0;
      } else {
        hBar[i][j] = 0.0;
      }
    } else {
      if (vBar[i][j] != 1.0) {
        vBar[i][j] = 1.0;
      } else {
        vBar[i][j] = 0.0;
      }
    }
    dispatch("SaveState");
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
          
            for (let i = 0; i < hBarw.length; i++) {
                for (let j = 0; j < hBarw[i].length; j++) {
                    hBarw[i][j] = false;
                }      
            }
          
            for (let i = 0; i < vBarw.length; i++) {
                for (let j = 0; j < vBarw[i].length; j++) {
                    vBarw[i][j] = false;
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

            const colNum = Val.length;
            const rowNum = Val[0].length;
            
            hBar = Array.from({length: rowNum + 1}, () => {
                return new Array(colNum).fill(0);
            });
            hBarw = Array.from({length: rowNum + 1}, () => {
                return new Array(colNum).fill(false);
            });
            vBar = Array.from({length: rowNum}, () => {
                return new Array(colNum + 1).fill(0);
            });
            vBarw = Array.from({length: rowNum}, () => {
                return new Array(colNum + 1).fill(false);
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

            for (let i = 0; i < hBar.length; i++) {
                for (let j = 0; j < hBar[i].length; j++) {
                    hBar[i][j] = 0;
                    hBarw[i][j] = false;
                }      
            }
            for (let i = 0; i < vBar.length; i++) {
                for (let j = 0; j < vBar[i].length; j++) {
                    vBar[i][j] = 0;
                    vBarw[i][j] = false;
                }      
            }
        },
        loadData(dt: any): void {
            Val = dt["b"].map((e: number[]) => {
                return (e.map(e2 => {
                    let a: boardData = {
                        v: e2,
                        w: false
                    }
                    return (a);
                }));
            });

            hBar = dt["h"];
            vBar = dt["v"];            
        },
        doubleClickMouse(e: HTMLElement): void {
            mainPanelClick(e);
            const id = e.id.split(" ");
        
            if (id.length == 3) {
                barClick(parseInt(id[0]), parseInt(id[1]), (id[2] == "h") ? true : false);
            }
        },
        getSavingData(): any {
            return ({
                b : Val.map(e => {
                    return (e.map(e2 => {
                        return e2.v;
                    }));
                }),
                v : vBar,
                h : hBar,
            });
        },
        checkAnswer(): boolean {
            let clear = true;
            const colNum = Val.length;
            const rowNum = Val[0].length;

            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v != -1) {
                        let bars = 0;
                        if (hBar[i][j]) {bars++};
                        if (hBar[i + 1][j]) {bars++};
                        if (vBar[i][j]) {bars++};
                        if (vBar[i][j + 1]) {bars++};
                        if (bars != Val[i][j].v) {
                            clear = false;
                            Val[i][j].w = true;
                        }
                    }
                }
            }

            for (let i = 0; i < hBar.length; i++) {
                for (let j = 0; j < hBar[i].length; j++) {
                    if (hBar[i][j] > 0.9) {
                        let connection = [0, 0];

                        if (i < rowNum) {
                            if (vBar[i][j + 1] > 0.9) {
                                connection[1]++;
                            }
                        }
                        if (j < colNum - 1) {
                            if (hBar[i][j + 1] > 0.9) {
                                connection[1]++;
                            }
                        }
                        if (i > 0) {
                            if (vBar[i - 1][j + 1] > 0.9) {
                                connection[1]++;
                            }
                        }

                        if (i < rowNum) {
                            if (vBar[i][j] > 0.9) {
                                connection[0]++;
                            }
                        }
                        if (j > 0) {
                            if (hBar[i][j - 1] > 0.9) {
                                connection[0]++;
                            }
                        }
                        if (i > 0) {
                            if (vBar[i - 1][j] > 0.9) {
                                connection[0]++;
                            }
                        }

                        if ((connection[0] != 1) || (connection[1] != 1)) {
                            hBarw[i][j] = true;
                            clear = false;
                        }
                    }
                }      
            }

            for (let i = 0; i < vBar.length; i++) {
                for (let j = 0; j < vBar[i].length; j++) {
                    if (vBar[i][j] > 0.9) {
                        let connection = [0, 0];

                        if (j < colNum) {
                            if (hBar[i + 1][j] > 0.9) {
                                connection[1]++;
                            }
                        }
                        if (i < rowNum - 1) {
                            if (vBar[i + 1][j] > 0.9) {
                                connection[1]++;
                            }
                        }
                        if (j > 0) {
                            if (hBar[i + 1][j - 1] > 0.9) {
                                connection[1]++;
                            }
                        }

                        if (j < rowNum) {
                            if (hBar[i][j] > 0.9) {
                                connection[0]++;
                            }
                        }
                        if (i > 0) {
                            if (vBar[i - 1][j] > 0.9) {
                                connection[0]++;
                            }
                        }
                        if (j > 0) {
                            if (hBar[i][j - 1] > 0.9) {
                                connection[0]++;
                            }
                        }

                        if ((connection[0] != 1) || (connection[1] != 1)) {
                            vBarw[i][j] = true;
                            clear = false;
                        }
                    }
                }      
            }
            return clear;
        },
        getCheckingData(): any {
            return ([Val.map(e => {
                return (e.map(e2 => {
                return e2.v;
                }));
            }),
            vBar,
            hBar
            ]);
        }
    }
  </script>

    <div
        id="mainBoard"
        style="
            display: grid;
            grid-template-columns: repeat({Val.length}, 1fr);
            grid-template-rows: repeat({Val[0].length}, 1fr);
            padding-left: calc({8/Val.length}% + 5px);
            padding-right: calc({8/Val.length}% + 5px);
            padding-top: calc({8/Val[0].length}% + 5px);
            padding-bottom: calc({8/Val[0].length}% + 5px); 
            height: {boardHeight}px; width: {boardWidth}px; 
            font-size: inherit;
        "
    >
    {#each Val as box, i}
    {#each box as e, j}
      <div
        class="boardCell empty" class:wrong={e.w}
      >
        <div class="front-mask">
          { (e.v >= 0) ? (e.v) : "" }
        </div>
        {#if i == 0}
          <div class="boardCell dot tr"></div>
          <div id={i.toString() + " " + j.toString() + " h"}
            class="boardCell bar t"
            style="opacity: {hBar[i][j]};"
            on:pointerenter={() => {barEnter(i, j, true);}}
            on:pointerleave={() => {barLeave(i, j, true);}}
            on:pointerdown={() => {barClick(i, j, true);}}
            >
            <div class="boardCell bar h" class:wrong={hBarw[i][j]}></div>
          </div>
        {/if}
        {#if j == 0}
          <div class="boardCell dot btl"></div>
          <div id={i.toString() + " " + j.toString() + " v"}
            class="boardCell bar l"
            style="opacity: {vBar[i][j]};"
            on:pointerenter={() => {barEnter(i, j, false);}}
            on:pointerleave={() => {barLeave(i, j, false);}}
            on:pointerdown={() => {barClick(i, j, false);}}
            >
            <div class="boardCell bar v" class:wrong={vBarw[i][j]}></div>
          </div>
        {/if}
        {#if (i == 0) && (j == 0)}
          <div class="boardCell dot tl"></div>
        {/if}
        <div class="boardCell dot btr"></div>
        <div id={i.toString() + " " + (j + 1).toString() + " v"}
          class="boardCell bar r"
          style="opacity: {vBar[i][j + 1]};"
          on:pointerenter={() => {barEnter(i, j + 1, false);}}
          on:pointerleave={() => {barLeave(i, j + 1, false);}}
          on:pointerdown={() => {barClick(i, j + 1, false);}}
          >
          <div class="boardCell bar v" class:wrong={vBarw[i][j + 1]}></div>
        </div>
        <div id={(i + 1).toString() + " " + j.toString() + " h"}
          class="boardCell bar b"
          style="opacity: {hBar[i + 1][j]};"
          on:pointerenter={() => {barEnter(i + 1, j, true);}}
          on:pointerleave={() => {barLeave(i + 1, j, true);}}
          on:pointerdown={() => {barClick(i + 1, j, true);}}
          >
          <div class="boardCell bar h" class:wrong={hBarw[i + 1][j]}></div>
        </div>
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
  position: relative;
}

.front-mask {
  color: inherit;
  background-color: inherit;
  pointer-events: none;
}

.dot {
  position: absolute;
  width: 16%;
  height: 16%;
  border-width: 0px;
  border-radius: 50%;
  z-index: 2;
}

.dot.tl {
  top: calc(-8% - 1px);
  left: calc(-8% - 1px);
}

.dot.tr {
  top: calc(-8% - 1px);
  right: calc(-8% - 1px);
}

.dot.btl {
  bottom: calc(-8% - 1px);
  left: calc(-8% - 1px);
}

.dot.btr {
  bottom: calc(-8% - 1px);
  right: calc(-8% - 1px);
}

.bar {
  position: absolute;
  z-index: 1;
}

.bar.v {
  width: 3px;
  height: 100%;
}

.bar.h {
  width: 100%;
  height: 3px;
}

.bar.t {
  width: 100%;
  height: 40%;
  left: 0%;
  top: calc(-20% - 1px);
  background-color: transparent;
}

.bar.b {
  width: 100%;
  height: 40%;
  left: 0%;
  bottom: calc(-20% - 1px);
  background-color: transparent;
}

.bar.l {
  width: 40%;
  height: 100%;
  left: calc(-20% - 1px);
  top: 0%;
  background-color: transparent;
}

.bar.r {
  width: 40%;
  height: 100%;
  right: calc(-20% - 1px);
  top: 0%;
  background-color: transparent;
}
</style>