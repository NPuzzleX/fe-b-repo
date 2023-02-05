<script lang="ts">
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    export let rowNum: number = 5;
    export let colNum: number = 5;
    export let sizeBox: number = 3;
    let printMode: boolean = false;

    type boardData = {
        v: string
        w: boolean // confirmed wrong
        u: undefined | boolean,
        l: undefined | boolean,
    }

    sizeBox = 3;

    let Val: boardData[][] = [[]];

    while (Val.length < rowNum) {
        let a: boardData[] = [];
        while (a.length < colNum) {
            a.push({v: "", w: false, u: undefined, l: undefined});
        }
        Val.push(a);
    }

    $: {
        if (sizeBox < 2) {
            sizeBox = 2;
        } else if (Math.round(sizeBox) != sizeBox) {
            sizeBox = Math.round(sizeBox);
        }    

        colNum = sizeBox;
        rowNum = sizeBox;

        changeSizeCheck();

    }

    function changeSizeCheck() {
        while (Val.length > rowNum) {
            Val.pop();
        }

        while (Val.length < rowNum) {
            let a: boardData[] = [];
            while (a.length < colNum) {
                a.push({v: "", w: false, u: undefined, l: undefined});
            }
            Val.push(a);
        }

        Val.forEach(e => {
            while (e.length > colNum) {
                e.pop();
            }

            while (e.length < colNum) {
                e.push({v: "", w: false, u: undefined, l: undefined});
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
        } else if (check > sizeBox) {
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

    function panelClick(i: number, j:number, up: boolean) {
        if (up) {
            if (Val[i][j].u == undefined) {
                Val[i][j].u = true;
            } else if (Val[i][j].u) {
                Val[i][j].u = false;
            } else {
                Val[i][j].u = undefined;
            }
        } else {
            if (Val[i][j].l == undefined) {
                Val[i][j].l = true;
            } else if (Val[i][j].l) {
                Val[i][j].l = false;
            } else {
                Val[i][j].l = undefined;
            }
        }
    }

    function clickMouse(e: MouseEvent) {
        const target = e.target as HTMLElement;
        if (target.firstChild) {
            if (target.firstChild.nodeName.toUpperCase() == "DIV") {
                (target.firstChild as HTMLElement).focus();
            }      
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
            Val = dt.map((e: any[]) => {
                return (e.map(e2 => {
                    let a: boardData = {
                        v: e2.v,
                        w: false,
                        u: (e2.u != undefined) ? e2.u : undefined,
                        l: (e2.l != undefined) ? e2.l : undefined,
                    }
                    return (a);
                }))
            });
    
            sizeBox = Val.length;
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
                    return {
                        v: e2.v,
                        u: e2.u,
                        l: e2.l
                    };
                });
            }));
        },
        checkPuzzle(): boolean {
            let clear = true;

            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v != "") {
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
            font-size: 50%;
        "
    >
    {#each Val as box, j}
    {#each box as e, i}
      <div id={i + " " + j} 
        class="boardCell back"
      >
        <div class="boardCell middle empty"
          class:wrong={e.w}
          on:click={clickMouse}
        >
          <div class="front"
            on:focusout={() => {validateInput(j, i)}}
            on:focusin={(e2) => {selectAllText(e2)}}
            contenteditable = "true"
            bind:innerHTML={e.v}
          ></div>
        </div>
        {#if j > 0}
          <div
            class="boardCell empty sign t"
          >
          {#if Val[j][i].u == undefined}
            <div class="signCircle" class:printing={printMode} on:click={() => {panelClick(j, i, true);}}></div>
          {:else if Val[j][i].u}
            <div class="arrow" on:click={() => {panelClick(j, i, true);}}>▲</div>
          {:else}
            <div class="arrow" on:click={() => {panelClick(j, i, true);}}>▼</div>
          {/if}
          </div>
        {/if}
        {#if i > 0}
          <div
            class="boardCell empty sign l"
          >
          {#if Val[j][i].l == undefined}
            <div class="signCircle" class:printing={printMode} on:click={() => {panelClick(j, i, false);}}></div>
          {:else if Val[j][i].l}
            <div class="arrow" on:click={() => {panelClick(j, i, false);}}>◀</div>
          {:else}
            <div class="arrow" on:click={() => {panelClick(j, i, false);}}>▶</div>
          {/if}
          </div>
        {/if}            
      </div>
    {/each}
    {/each}    
    </div>
  
  <style>
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
        cursor: pointer;
        aspect-ratio: 1;
    }

    .signCircle {
        background-color: transparent;
        border-radius: 50%;
        border-width: 3px;
        border-color: inherit;
        border-style: dotted;
    }

    .signCircle.printing {
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