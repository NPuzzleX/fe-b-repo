<script lang="ts">
    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    export let rowNum: number = 5;
    export let colNum: number = 5;
    let printMode: boolean = false;

    $: {
        if (rowNum < 1) {
            rowNum = 1;
        } else if (Math.round(rowNum) != rowNum) {
            rowNum = Math.round(rowNum);
        }
    }

    $: {
        if (colNum < 1) {
            colNum = 1;
        } else if (Math.round(colNum) != colNum) {
            colNum = Math.round(colNum);
        }
    }

    type boardData = {
        v: number
        /*
            0: empty
            1-8: number
        */
        w: boolean // confirmed wrong
    }

    colNum = 5;
    rowNum = 5;
    

    let Val: boardData[][] = [[]];

    while (Val.length < rowNum) {
        let a: boardData[] = [];
        while (a.length < colNum) {
            a.push({v: 0, w: false});
        }
        Val.push(a);
    }

    $: {
        while (Val.length > rowNum) {
            Val.pop();
        }

        while (Val.length < rowNum) {
            let a: boardData[] = [];
            while (a.length < colNum) {
                a.push({v: 0, w: false});
            }
            Val.push(a);
        }

        Val.forEach(e => {
            while (e.length > colNum) {
                e.pop();
            }

            while (e.length < colNum) {
                e.push({v: 0, w: false});
            }
        })

        forceRefresh();
    }

    function forceRefresh() {
        Val = Val;
    }

    function mainPanelRightClick(i: number, j: number) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }

        if (Val[i][j].v == 8) {
            Val[i][j].v = 0;
        } else  {
            Val[i][j].v++;
        }
    }

    function mainPanelLeftClick(i: number, j: number) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }

        if (Val[i][j].v == 0) {
            Val[i][j].v = 8;
        } else  {
            Val[i][j].v--;
        }
    }

    export const boardController = {
        preparePrinting(): Promise<void> {
            printMode = true;
            return(new Promise(resolve => setTimeout(resolve, 1000)));
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
    
            colNum = Val.length;
            rowNum = Val[0].length;
        },
        clearState():void {
            for(let i = 0; i < Val.length; i++) {
                for(let j = 0; j < Val[i].length; j++) {
                    Val[i][j].v = 0;
                    Val[i][j].w = false;
                }
            }
        },
        getSavingData(): any {
            return (Val.map(e => {
                return e.map(e2 => {
                    return e2.v;
                });
            }));
        },
        checkPuzzle(): boolean {
            let clear = true;

            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v > 0) {
                        let openLine = 8;
                        /* Border Case Check */
                        if ((i == 0) || (i == rowNum - 1)) {
                            openLine -= 2;
                        }
                        if ((j == 0) || (j == colNum - 1)) {
                            openLine -= 2;
                        }
                        if (Val[i][j].v > openLine) {
                            Val[i][j].w = true;
                            clear = false;
                        }

                        /* Neighboring Check */
                        if (i > 0) {
                            if (Val[i - 1][j].v > 0){
                                Val[i][j].w = true;
                                clear = false;
                            }
                        }
                        if (j > 0) {
                            if (Val[i][j - 1].v > 0){
                                Val[i][j].w = true;
                                clear = false;
                            }
                        }
                        if (i < rowNum - 1) {
                            if (Val[i + 1][j].v > 0){
                                Val[i][j].w = true;
                                clear = false;
                            }
                        }
                        if (j < colNum - 1) {
                            if (Val[i][j + 1].v > 0){
                                Val[i][j].w = true;
                                clear = false;
                            }
                        }

                        /* Available Channels Check */
                        openLine = 0;
                        for (let x = i - 1; x >= 0; x--) {
                            if (Val[x][j].v == 1) {
                                openLine += 1;
                                break;
                            } else if (Val[x][j].v > 1) {
                                openLine += 2;
                                break;
                            }
                        }
                        for (let x = i + 1; x < rowNum; x++) {
                            if (Val[x][j].v == 1) {
                                openLine += 1;
                                break;
                            } else if (Val[x][j].v > 1) {
                                openLine += 2;
                                break;
                            }
                        }
                        for (let y = j - 1; y >= 0; y--) {
                            if (Val[i][y].v == 1) {
                                openLine += 1;
                                break;
                            } else if (Val[i][y].v > 1) {
                                openLine += 2;
                                break;
                            }
                        }
                        for (let y = j + 1; y < colNum; y++) {
                            if (Val[i][y].v == 1) {
                                openLine += 1;
                                break;
                            } else if (Val[i][y].v > 1) {
                                openLine += 2;
                                break;
                            }
                        }

                        if (openLine < Val[i][j].v) {
                            Val[i][j].w = true;
                            clear = false;
                        }
                    }
                }
            }

            return clear;
        }
    }
  </script>

    <div
        id="mainBoard"
        style="
            display: grid;
            grid-template-columns: repeat({colNum}, 1fr);
            grid-template-rows: repeat({rowNum}, 1fr);
            height: {boardHeight}px; width: {boardWidth}px; 
            font-size: inherit;
        "
    >
    {#each Val as box, i}
    {#each box as e, j}
      <div id={i.toString()} 
        class="boardCell empty" class:printing={printMode}
        on:contextmenu|preventDefault={() => mainPanelLeftClick(i, j)} 
        on:click={() => mainPanelRightClick(i, j)}
      >
        <div class="boardCell empty inner" style="border-width: {(e.v > 0) ? "2px" : "0px"};" class:wrong={e.w}>
          { (e.v > 0) ? e.v : "" }
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
        border-width: 2px;
        border-style: dashed;
    }

    .printing {
        border-style: none;
        border-width: 0px;
    }

    .inner {
        border-radius: 50%;
        border-style: solid;
        width: 100%;
        height: 100%;
    }
  </style>