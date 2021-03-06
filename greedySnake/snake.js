import {$} from "../cweb.js"

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

class Snake {
    constructor() {
        this.w = 15
        this.h = 15

        this.snake = []

        //init snake in the middle of canvas
        let body = {
            x: canvas.width / 2,
            y: canvas.height / 2
        }

        //assign 5 snake body object {x:, y:} to snake array []
        for (let i = 0; i < 5; i++) {
            this.snake.push(Object.assign({}, body))
            body.x += this.w
        }
        console.log(this.snake)

        this.foods = []
        //10 foods
        for (let i = 0; i < 10; i++) this.foods.push(new Food)
    }

    eat(food) {
        return this.snake[0].x < food.x + food.w
            && this.snake[0].x + this.w > food.x
            && this.snake[0].y < food.y + food.h
            && this.h + this.snake[0].y > food.y
    }

    draw() {
        let arrow_key = key && key.search("Arrow") > -1
        let food_number = -1

        if (arrow_key) {
            // arrayLike is now iterable, spread operator is used to extract
            // its elements into an array: [...arrayLike]
            let head = {
                ...this.snake[0]
            };

            "ArrowUp" === key && (head.y -= this.h)
            "ArrowDown" === key && (head.y += this.h)
            "ArrowLeft" === key && (head.x -= this.w)
            "ArrowRight" === key && (head.x += this.w)

            head.x >= canvas.width ? head.x = 0 : head.x < 0 && (head.x = canvas.width - this.w)
            head.y > canvas.height ? head.y = 0 : head.y < 0 && (head.y = canvas.height)

            //returns the index of the first element in the array that satisfies the provided testing function
            food_number = this.foods.findIndex(food => this.eat(food))

            //adds one or more elements to the beginning of an array and returns the new length of the array.
            this.snake.unshift(head)

            //food was eaten, and return without pop last snake body. (added one body)
            if (-1 !== food_number) {
                this.foods[food_number].renew()
                document.getElementById("score").innerText = Number(document.getElementById("score").innerText) + 1 + ''
                return console.log(`eat item: ${food_number}`)
            }
            this.snake.pop()
        }

        // forEach callback function:
        // the value of the element
        // the index of the element
        // the Array object being traversed
        this.snake.forEach((body, idx, snake) => {
            ctx.fillRect(body.x, body.y, this.w, this.h)
            ctx.strokeStyle = "#39031f" //"#E91E63"
            ctx.font = "30px serif"
            ctx.strokeStyle = "#c34a89" // "#9E9E9E"
            snake.length - 1 !== idx && 0 !== idx && ctx.strokeRect(body.x, body.y, this.w, this.h)

            if (0 === idx) {
                ctx.beginPath()
                ctx.fillStyle = "#5ff436"
                ctx.arc(body.x + 10, body.y + 2, 5, 360, 0)
                ctx.fill()
            }

            ctx.arc(body.x + 10, body.y + 2, 5, 360, 0)
            ctx.fill()
            ctx.beginPath()
        })
    }
}

class Food {
    constructor() {
        this.x = 0
        this.y = 0
        this.b = 10
        this.w = this.b
        this.h = this.b
        this.color = 'red'
        this.bowl = 'yellow'

        this.renew()
        this.put()
    }

    renew() {
        this.x = Math.floor(Math.random() * (canvas.width - 200) + 10)
        this.y = Math.floor(Math.random() * (canvas.height - 200) + 30)
    }

    put() {
        ctx.fillStyle = this.color
        ctx.arc(this.x, this.y, this.b - 5, 0, 2 * Math.PI)
        ctx.fill()
        ctx.beginPath()
        ctx.arc(this.x, this.y, this.b - 5, 0, Math.PI)
        ctx.strokeStyle = this.bowl
        ctx.lineWidth = 10
        ctx.stroke()
        ctx.beginPath()
        ctx.lineWidth = 1
    }
}

class gameSnake {
    constructor() {
        //one snake
        this.snake = new Snake(canvas.width / 2, canvas.height / 2, 400, 4, 4)
    }

    //start game
    loop() {
        // ctx.fillStyle = "rgba(0,0,0,0.11)"
        ctx.clearRect(0, 0, canvas.width, canvas.height)

        this.snake.foods.forEach(food => food.put())
        this.snake.draw()

        document.getElementById("time").innerText = tmz()
        setTimeout(() => {
            requestAnimationFrame(this.loop.bind(this))
        }, fw)
    }
}

let game_snake = new gameSnake()
game_snake.loop()
