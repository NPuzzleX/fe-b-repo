<script lang="ts">
    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    export let rowNum: number = 5;
    export let colNum: number = 5;

    type boardData = {
        v: number
        /*
            -1: block
            0: empty
            1-4: number
        */
        w: boolean // confirmed wrong
    }

    let Val: boardData[][] = [[]];
    rowNum = 5;
    colNum = 5;
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

    function forceRefresh() {
        Val = Val;
    }

    function mainPanelRightClick(i: number, j: number) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }

        if (Val[i][j].v == 4) {
            Val[i][j].v = -1;
        } else  {
            Val[i][j].v++;
        }
    }

    function mainPanelLeftClick(i: number, j: number) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }

        if (Val[i][j].v == -1) {
            Val[i][j].v = 4;
        } else  {
            Val[i][j].v--;
        }
    }

    export const boardController = {
        preparePrinting(): Promise<void> {
            return(Promise.resolve());
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
                        let emptyBox: number = 0;
                        if (i > 0) {
                            if (Val[i - 1][j].v == 0) {
                                emptyBox++;
                            }
                        }
                        if (j > 0) {
                            if (Val[i][j - 1].v == 0) {
                                emptyBox++;
                            }
                        }
                        if (i + 1 < colNum) {
                            if (Val[i + 1][j].v == 0) {
                                emptyBox++;
                            }
                        }
                        if (j + 1 < rowNum) {
                            if (Val[i][j + 1].v == 0) {
                                emptyBox++;
                            }
                        }
                        if (emptyBox < Val[i][j].v) {
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
        class="boardCell" class:empty={e.v == 0} class:wrong={e.w}
        on:contextmenu|preventDefault={() => mainPanelLeftClick(i, j)} 
        on:click={() => mainPanelRightClick(i, j)}
      >
        { (e.v > 0) ? e.v : "" }
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
        border-style: solid;
    }
  </style>