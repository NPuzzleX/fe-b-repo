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
            -1: empty
            0-3: number
        */
        w: boolean // confirmed wrong
    }

    colNum = 5;
    rowNum = 5;

    let Val: boardData[][] = [[]];

    while (Val.length < rowNum) {
        let a: boardData[] = [];
        while (a.length < colNum) {
            a.push({v: -1, w: false});
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
                a.push({v: -1, w: false});
            }
            Val.push(a);
        }

        Val.forEach(e => {
            while (e.length > colNum) {
                e.pop();
            }

            while (e.length < colNum) {
                e.push({v: -1, w: false});
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

        if (Val[i][j].v == 3) {
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
            Val[i][j].v = 3;
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
                    Val[i][j].v = -1;
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
                        let blocked = 0;
                        let hCorner = false;
                        let vCorner = false;
                        let zeros = [false, false, false, false];

                        if (i == 0) {
                            vCorner = true;
                        } else if (Val[i - 1][j].v == 0) {
                            zeros[0] = true;
                            blocked++;
                        }

                        if (j == 0) {
                            hCorner = true;
                        } else if (Val[i][j - 1].v == 0) {
                            zeros[1] = true;
                            blocked++;
                        }

                        if (i == Val.length - 1) {
                            vCorner = true;
                        } else if (Val[i + 1][j].v == 0) {
                            zeros[2] = true;
                            blocked++;
                        }

                        if (j == Val[i].length - 1) {
                            hCorner = true;
                        } else if (Val[i][j + 1].v == 0) {
                            zeros[3] = true;
                            blocked++;
                        }
            
                        if (hCorner && vCorner && (zeros[0] || zeros[1] || zeros[2] || zeros[3])) {
                            blocked++;
                        }

                        if (hCorner && (zeros[0] || zeros[2])) {blocked++;}
                        if (vCorner && (zeros[1] || zeros[3])) {blocked++;}

                        if (4 - blocked < Val[i][j].v) {
                            clear = false;
                            Val[i][j].w = true;
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
        class="boardCell empty" class:wrong={e.w} class:printing={printMode}
        on:contextmenu|preventDefault={() => mainPanelLeftClick(i, j)} 
        on:click={() => mainPanelRightClick(i, j)}
      >
        <div class="front-mask">
          { (e.v >= 0) ? (e.v) : "" }
        </div>
        {#if i == 0}
          <div class="boardCell dot tr"></div>
        {/if}
        {#if j == 0}
          <div class="boardCell dot bl"></div>
        {/if}
        {#if (i == 0) && (j == 0)}
          <div class="boardCell dot tl"></div>
        {/if}
        <div class="boardCell dot br"></div>
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
        border-width: 1px;
        border-style: dashed;
    }

    .boardCell.printing {
        border-style: none;
        border-width: 0px;
    }

    .front-mask {
        color: inherit;
        background-color: inherit;
    }

    .dot {
        position: absolute;
        width: 16%;
        height: 16%;
        border-width: 0px;
        border-radius: 50%;
        z-index: 1;
    }

    .dot.tl {
        top: calc(-8% - 1px);
        left: calc(-8% - 1px);
    }

    .dot.tr {
        top: calc(-8% - 1px);
        right: calc(-8% - 1px);
    }

    .dot.bl {
        bottom: calc(-8% - 1px);
        left: calc(-8% - 1px);
    }

    .dot.br {
        bottom: calc(-8% - 1px);
        right: calc(-8% - 1px);
    }
  </style>