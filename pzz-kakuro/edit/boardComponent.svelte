<script lang="ts">
    export let blockInteraction:boolean = false;
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
        v: number,
        /*
            -2: block
            -1: border
            0: empty
            1-9: number
        */
        dt1: string,
        dt2: string,
        w: boolean, // confirmed wrong
        w1: boolean,
        w2: boolean
    }

    colNum = 5;
    rowNum = 5;

    let Val: boardData[][] = [[]];

    while (Val.length < rowNum) {
        let a: boardData[] = [];
        while (a.length < colNum) {
            a.push({v: -2, dt1: "", dt2: "", w: false, w1: false, w2: false});
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
                a.push({v: -2, dt1: "", dt2: "", w: false, w1: false, w2: false});
            }
            Val.push(a);
        }

        Val.forEach(e => {
            while (e.length > colNum) {
                e.pop();
            }

            while (e.length < colNum) {
                e.push({v: -2, dt1: "", dt2: "", w: false, w1: false, w2: false});
            }
        })

        for(let i = 0; i < colNum; i++) {
            checkSurroundingCell(rowNum - 1, i);
        }

        for(let i = 0; i < rowNum; i++) {
            checkSurroundingCell(i, colNum - 1);
        }

        forceRefresh();
    }

    function forceRefresh() {
        Val = Val;
    }

    function mainPanelClick(i: number, j: number) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }

        if (Val[i][j].v == 0) {
            Val[i][j].v = -2;
            Val[i][j].dt1 = "";
            Val[i][j].dt2 = "";
        } else  {
            Val[i][j].v = 0;
        }

        checkSurroundingCell(i, j);
        if (i > 0) {
            checkSurroundingCell(i - 1, j);
            if (j > 0) {
                checkSurroundingCell(i - 1, j - 1);
            }
            if (j < colNum - 1) {
                checkSurroundingCell(i - 1, j + 1);
            }
        }

        if (i < rowNum - 1) {
            checkSurroundingCell(i + 1, j);
            if (j > 0) {
                checkSurroundingCell(i + 1, j - 1);
            }
            if (j < colNum - 1) {
                checkSurroundingCell(i + 1, j + 1);
            }
        }

        if (j > 0) {
            checkSurroundingCell(i, j - 1);
        }
        if (j < colNum - 1) {
            checkSurroundingCell(i, j + 1);
        }
    }

    function checkSurroundingCell(i: number, j: number) { 
        if (Val[i][j].v == 0) {
            return;
        }

        if (i > 0) {
            if (Val[i - 1][j].v == 0) {
                Val[i][j].v = -1;
                return;
            }
        }
    
        if (i < rowNum - 1) {
            if (Val[i + 1][j].v == 0) {
                Val[i][j].v = -1;
                return;
            }
        }

        if (j > 0) {
            if (Val[i][j - 1].v == 0) {
                Val[i][j].v = -1;
                return;
            }
        }
    
        if (j < colNum - 1) {
            if (Val[i][j + 1].v == 0) {
                Val[i][j].v = -1;
                return;
            }
        }

        Val[i][j].v = -2;
    }

    function validateInput(i: number, j: number, upper: boolean) {
        if (upper) {
            let check = parseInt(Val[i][j].dt1);
            if (isNaN(check)) {
                Val[i][j].dt1 = "";
            }
            /*
            if (check > 45) {
                Val[i][j].dt1 = "";
            }
            */
        } else {
            let check = parseInt(Val[i][j].dt2);
            if (isNaN(check)) {
                Val[i][j].dt2 = "";
            } 
            /* 
            if (check > 45) {
                Val[i][j].dt2 = "";
            }
            */
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
                for (let j = 0; j < Val[i].length; j++) {
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
                        v: e2.v,
                        dt1: e2.dt1 ? e2.dt1 : "",
                        dt2: e2.dt2 ? e2.dt2 : "",
                        w: false,
                        w1: false,
                        w2: false
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
                    Val[i][j].v = -2;
                    Val[i][j].w = false;
                    Val[i][j].w1 = false;
                    Val[i][j].w2 = false;
                    Val[i][j].dt1 = "";
                    Val[i][j].dt2 = "";
                }
            }
        },
        getSavingData(): any {
            return (Val.map(e => {
                return e.map(e2 => {
                    let dt: any = {
                        v: 0,
                        dt1: undefined,
                        dt2: undefined
                    };

                    dt.v = e2.v;
                    if (dt.v == -1) {
                        if (e2.dt1 != "") {
                            dt.dt1 = e2.dt1
                        } else {
                            delete dt.dt1;
                        }
                        if (e2.dt2 != "") {
                            dt.dt2 = e2.dt2
                        } else {
                            delete dt.dt2;
                        }
                    } else {
                        delete dt.dt1;
                        delete dt.dt2;
                    }
                    return (dt);
                });
            }));
        },
        checkPuzzle(): boolean {
            const minVal: number[] = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45];
            const maxVal: number[] = [0, 9, 17, 24, 30, 35, 39, 42, 44, 45];

            let clear = true;

            for (let i = 0; i < Val.length; i++) {
                for (let j = 0; j < Val[i].length; j++) {
                    if (Val[i][j].v == -1) {
                        if ((Val[i][j].dt1 != "") && (isNaN(parseInt(Val[i][j].dt1)))) {
                            Val[i][j].w1 = true;
                            clear = false;
                        }
                        if ((Val[i][j].dt2 != "") && (isNaN(parseInt(Val[i][j].dt2)))) {
                            Val[i][j].w2 = true;
                            clear = false;
                        }
                        if (parseInt(Val[i][j].dt1) > 45) {
                            Val[i][j].w1 = true;
                            clear = false;
                        }
                        if (parseInt(Val[i][j].dt2) > 45) {
                            Val[i][j].w2 = true;
                            clear = false;
                        }              

                        let empty: number[] = [0, 0, 0, 0];
                        for(let x = i - 1; x > 0; x--) {
                            if (Val[x][j].v == 0) {empty[0]++;} else {break;}
                        }
                        if (empty[0] > 9) {
                            for(let x = i - 1; x > 0; x--) {
                                if (Val[x][j].v == 0) {Val[x][j].w = true;} else {break;}
                            }
                            clear = false;
                        }

                        for(let x = i + 1; x < rowNum; x++) {
                            if (Val[x][j].v == 0) {empty[2]++;} else {break;}
                        }
                        if (empty[2] > 9) {
                            for(let x = i + 1; x < rowNum; x++) {
                                if (Val[x][j].v == 0) {Val[x][j].w = true;} else {break;}
                            }
                            clear = false;
                        }

                        for(let y = j - 1; y > 0; y--) {
                            if (Val[i][y].v == 0) {empty[3]++;} else {break;}
                        }
                        if (empty[3] > 9) {
                            for(let y = j - 1; y > 0; y--) {
                                if (Val[i][y].v == 0) {Val[i][y].w = true;} else {break;}
                            }
                            clear = false;
                        }

                        for(let y = j + 1; y < colNum; y++) {
                            if (Val[i][y].v == 0) {empty[1]++;} else {break;}
                        }
                        if (empty[1] > 9) {
                            for(let y = j + 1; y < colNum; y++) {
                                if (Val[i][y].v == 0) {Val[i][y].w = true;} else {break;}
                            }
                            clear = false;
                        }

                        if (Val[i][j].dt1 != "") {
                            if (Math.max(empty[0], empty[1]) == 0) {
                                Val[i][j].dt1 = "";
                            } else if ((empty[0] <= 9) && (empty[1] <= 9)) {
                                const valNum = parseInt(Val[i][j].dt1);
                                if (empty[0] == 0) {
                                    if ((valNum < minVal[empty[1]]) || (valNum > maxVal[empty[1]])) {
                                        Val[i][j].w1 = true;
                                        clear = false;
                                    }
                                } else if (empty[1] == 0) {
                                    if ((valNum < minVal[empty[0]]) || (valNum > maxVal[empty[0]])) {
                                        Val[i][j].w1 = true;
                                        clear = false;
                                    }
                                } else if ((valNum < minVal[Math.min(empty[0], empty[1])]) || (valNum > maxVal[Math.max(empty[0], empty[1])])) {
                                    Val[i][j].w1 = true;
                                    clear = false;
                                }
                            }
                        }

                        if (Val[i][j].dt2 != "") {
                            if (Math.max(empty[2], empty[2]) == 0) {
                                Val[i][j].dt2 = "";
                            } else if ((empty[2] <= 9) && (empty[3] <= 9)) {
                                const valNum = parseInt(Val[i][j].dt2);
                                if (empty[2] == 0) {
                                    if ((valNum < minVal[empty[3]]) || (valNum > maxVal[empty[3]])) {
                                        Val[i][j].w2 = true;
                                        clear = false;
                                    }
                                } else if (empty[3] == 0) {
                                    if ((valNum < minVal[empty[2]]) || (valNum > maxVal[empty[2]])) {
                                        Val[i][j].w2 = true;
                                        clear = false;
                                    }
                                } else if ((valNum < minVal[Math.min(empty[2], empty[3])]) || (valNum > maxVal[Math.max(empty[2], empty[3])])) {
                                    Val[i][j].w2 = true;
                                    clear = false;
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
        class="kakuro"
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
        class="boardCell kakuro" class:border={e.v == -1} class:empty={e.v == 0} class:wrong={e.w && (e.v == 0)}
        on:dblclick ={() => mainPanelClick(i, j)}
      >
        {#if e.v == -1}
        <svg xmlns='http://www.w3.org/2000/svg' version='1.1' preserveAspectRatio='none' viewBox='0 0 10 10' style="position: absolute; height: {boardHeight/rowNum}px; width: {boardWidth/colNum}px;">
          <line x1='0' y1='0' x2='10' y2='10' style='stroke-width:0.1px'/>
        </svg>

        <div class="cir1" class:empty={!e.w1} class:wrong={e.w1}>
          <div
            class="borderInner"
            on:focusout={() => {validateInput(i, j, true)}}
            on:focusin={(e2) => {selectAllText(e2)}}
            contenteditable = "true"
            bind:innerHTML={e.dt1}
          >
          </div>              
        </div>
        <div class="cir2" class:empty={!e.w2} class:wrong={e.w2}>
          <div
            class="borderInner"
            on:focusout={() => {validateInput(i, j, true)}}
            on:focusin={(e2) => {selectAllText(e2)}}
            contenteditable = "true"
            bind:innerHTML={e.dt2}
          >
          </div>              
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

    .borderInner {
        background-color: transparent;
        color: inherit;
    }
  </style>