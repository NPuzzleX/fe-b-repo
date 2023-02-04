<script lang="ts">
    import { onMount } from "svelte";
  	import { createEventDispatcher } from 'svelte';
    
    export const canvasControl = {
      clearCanvas(): void {
        ctx.clearRect(0, 0, originalHeight, originalWidth);
        saveStorageScribble();
      },

      loadImage(img : HTMLImageElement): void {
        ctx.drawImage(img, 0, 0);
      },

      saveToStorage(): void {
        saveStorageScribble();
      },

      setImageHW(height: number, width: number): void {
        originalHeight = height;
        originalWidth = width;
        CV.height = originalHeight;
        CV.width = originalWidth;
      }
    }

    //------------- SCRIBBLE BOARD CONTROL -------------  
    export let pointSize: number = 2;
    $: intervalSize = Math.floor(pointSize*1.3);

    export let mainDiv: HTMLDivElement;
    export let brushColour: string = '#000000';
    export let scaling = 1;
    export let writeMode: number = 2;
    export let show: boolean = false;    
    /*
      0 : erase
      1 : write
      2 : move
    */

	  const dispatch = createEventDispatcher();
    export let doubleClickTarget: string = "";

    $: cursorType = (writeMode == 0) ? "" : ((writeMode == 1) ? "" : "grab")
  
    let CV: HTMLCanvasElement
    let ctx: CanvasRenderingContext2D
  
    let isMouseDown: boolean = false;
    let isScrolled:boolean = false;
    let posX: number = 0;
    let posY: number = 0;

    let originalHeight = 1200;
    let originalWidth = 1200;
    
    let isPenDown: boolean = false;
    let ongoingTouches = [];
  
    function mouseMove(e: MouseEvent) {
      if (isMouseDown) {
        e.preventDefault();
        const newX = (e.clientX - CV.getBoundingClientRect().left)/scaling;
        const newY = (e.clientY - CV.getBoundingClientRect().top)/scaling;
  
        if (writeMode == 0) {
          if ((posX > 0) && (posY > 0)) {
            const dotCount = Math.floor(Math.sqrt(Math.pow(newX - posX, 2) + Math.pow(newY - posY, 2))/intervalSize);
            if (dotCount > 0) {
              const xInterval = (newX - posX)/dotCount;
              const yInterval = (newY - posY)/dotCount;
              for (let i = 0; i < dotCount; i++) {
                ctx.clearRect(posX + xInterval*i - pointSize*0.5, posY + yInterval*i - pointSize*0.5, pointSize, pointSize);
              }
            }
          }
  
          posX = newX;
          posY = newY;
          ctx.clearRect(posX - pointSize*0.5, posY - pointSize*0.5, pointSize, pointSize);
        } else if (writeMode == 1) {
          if ((posX > 0) && (posY > 0)) {
            const dotCount = Math.floor(Math.sqrt(Math.pow(newX - posX, 2) + Math.pow(newY - posY, 2))/intervalSize);
            if (dotCount > 0) {
              const xInterval = (newX - posX)/dotCount;
              const yInterval = (newY - posY)/dotCount;
              for (let i = 0; i < dotCount; i++) {
                drawDot(posX + xInterval*i, posY + yInterval*i);
              }
            }
          }
  
          posX = newX;
          posY = newY;
          drawDot(posX, posY);
        } else if (writeMode == 2) {
          mainDiv.scrollTop = mainDiv.scrollTop - e.movementY;
          mainDiv.scrollLeft = mainDiv.scrollLeft - e.movementX;
        }
      }
    }
  
    function mouseDown(e: MouseEvent) {
      isMouseDown = true;
      posX = (e.clientX - CV.getBoundingClientRect().left)/scaling;
      posY = (e.clientY - CV.getBoundingClientRect().top)/scaling;
    }
  
    function mouseUp() {
      if (isMouseDown) {
        isMouseDown = false;
        saveStorageScribble();
        posX = -1;
        posY = -1;
      }
    }
  
    function mouseLeave () {
      if (isMouseDown) {
        isMouseDown = false;
        saveStorageScribble();
        posX = -1;
        posY = -1;
      }
      isScrolled = false;
    }
  
    function pointerDown(e: PointerEvent) {
      if (e.pointerType == "pen") {
        isPenDown = true;
      }
    }
  
    function touchStart (e: TouchEvent) {
      if ((writeMode != 2) || (isPenDown)) {
        const touches = e.changedTouches;
  
        for (let i = 0; i < touches.length; i++) {
          ongoingTouches.push(copyTouch(touches[i]));
        }      
      }
    }
  
    function touchMove(e: TouchEvent) {
      if ((writeMode != 2) || (isPenDown)) {
        e.preventDefault();
        const touches = e.changedTouches;
  
        for (let i = 0; i < touches.length; i++) {
          const idx = ongoingTouchIndexById(touches[i].identifier);
  
          if (idx >= 0) {
            const newX = (touches[i].clientX - CV.getBoundingClientRect().left)/scaling;
            const newY = (touches[i].clientY - CV.getBoundingClientRect().top)/scaling;
  
            if (writeMode == 0) {
              if ((ongoingTouches[idx].x > 0) && (ongoingTouches[idx].y > 0)) {
                const dotCount = Math.floor(Math.sqrt(Math.pow(newX - ongoingTouches[idx].x, 2) + Math.pow(newY - ongoingTouches[idx].y, 2))/intervalSize);
                if (dotCount > 0) {
                  const xInterval = (newX - ongoingTouches[idx].x)/dotCount;
                  const yInterval = (newY - ongoingTouches[idx].y)/dotCount;
                  for (let i = 0; i < dotCount; i++) {
                    ctx.clearRect(ongoingTouches[idx].x + xInterval*i - pointSize*0.5, ongoingTouches[idx].y + yInterval*i - pointSize*0.5, pointSize, pointSize);
                  }
                }
              }
  
              ctx.clearRect(ongoingTouches[idx].x - pointSize*0.5, ongoingTouches[idx].y - pointSize*0.5, pointSize, pointSize);
            } else {
              if ((ongoingTouches[idx].x > 0) && (ongoingTouches[idx].y > 0)) {
                const dotCount = Math.floor(Math.sqrt(Math.pow(newX - ongoingTouches[idx].x, 2) + Math.pow(newY - ongoingTouches[idx].y, 2))/intervalSize);
                if (dotCount > 0) {
                  const xInterval = (newX - ongoingTouches[idx].x)/dotCount;
                  const yInterval = (newY - ongoingTouches[idx].y)/dotCount;
                  for (let i = 0; i < dotCount; i++) {
                    drawDot(ongoingTouches[idx].x + xInterval*i, ongoingTouches[idx].y + yInterval*i);
                  }
                }
              }
  
              drawDot(ongoingTouches[idx].x, ongoingTouches[idx].y);
            }
  
            ongoingTouches.splice(idx, 1, copyTouch(touches[i])); 
          }
        }
      }    
    }
  
    function touchEnd(e: TouchEvent) {
      if ((writeMode != 2) || (isPenDown)) {
        
        ongoingTouches.splice(0, ongoingTouches.length);
  
        if (isPenDown) {
          isPenDown = false;
        }
      }
    }
  
    function touchCancel(e: TouchEvent) {
      if ((writeMode != 2) || (isPenDown)) {
        e.preventDefault();
        ongoingTouches.splice(0, ongoingTouches.length);
  
        if (isPenDown) {
          isPenDown = false;
        }
  
        saveStorageScribble();
      }
    }
  
    function copyTouch({ identifier, clientX, clientY }) {
      return {
        id: identifier, 
        x: (clientX - CV.getBoundingClientRect().left)/scaling, 
        y: (clientY - CV.getBoundingClientRect().top)/scaling 
      };
    }
  
    function ongoingTouchIndexById(idToFind) {
      for (let i = 0; i < ongoingTouches.length; i++) {
        const id = ongoingTouches[i].id;
  
        if (id === idToFind) {
          return i;
        }
      }
      return -1;
    }
  
    function drawDot(x: number, y: number) {
      ctx.fillStyle = brushColour;
      ctx.beginPath();
      ctx.arc(x - pointSize*0.5, y - pointSize*0.5, pointSize, 0, 2 * Math.PI);
      ctx.fill();
    }
  
    function checkTouchscreen(): boolean {
      if ("maxTouchPoints" in navigator) {
        return (navigator.maxTouchPoints > 0);
      } else if ("msMaxTouchPoints" in navigator) {
        //@ts-ignore
        return (navigator.msMaxTouchPoints > 0);
      } else {
        const mQ = matchMedia?.("(pointer:coarse)");
        if (mQ?.media === "(pointer:coarse)") {
          return (!!mQ.matches);
        } else if ("orientation" in window) {
          return (true);
        } else {
          //@ts-ignore
          const UA = navigator.userAgent;
          return (
            /\b(BlackBerry|webOS|iPhone|IEMobile)\b/i.test(UA) ||
            /\b(Android|Windows Phone|iPad|iPod)\b/i.test(UA)
          );
        }
      }
    }
  
    onMount(async () => {
      let ctxCont = CV.getContext("2d");
      if (ctxCont) {
        ctx = ctxCont;
      }
  
      CV.height = originalHeight;
      CV.width = originalWidth;
  
      show = checkTouchscreen();
    });
  
    function doubleClickMouse(e: MouseEvent) {
      document.elementsFromPoint(e.clientX, e.clientY).every(e2 => {
        if (e2.className.indexOf(doubleClickTarget) == 0) {
          const target = e2 as HTMLElement;
          dispatch("doubleClickEv", {
            target: target
          })
          return false;
        } else {
          return true;
        }
      })
    }
 
    function saveStorageScribble() {
      sessionStorage.setItem("TEMPSCRIBBLE", CV.toDataURL("image/webp", 0.5));
      sessionStorage.setItem("save", "Y");
    }
  </script>
  
  <canvas 
    style="display: { show ? "initial" : "none" }; height: {originalHeight*scaling}px; width: {originalWidth*scaling}px; z-index: 2; opacity: 1.0; cursor: { cursorType };"
    bind:this={CV}
    on:mousemove={mouseMove}
    on:mouseup={mouseUp}
    on:mousedown={mouseDown}
    on:mouseleave={mouseLeave}
    on:touchstart={touchStart}
    on:touchmove={touchMove}
    on:touchend={touchEnd}
    on:touchcancel={touchCancel}
    on:pointerdown={pointerDown}
    on:dblclick={doubleClickMouse}
  ></canvas>

<style>
  /*   SCRIBBLE BOARD   */
  canvas {
    position: absolute;
    top: 0px;
    left: 0px;
  }
</style>