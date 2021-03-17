import {$, Snake} from "../cweb.js"

let up = $("up");
let down = $("down");
let left = $("left");
let right = $("right");

//key clicked on keyboarder
let key = undefined;

up.onclick = screen_click.bind(this, 38);
down.onclick = screen_click.bind(this, 39);
left.onclick = screen_click.bind(this, 37);
right.onclick = screen_click.bind(this, 40);

//mouse click on screen element
function screen_click(key_code) {
    key = 37 === key_code ? "ArrowLeft" : 38 === key_code ? "ArrowUp" : 39 === key_code ? "ArrowRight" : "ArrowDown";
}

//mouse double click to pause (equivalent key: 1)
document.addEventListener('dblclick', () => {
    key = "1";
})

//keyboard arrow keys to move snake, key:1 pause
document.addEventListener('keydown', event => {
    //keys are arrows or "1",
    if (event.key.search("Arrow") > -1 || "1" === event.key) {
        key = event.key;
    } else {
        if ("d" !== event.key && "D" !== event.key) {
            console.log("inc");
            fw -= 10;
        }
        if ("i" !== event.key && "I" !== event.key) {
            console.log("dec");
            fw += 10;
        }
    }
})


let fw = 60;

let startTime = new Date();
let canvas = document.getElementsByTagName("canvas")[0];
let ctx = canvas.getContext("2d");


function tmz(startTime) {

    // Record end time
    let endTime = new Date();

    // Compute time difference in milliseconds
    let timeDiff = endTime.getTime() - startTime.getTime();

    // Convert time difference from milliseconds to seconds
    timeDiff = timeDiff / 1000;

    // Extract integer seconds that dont form a minute using %
    let seconds = Math.floor(timeDiff % 60); //ignoring uncomplete seconds (floor)

    // Pad seconds with a zero if necessary
    let secondsAsString = seconds < 10 ? "0" + seconds : seconds + "";

    // Convert time difference from seconds to minutes using %
    timeDiff = Math.floor(timeDiff / 60);

    // Extract integer minutes that don't form an hour using %
    let minutes = timeDiff % 60; //no need to floor possible incomplete minutes, becase they've been handled as seconds

    // Pad minutes with a zero if necessary
    let minutesAsString = minutes < 10 ? "0" + minutes : minutes + "";

    // Convert time difference from minutes to hours
    timeDiff = Math.floor(timeDiff / 60);

    // Extract integer hours that don't form a day using %
    let hours = timeDiff % 24; //no need to floor possible incomplete hours, becase they've been handled as seconds

    // Convert time difference from hours to days
    timeDiff = Math.floor(timeDiff / 24);

    // The rest of timeDiff is number of days
    let days = timeDiff;

    let totalHours = hours + (days * 24); // add days to hours
    let totalHoursAsString = totalHours < 10 ? "0" + totalHours : totalHours + "";

    if (totalHoursAsString === "00") {
        return minutesAsString + ":" + secondsAsString;
    } else {
        return totalHoursAsString + ":" + minutesAsString + ":" + secondsAsString;
    }

}

class gameSnake {
    constructor() {
        //one snake
        this.snake = new Snake(canvas);
        this.id = undefined;
    }

    //start game
    loop() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);   //clean field

        this.snake.foods.forEach(food => food.serve()); // draw food
        this.snake.move_on(key);    //move snake

        document.getElementById("time").innerText = tmz(startTime);  //update game time
        setTimeout(() => {
            this.id = requestAnimationFrame(this.loop.bind(this))
        }, fw)
    }

    start() {
        if (this.id) {
            cancelAnimationFrame(this.id);
            window.location.reload(true);
        }

        fw = 60;
        startTime = new Date();

        this.loop();
        setTimeout(this.stop, 60000)
    }

    stop() {
        cancelAnimationFrame(this.id);
        window.location.reload(true);
        alert("Game Over")
    }
}


const game_snake = new gameSnake();
const start = document.getElementById("start");
start.addEventListener("click", (e) => {
    game_snake.start();
})
// game_snake.loop();