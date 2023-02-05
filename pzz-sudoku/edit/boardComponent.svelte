<script lang="ts">
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    export let rowNum: number = 5;
    export let colNum: number = 5;
    export let sizeBox: number = 3;

    type boardData = {
        v: string
        w: boolean // confirmed wrong
    }

    sizeBox = 3;

    let Val: boardData[][] = [];

    while (Val.length < rowNum) {
        let a: boardData[] = [];
        while (a.length < colNum) {
            a.push({v: "", w: false});
        }
        Val.push(a);
    }

    $: {
        if (sizeBox > 10) {
            sizeBox = sizeBox % 10;
        }

        if (sizeBox < 3) {
            sizeBox = 3;
        } else if (sizeBox > 7) {
            sizeBox = 7;
        } else if (Math.round(sizeBox) != sizeBox) {
            sizeBox = Math.round(sizeBox);
        }    

        colNum = sizeBox*sizeBox;
        rowNum = sizeBox*sizeBox;

        changeSizeCheck();
    }

    function changeSizeCheck() {
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
        } else if (check > sizeBox*sizeBox) {
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
    
            sizeBox = Math.round(Math.sqrt(Val.length));
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

            // Vertical Checking
            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v != "") {
                        let nOccur : number = 0;
                        for (let k = 0; k < Val[i].length; k++) {
                            if (Val[i][j].v == Val[i][k].v) {
                                nOccur++;
                            }
                        }
                        if (nOccur > 1) {
                            clear = false;
                            for (let k = 0; k < Val[i].length; k++) {
                                if (Val[i][j].v == Val[i][k].v) {
                                    Val[i][k].w = true;
                                    nOccur--;
                                }
                                if (nOccur == 0) {
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            // Horizontal Checking
            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v != "") {
                        let nOccur : number = 0;
                        for (let k = 0; k < Val.length; k++) {
                            if (Val[i][j].v == Val[k][j].v) {
                                nOccur++;
                            }
                        }
                        if (nOccur > 1) {
                            clear = false;
                            for (let k = 0; k < Val.length; k++) {
                                if (Val[i][j].v == Val[k][j].v) {
                                    Val[k][j].w = true;
                                    nOccur--;
                                }
                                if (nOccur == 0) {
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            // Box checking
            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v != "") {
                        let nOccur : number = 0;
                        let xBox: number = Math.floor(i/sizeBox);
                        let yBox: number = Math.floor(j/sizeBox);

                        for (let k = 0; k < sizeBox; k++) {
                            for (let l = 0; l < sizeBox; l++) {
                                if (Val[i][j].v == Val[k + xBox*sizeBox][l + yBox*sizeBox].v) {
                                    nOccur++;
                                }
                            }
                        }

                        if (nOccur > 1) {
                            clear = false;
                            for (let k = 0; k < sizeBox; k++) {
                                for (let l = 0; l < sizeBox; l++) {
                                    if (Val[i][j].v == Val[k + xBox*sizeBox][l + yBox*sizeBox].v) {
                                        Val[k + xBox*sizeBox][l + yBox*sizeBox].w = true;
                                        nOccur--;
                                    }
                                    if (nOccur == 0) {
                                        break;
                                    }
                                }
                            }
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
    {#each Val as box, j}
    {#each box as e, i}
      <div id={i + " " + j} 
        class="boardCell empty"
        class:oddCell={!e.w && (((Math.floor(i/sizeBox) + Math.floor(j/sizeBox)) % 2) == 1)}
        class:wrong={e.w}
        class:bl={i % sizeBox == 0} class:br={(i + 1) % sizeBox == 0}
        class:bt={j % sizeBox == 0} class:bb={(j + 1) % sizeBox == 0}
        on:focusout={() => {validateInput(j, i)}}
        on:focusin={(e2) => {selectAllText(e2)}}
        contenteditable = "true"
        bind:innerHTML={e.v}
      >
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

    .bl {
        border-left-width: 5px;
        border-left-style: solid;
    }
  
    .br {
        border-right-width: 5px;
        border-right-style: solid;
    }
  
    .bt {
        border-top-width: 5px;
        border-top-style: solid;
    }
  
    .bb {
        border-bottom-width: 5px;
        border-bottom-style: solid;
    }
  </style>