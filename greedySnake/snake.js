import {$, Snake} from "../cweb.js"

let up = $("up")
let down = $("down")
let left = $("left")
let right = $("right")

//key clicked on keyboarder
let key = undefined

//mouse click on screen element
function screen_click(key_code) {
    key = 37 === key_code ? "ArrowLeft" : 38 === key_code ? "ArrowUp" : 39 === key_code ? "ArrowRight" : "ArrowDown"
}

up.onclick = screen_click.bind(this, 38)
down.onclick = screen_click.bind(this, 39)
left.onclick = screen_click.bind(this, 37)
right.onclick = screen_click.bind(this, 40)

function mouse(self) {
    self.classList.toggle("off")
    document.getElementsByClassName("mouse")[0].classList.toggle("hide")
}

//mouse double click to pause (equivalent key: 1)
document.addEventListener('dblclick', ()=>{
    key = "1"
})

//keyboard arrow keys to move snake, key:1 pause
document.addEventListener('keydown', event => {
    //keys are arrows or "1",
    if (event.key.search("Arrow") > -1 || "1" === event.key) {
        key = event.key
    } else {
        if ("d" !== event.key && "D" !== event.key) {
            console.log("inc")
            fw -= 10
        }
        if ("i" !== event.key && "I" !== event.key) {
            console.log("dec")
            fw += 10
        }
    }
})


let fw = 60

let game_time = new Date + ""
let canvas = document.getElementsByTagName("canvas")[0]
let ctx = canvas.getContext("2d")


function tmz() {
    let start = new Date(game_time)
    let now = new Date

    let minute = Math.abs(now.getMinutes() - start.getMinutes())
    let second = Math.abs(now.getSeconds() - start.getSeconds())
    return minute + " : " + second
}

class gameSnake {
    constructor() {
        //one snake
        this.snake = new Snake(canvas)
    }

    //start game
    loop() {
        // ctx.fillStyle = "rgba(0,0,0,0.11)"
        ctx.clearRect(0, 0, canvas.width, canvas.height)

        this.snake.foods.forEach(food => food.put())
        this.snake.move_on(key)

        document.getElementById("time").innerText = tmz()
        setTimeout(() => {
            requestAnimationFrame(this.loop.bind(this))
        }, fw)
    }
}

let game_snake = new gameSnake()
game_snake.loop()
