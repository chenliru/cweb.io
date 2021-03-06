import {$, Blob, Blobs, Point} from "../cweb.js"

class bigBall extends Blob {
    constructor(label, image, rect, vector) {
        super(label, image, rect, vector);

        this.color = "white";
        this.point = new Point()
    }

    control_park(canvas) {
        const _this = this;
        document.onkeydown = function (e) {
            switch (e.key) {
                case 'ArrowLeft':
                    _this.rect[0] -= 5;
                    break;
                case 'ArrowRight':
                    _this.rect[0] += 5;
                    break;
                case 'ArrowUp':
                    _this.rect[1] -= 5;
                    break;
                case 'ArrowDown':
                    _this.rect[1] += 5;
                    break;
            }
        }
        window.onmousemove = function (e) {
            _this.point.mouse_xy(e)
            _this.rect[0] = _this.point.x - _this.rect[2] / 2
            _this.rect[1] = _this.point.y - _this.rect[3] / 2
        }
    }
}

// setup canvas
const blobCanvas = $("blob-canvas")
const traceCanvas = $("trace-canvas")
const canvas_layer = {
    blob: blobCanvas,
    trace: traceCanvas
}

let ball_number = $("ball-number")
let trace_ball = $("tracing-ball")
let gravity = $("gravity")

const ball = document.getElementById('ball')
const gate = document.getElementById('soccer-gate')


class blobGame {
    constructor() {
        this.blobs = new Blobs()
        this.init()
    }

    init() {
        let count = 0
        this.blobs = new Blobs()

        // define array to store balls and populate it
        while (count < ball_number.value) {
            console.log(count)
            const label = `Num-${count}`
            const image = ball

            const w = Blob.random(10, 40)
            const h = Blob.random(10, 50)

            const x = Blob.random(0 + w, blobCanvas.width - w)
            const y = Blob.random(0 + h, blobCanvas.height - h)

            const velX = Blob.random(-7, 7)
            const velY = Blob.random(-7, 7)

            if (count < ball_number.value - 1) {
                const ball = new Blob(
                    // ball position always drawn at least one ball width
                    // away from the edge of the canvas, to avoid drawing errors
                    label, image, [x, y, w, h], [velX, velY]
                )
                ball.trace = trace_ball.checked
                ball.anti_gravity = gravity.checked
                this.blobs.register([ball])
            } else {
                const big = new bigBall(
                    label, ball, [x, y, 100, 100], [0, 0]
                )
                big.anti_gravity = true
                big.control_park(canvas_layer['trace'])
                this.blobs.register([big])
            }
            count++
        }
    }

    loop() {
        const ctx = blobCanvas.getContext('2d')
        ctx.clearRect(0, 0, blobCanvas.width, blobCanvas.height)

        this.blobs.blobs.forEach((blob) =>{
            blob.trace = trace_ball.checked
            blob.anti_gravity = !gravity.checked
        })

        this.blobs.draw(canvas_layer)

        window.requestAnimationFrame(this.loop.bind(this))
    }
}
const ball_game = new blobGame()
ball_game.loop()

function update_trace() {
    const ctx = traceCanvas.getContext('2d')
    ctx.clearRect(0, 0, traceCanvas.width, traceCanvas.height)
}
trace_ball.onchange = update_trace

function update_number() {
    ball_game.init()
}
ball_number.onchange = update_number
