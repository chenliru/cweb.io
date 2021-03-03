class Blob {
    constructor(label, image, rect, vector) {
        this.exists = true
        // this.firstFrame = true
        // this.preImageData = undefined
        this.label = label
        this.rect = rect
        this.image = image

        this.get_center()
        this.get_diagonal()

        this.vector = vector
        this.velX = vector[0]
        this.velY = vector[1]
        this.get_velocity()

        this.anti_gravity = false
        this.tracing = true

        this.color = 'rgb(' + Blob.random(0, 255) + ',' + Blob.random(0, 255) + ',' + Blob.random(0, 255) + ')'
    }

    get_center() {
        this.center = [Math.floor(this.rect[0] + this.rect[2] / 2), Math.floor(this.rect[1] + this.rect[3] / 2)]
        return this.center
    }

    get_diagonal() {
        this.diagonal = Math.floor(Math.sqrt(this.rect[2] ** 2 + this.rect[3] ** 2))
        return this.diagonal
    }

    get_velocity() {
        this.velocity = Math.sqrt(this.vector[0] * this.vector[0] + this.vector[1] * this.vector[1])
        return this.velocity
    }

    // function to generate random number
    static random(min, max) {
        return Math.floor(Math.random() * (max - min)) + min
    }

    static distance(p1, p2) {
        const dx = p1[0] - p2[0]
        const dy = p1[1] - p2[1]

        return Math.hypot(dx, dy)
    }

    static line(context, x1, y1, x2, y2) {
        context.beginPath();
        context.strokeStyle = 'black';
        context.lineWidth = 1;
        context.moveTo(x1, y1);
        context.lineTo(x2, y2);
        context.stroke();
        context.closePath();
    }

    static overlap(b1, b2) {
        // return b1.x < b2.x + b2.w && b1.x + b1.w > b2.x && b1.y < b2.y + b2.h && b1.h + b1.y > b2.y
        //
        b1.get_center()
        b2.get_center()

        b1.get_diagonal()
        b2.get_diagonal()

        return Blob.distance(b1.center, b2.center) < (b1.diagonal + b2.diagonal) / 2
    }

    static inside(outside, inside) {
        let x_o = outside.rect[0]
        let y_o = outside.rect[1]
        let w_o = outside.rect[2]
        let h_o = outside.rect[3]

        let x_i = inside.rect[0]
        let y_i = inside.rect[1]
        let h_i = inside.rect[2]
        let w_i = inside.rect[3]

        return x_i > x_o && y_i > y_o && x_i + w_i < x_o + w_o && y_i + h_i < y_o + h_o
    }

    gravity() {
        this.velY *= .99
        this.velY += .25
    }

    draw(canvas) {
        const ctx = canvas.getContext('2d')
        const ctx_tracing = canvas_tracing.getContext('2d')
        if (this.exists) {
            let x = this.center[0]
            let y = this.center[1]

            // update velX, velY
            if (!this.anti_gravity) this.gravity()
            this.rect[0] += this.velX
            this.rect[1] += this.velY

            ctx.drawImage(this.image, Math.floor(this.rect[0]), Math.floor(this.rect[1]), this.rect[2], this.rect[3])

            if (this.tracing) {
                this.get_center()
                Blob.line(ctx_tracing, x, y, this.center[0], this.center[1]);
            }
        }
    }
}

class Blobs {
    constructor(border) {
        // collection of blobs, in which this blob belong to
        this.blobs = []
        this.border = border

    }

    register(blobs) {
        blobs.forEach((blob) => {
            this.blobs.push(blob)
        })
    }

    //hit border return
    hit_border(blob) {
        if (blob.rect[0] <= 0) {
            return "left"
        }
        if ((blob.rect[0] + blob.rect[2]) >= this.border[0]) {
            return "right"
        }
        if (blob.rect[1] <= 0) {
            return "top"
        }
        if ((blob.rect[1] + blob.rect[3]) >= this.border[1]) {
            return "bottom"
        }
    }

    draw(canvas) {
        this.blobs.forEach((blob) => {
            if (blob.exists) {
                // update velX, velY
                this.detect_collision(blob)
                this.detect_border(blob)

                blob.draw(canvas)
            }
        })
    }

    detect_border(blob) {
        if (this.hit_border(blob) === "left" || (this.hit_border(blob) === "right")) {
            blob.velX = -(blob.velX)
        }
        if (this.hit_border(blob) === "top" || (this.hit_border(blob) === "bottom")) {
            blob.velY = -(blob.velY)
        }
        if (this.hit_border(blob) === "bottom") {
            blob.rect[1] = this.border[1] - blob.rect[3]
        }
    }

    detect_collision(blob) {
        for (let j = 0; j < this.blobs.length; j++) {
            if (blob !== this.blobs[j] && this.blobs[j].exists) {
                if (Blob.overlap(blob, this.blobs[j])) {
                    blob.get_center()
                    // this.get_velocity()

                    const dx = blob.center[0] - this.blobs[j].center[0]
                    const dy = blob.center[1] - this.blobs[j].center[1]
                    const distance = Blob.distance(blob.center, this.blobs[j].center)

                    blob.velX = Math.floor(blob.velocity * dx / distance)
                    blob.velY = Math.floor(blob.velocity * dy / distance)
                }
            }
        }
    }

}

class Park extends Blob {
    constructor(label, image, rect, vector) {
        super(label, image, rect, vector);

        this.color = "white";
    }

    control_park(canvas) {
        const _this = this;
        canvas.onkeydown = function (e) {
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
        canvas.onmousemove = function (e) {
            _this.rect[0] = e.offsetX - _this.rect[2] / 2
            _this.rect[1] = e.offsetY - _this.rect[3] / 2
        }
        console.log(_this.velY)
    }

}

// setup canvas

const para = document.querySelector('p')
let count = 0

const canvas = document.getElementById('canvas-main')
const canvas_tracing = document.getElementById('canvas-tracing')

const width = canvas.width = canvas_tracing.width = window.innerWidth
const height = canvas.height = canvas_tracing.height = window.innerHeight

const ball = document.getElementById('ball')
const gate = document.getElementById('soccer-gate')


function loop() {
    const ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, width, height)
    // background(canvas)

    blobs.draw(canvas)

    requestAnimationFrame(loop);
}

// define array to store balls and populate it

const blobs = new Blobs([width, height])
let blobNum = 3

while (count < blobNum) {
    const label = `Num-${count}`
    const image = ball

    const w = Blob.random(10, 40)
    const h = Blob.random(10, 50)

    const x = Blob.random(0 + w, width - w)
    const y = Blob.random(0 + h, height - h)

    const velX = Blob.random(-7, 7)
    const velY = Blob.random(-7, 7)

    if (count < blobNum - 1) {
        const ball = new Blob(
            // ball position always drawn at least one ball width
            // away from the edge of the canvas, to avoid drawing errors
            label, image, [x, y, w, h], [velX, velY]
        )
        blobs.register([ball])
    } else {
        const park = new Park(
            label, ball, [x, y, 100, 100], [0, 0]
        )
        park.anti_gravity = true
        park.control_park(canvas)
        blobs.register([park])
    }

    count++;
    para.textContent = 'Blob count: ' + count;
}

loop();
