<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let blockInteraction:boolean = false;
    export let boardHeight: number = 0;
    export let boardWidth: number = 0;
    type boardData = {
      v: string,
      w: boolean // confirmed wrong
    }
    let Val: boardData[][] = [[]];

    function mainPanelClick(i: number, j : number, e:MouseEvent) {
      if (blockInteraction) {
        blockInteraction = false;
        return;
      }

      if (Val[i][j].v == "") {
        Val[i][j].v = "B";
      } else if (Val[i][j].v == "B") {
        Val[i][j].v = "";
      }

      dispatch("SaveState");
    }

    function arrayDoubletSearch(target: any, list: any[]) {
      for (let i = 0; i < list.length; i++) {
        if ((list[i][0] == target[0]) && (list[i][1] == target[1])) {
          return true;
        }
      }
      return false;
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
            for (let j = 0; j < Val[i].length; j++) {
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
        },
        resetState(dt: any): void {
            Val = dt.map((e: string[]) => {
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
            Val = dt.map((e: string[]) => {
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

            //---   WHITE ROOM CHECKS   ---
            for (let i = 0; i < Val.length; i++) {
              for (let j = 0; j < Val[i].length; j++) {
                let check = parseInt(Val[i][j].v)

                if (!isNaN(check)) {
                  if (Val[i][j].w) {
                    continue;
                  }

                  let testBox = [[i, j]];
                  let count = 0;
                  let err = false;

                  for (let k = 0; k < testBox.length; k++) {
                    const targetBox = testBox[k];

                    if (Val[targetBox[0]][targetBox[1]].v == "B") {
                      testBox.splice(k, 1);
                      k--;
                      continue;
                    } else {
                      if ((Val[targetBox[0]][targetBox[1]].v != "") && (targetBox[0] != i) && (targetBox[1] != j)) {
                        err = true;
                      }
                
                      count++;
                      if ((targetBox[0] > 0) && (!arrayDoubletSearch([targetBox[0] - 1, targetBox[1]], testBox))) {
                        testBox.push([targetBox[0] - 1, targetBox[1]]);
                      }
                      if ((targetBox[0] < Val.length - 1) && (!arrayDoubletSearch([targetBox[0] + 1, targetBox[1]], testBox))) {
                        testBox.push([targetBox[0] + 1, targetBox[1]]);
                      }
                      if ((targetBox[1] > 0) && (!arrayDoubletSearch([targetBox[0], targetBox[1] - 1], testBox))) {
                        testBox.push([targetBox[0], targetBox[1] - 1]);
                      }
                      if ((targetBox[1] < Val[0].length - 1) && (!arrayDoubletSearch([targetBox[0], targetBox[1] + 1], testBox))) {
                        testBox.push([targetBox[0], targetBox[1] + 1]);
                      }
                    }
                  }

                if (count != check) {
                  err = true;
                }

                if (err) {
                  clear = false;

                  testBox.forEach(e => {
                    Val[e[0]][e[1]].w = true;
                  })
                }
              }
            }
          }

          //---   CLUSTERING CHECKS   ---
          for (let i = 0; i < Val.length - 1; i++) {
            for (let j = 0; j < Val[i].length - 1; j++) {
              if (Val[i][j].v == "B") {
                if ((Val[i + 1][j].v == "B") && (Val[i][j + 1].v == "B") && (Val[i + 1][j + 1].v == "B")) {
                  Val[i][j].w = true;
                  Val[i + 1][j].w = true;
                  Val[i][j + 1].w = true;
                  Val[i + 1][j + 1].w = true;
                  clear = false;
                }
              }
            }
          }

          //---   WALL CONTINUITY CHECKS   ---
          let wallMap: boolean[][] = Val.map(e => {
            return e.map(e2 => {
              return e2.v != "B"
            })
          })
      
          for (let i = 0; i < wallMap.length; i++) {
            for (let j = 0; j < wallMap[i].length; j++) {
              if (!wallMap[i][j]) {

                let testBox = [[i, j]];

                for (let k = 0; k < testBox.length; k++) {
                  const targetBox = testBox[k];

                  if (wallMap[targetBox[0]][targetBox[1]]) {
                    continue;
                  } else {
                    wallMap[targetBox[0]][targetBox[1]] = true;
                    if ((targetBox[0] > 0) && (!arrayDoubletSearch([targetBox[0] - 1, targetBox[1]], testBox))) {
                      testBox.push([targetBox[0] - 1, targetBox[1]]);
                    }
                    if ((targetBox[0] < wallMap.length - 1) && (!arrayDoubletSearch([targetBox[0] + 1, targetBox[1]], testBox))) {
                      testBox.push([targetBox[0] + 1, targetBox[1]]);
                    }
                    if ((targetBox[1] > 0) && (!arrayDoubletSearch([targetBox[0], targetBox[1] - 1], testBox))) {
                      testBox.push([targetBox[0], targetBox[1] - 1]);
                    }
                    if ((targetBox[1] < wallMap[0].length - 1) && (!arrayDoubletSearch([targetBox[0], targetBox[1] + 1], testBox))) {
                      testBox.push([targetBox[0], targetBox[1] + 1]);
                    }
                  }
                }

                for (i = 0; i < wallMap.length; i++) {
                  for (j = 0; j < wallMap[i].length; j++) {
                    if (!wallMap[i][j]) {
                      for (i = 0; i < wallMap.length; i++) {
                        for (j = 0; j < wallMap[i].length; j++) {
                          if (Val[i][j].v == "B") {
                            Val[i][j].w = true;
                          }
                        }
                      }
                      break;
                    }
                  }
                }

                i = wallMap.length + 1;
                j = wallMap[0].length + 1;
                break;
              }
            }
          }
          return clear;
        },
        getCheckingData(): any {
            return (Val.map(e => {
              return (e.map(e2 => {
                return e2.v;
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
    {#each Val as box, i}
    {#each box as e, j}
      <div id={i.toString() + " " + j.toString()} 
        class="boardCell" class:empty={(e.v != "B")} class:wrong={e.w} 
        on:click={(e) => mainPanelClick(i, j, null)}
      >
        { (e.v != "B") ? e.v : "" }
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