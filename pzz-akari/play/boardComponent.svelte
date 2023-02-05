<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    type boardData = {
      v: number
      /*
        -2 : light
        -1: block
        0: empty
        1-4: number
      */
      w: boolean // confirmed wrong
    }
  
    let Val: boardData[][] = [[]];

    function mainPanelClick(i: number, j : number, e:MouseEvent) {
      if (blockInteraction) {
        blockInteraction = false;
        return;
      }
  
      if (Val[i][j].v == 0) {
        Val[i][j].v = -2;
      } else if (Val[i][j].v == -2) {
        Val[i][j].v = 0;
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
        },
        initializeData(dt: any): void {
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
        resetState(dt: any):void {
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
            mainPanelClick(Number(id[0]), Number(id[1]), null);
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
            const colNum = Val.length;
            const rowNum = Val[0].length;
  
            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v > 0) {
                        let lightBulb: number = 0;
                        if (i > 0) {
                            if (Val[i - 1][j].v == -2) {
                                lightBulb++;
                            }
                        }
                        
                        if (j > 0) {
                            if (Val[i][j - 1].v == -2) {
                                lightBulb++;
                            }
                        }
                        if (i + 1 < colNum) {
                            if (Val[i + 1][j].v == -2) {
                                lightBulb++;
                            }
                        }
                        if (j + 1 < rowNum) {
                            if (Val[i][j + 1].v == -2) {
                                lightBulb++;
                            }
                        }
                        if (lightBulb != Val[i][j].v) {
                            Val[i][j].w = true;
                            clear = false;
                        }
                    }
                }
            }

            let tempBoard: boolean[][] = [];
            while (tempBoard.length < rowNum) {
                let a: boolean[] = [];
                while (a.length < colNum) {
                    a.push(false);
                }
                tempBoard.push(a);
            }

            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v == -2) {
                        tempBoard[i][j] = true;
                        for (let x = i - 1; x >= 0; x--){
                            if (Val[x][j].v == -2) {
                                clear = false;
                                Val[i][j].w = true;
                                Val[x][j].w = true;
                            } else if (Val[x][j].v == 0) {
                                tempBoard[x][j] = true;
                            } else {
                                break;
                            }
                        }

                        for (let x = i + 1; x < rowNum; x++){
                            if (Val[x][j].v == -2) {
                                clear = false;
                                Val[i][j].w = true;
                                Val[x][j].w = true;
                            } else if (Val[x][j].v == 0) {
                                tempBoard[x][j] = true;
                            } else {
                                break;
                            }
                        }

                        for (let y = j - 1; y >= 0; y--){
                            if (Val[i][y].v == -2) {
                                clear = false;
                                Val[i][j].w = true;
                                Val[i][y].w = true;
                            } else if (Val[i][y].v == 0) {
                                tempBoard[i][y] = true;
                            } else {
                                break;
                            }
                        }

                        for (let y = j + 1; y < colNum; y++){
                            if (Val[i][y].v == -2) {
                                clear = false;
                                Val[i][j].w = true;
                                Val[i][y].w = true;
                            } else if (Val[i][y].v == 0) {
                                tempBoard[i][y] = true;
                            } else {
                                break;
                            }
                        }
                    } else if (Val[i][j].v != 0) {
                        tempBoard[i][j] = true;
                    }
                }          
            }

            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (!tempBoard[i][j]) {
                        Val[i][j].w = true;
                        clear = false;
                    }
                }
            }

            return clear;
        },
        getCheckingData(): any {
            return (Val.map(e => {
                return (e.map(e2 => {
                    return e2.v;
                }))
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
                class="boardCell" class:empty={(e.v == 0) || (e.v == -2)} class:wrong={e.w} 
                on:click={(e) => mainPanelClick(i, j, null)}
            >
                { (e.v == -2) ? "O" : ((e.v > 0) ? e.v : "") }
            </div>
        {/each}
    {/each}
    </div>
  
  <style>
    /*   MAIN PANEL   */
    .boardCell {
      cursor: pointer;
      display: flex;
      justify-content: center;
      align-items: center;
      font-size: inherit;
      border-width: 2px;
      border-style: solid;
    }
  
  </style>