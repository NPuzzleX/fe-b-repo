<script lang="ts">
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    export let rowNum: number = 5;
    export let colNum: number = 5;

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
        v: string
        w: boolean // confirmed wrong
    }

    colNum = 5;
    rowNum = 5;

    let Val: boardData[][] = [[]];

    while (Val.length < rowNum) {
        let a: boardData[] = [];
        while (a.length < colNum) {
            a.push({v: "", w: false});
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
                a.push({v: "", w: false});
            }
            Val.push(a);
        }

        Val.forEach(e => {
            while (e.length > colNum) {
                e.pop();
            }

            while (e.length < colNum) {
                e.push({v: "", w: false});
            }
        })

        forceRefresh();
    }

    function forceRefresh() {
        Val = Val;
    }


    function validateInput(i: number, j: number) {
        let check = parseInt(Val[i][j].v);

        if (isNaN(check)) {
            Val[i][j].v = "";
        } else if (check > rowNum*colNum) {
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
            Val = dt.map((e: string[]) => {
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
                    Val[i][j].v = "";
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

            let sum: number = 0;
            Val.forEach(e => {
                e.forEach(e2 => {
                    if (e2.v == "") {
                        return;
                    }

                    let check = parseInt(e2.v);

                    if (isNaN(check)) {
                        clear = false;
                        e2.w = true;
                    } else if (check > rowNum*colNum) {
                        clear = false;
                        e2.w = true;
                    } else if (check < 1) {
                        clear = false;
                        e2.w = true;
                    } else {
                        sum += check;
                    }          
                })
            })

            if (sum > rowNum*colNum) {
                clear = false;
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
        class="boardCell" class:empty={!e.w} class:wrong={e.w}
        on:focusout={() => {validateInput(i, j)}}
        on:focusin={(e2) => {selectAllText(e2)}}
        contenteditable = "true"
        bind:innerHTML={e.v}
      ></div>
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