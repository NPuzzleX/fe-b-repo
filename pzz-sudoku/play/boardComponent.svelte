<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    type boardData = {
        v: string
        w: boolean // confirmed wrong
        f: boolean // fixed
    }
  
    let Val: boardData[][] = [[]];
    $: sizeBox = Math.round(Math.sqrt(Val.length));

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
        dispatch("SaveState");
    }

    function selectAllText(e: Event) {
        window.getSelection().selectAllChildren((e.target as Element))
    }
    
    function mainPanelClick(e: HTMLElement) {
        if (blockInteraction) {
            blockInteraction = false;
            return;
        }
        e.focus();
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
            Val = dt.map((e: string[]) => {
                return (e.map(e2 => {
                let a: boardData = {
                    v: e2,
                    w: false,
                    f: (e2 != "")
                }
                return (a);
                }))
            });
        },
        resetState(dt: any):void {
            Val = dt.map((e: string[]) => {
                return (e.map(e2 => {
                let a: boardData = {
                    v: e2,
                    w: false,
                    f: (e2 != "")
                }
                return (a);
                }))
            });
        },
        loadData(dt: any): void {
            Val = dt.map((e: string[]) => {
                return (e.map(e2 => {
                let a: boardData = {
                    v: e2,
                    w: false,
                    f: (e2 != "")
                }
                return (a);
                }))
            });
        },
        doubleClickMouse(e: HTMLElement): void {
            mainPanelClick(e);
        },
        getSavingData(): any {
            return (Val.map(e => {
                return (e.map(e2 => {
                    return e2.v;
                }))
            }));
        },
        checkAnswer(): boolean {
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
                    } else {
                        clear = false;
                        Val[i][j].w = true;
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
                    } else {
                        clear = false;
                        Val[i][j].w = true;
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
                    } else {
                        clear = false;
                        Val[i][j].w = true;
                    }
                }
            }

            return clear;
        },
        getCheckingData(): any {
            return (Val.map(e => {
                return (e.map(e2 => {
                    return parseInt(e2.v);
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
    {#each Val as box, j}
        {#each box as e, i}
            {#if e.f}
                <div id={i + " " + j} 
                    class="boardCell"
                    class:oddCell={!e.w && (((Math.floor(i/sizeBox) + Math.floor(j/sizeBox)) % 2) == 1)}
                    class:wrong={e.w}
                    class:fix={true}
                    class:bl={i % sizeBox == 0} class:br={(i + 1) % sizeBox == 0}
                    class:bt={j % sizeBox == 0} class:bb={(j + 1) % sizeBox == 0}
                >
                {e.v}
                </div>
            {:else}
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
                ></div>
            {/if}
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