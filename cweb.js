/*
 You are free to use and modify this code in anyway you find useful. Please leave this comment in the code
 to acknowledge its original source. If you feel like it, I enjoy hearing about projects that use my code,
 but don't feel like you have to let me know or ask permission.

 author: chenliru@yahoo.com

*/


// utility function
function $(id) {
    return document.getElementById(id)
}

const reload = document.querySelectorAll('.reload')

reload.forEach((reload) => {
    reload.addEventListener('click', () => {
        window.setTimeout(() => {
            window.location.reload(true)
        }, 200);
    })
})

class Point {
    constructor() {
        this.x = 0
        this.y = 0

        this.color = 'red'
        this.isDraw = false
    }

    draw_point(event, canvas) {
        if (this.isDraw) {
            if (typeof (canvas) == 'undefined') canvas = event.target
            let ctx = canvas.getContext('2d')

            ctx.save()
            ctx.fillStyle = this.color
            ctx.beginPath()

            //get mouse x,y
            this.mouse_xy(event)

            ctx.arc(this.x, this.y, 2, 0, 2 * Math.PI);
            ctx.fill()
            ctx.restore();
        }
    }

    draw_curve(event, canvas) {
        if (this.isDraw) {
            if (typeof (canvas) == 'undefined') canvas = event.target
            let ctx = canvas.getContext('2d')

            ctx.beginPath();
            ctx.strokeStyle = 'black';
            ctx.lineWidth = 1;
            ctx.moveTo(this.x, this.y);

            this.mouse_xy(event, canvas)

            ctx.lineTo(this.x, this.y);
            ctx.stroke();
            ctx.closePath();
        }
    }

    draw_circle(event, canvas) {
        //
        console.log("put your code here")
    }

    mouse_xy(event, canvas) {
        if (typeof (canvas) == 'undefined') canvas = event.target
        // let canvas =  event.target

        let c = canvas
        let scaleX = c.width / c.offsetWidth || 1
        let scaleY = c.height / c.offsetHeight || 1
        console.log(c.width, c.offsetWidth)

        if (!isNaN(event.offsetX)) {
            this.x = event.offsetX * scaleX
            this.y = event.offsetY * scaleY
        } else {
            let x = event.pageX, y = event.pageY
            do {
                x -= canvas.offsetLeft
                y -= canvas.offsetTop
                canvas = canvas.offsetParent
            } while (canvas)
            this.x = x * scaleX
            this.y = y * scaleY
        }
    }
}


class bezierCurve {
    constructor() {
        this.flexible = 0.3
        this.tension = 0.6

        // a list of point: (x and y)
        this.points = []
        this.showPoints = true
    }

    register(points) {
        points.forEach((point) => {
            this.points.push(point)
        })
    }

    draw_splines(canvas) {
        bezierCurve.clear(canvas)
        if (this.showPoints) this.draw_points(canvas)
        this.bzCurve(canvas)
    }

    draw_points(canvas) {
        for (let i = 0; i < this.points.length; i++) {
            bezierCurve.show_point(canvas, this.points[i])
        }
    }

    //Gradient function that return slope of the line
    static gradient(a, b) {
        return (b.y - a.y) / (b.x - a.x)
    }

    bzCurve(canvas) {
        let ctx = canvas.getContext('2d')
        // if (typeof (f) == 'undefined') f = $("flexible").value //0.3
        // if (typeof (t) == 'undefined') t = $("tension").value //0.6
        let f = this.flexible
        let t = this.tension

        ctx.beginPath()
        ctx.moveTo(this.points[0].x, this.points[0].y)

        let m = 0
        let dx1 = 0
        let dy1 = 0
        let dx2 = 0
        let dy2 = 0

        let preP = this.points[0]

        for (let i = 1; i < this.points.length; i++) {
            let curP = this.points[i]
            let nexP = this.points[i + 1]
            if (nexP) {
                m = bezierCurve.gradient(preP, nexP)
                dx2 = (nexP.x - curP.x) * -f
                dy2 = dx2 * m * t
            } else {
                dx2 = 0
                dy2 = 0
            }

            ctx.bezierCurveTo(
                preP.x - dx1, preP.y - dy1,
                curP.x + dx2, curP.y + dy2,
                curP.x, curP.y
            )

            dx1 = dx2
            dy1 = dy2
            preP = curP
        }
        ctx.stroke()
    }

    static clear(canvas) {
        this.canvas = canvas

        let ctx = canvas.getContext('2d')
        ctx.save()
        // use alpha to fade out
        ctx.fillStyle = "rgba(255,255,255,.7)" // clear screen
        ctx.fillRect(0, 0, canvas.width, canvas.height)
        ctx.restore()
    }

    static show_point(canvas, p) {
        let ctx = canvas.getContext('2d')
        ctx.save()
        ctx.beginPath()
        if (p.color) {
            ctx.fillStyle = p.color
        }
        ctx.arc(p.x, p.y, 5, 0, 2 * Math.PI)
        ctx.fill()
        ctx.restore()
    }
}

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
        this.trace = false

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
        context.beginPath()
        context.strokeStyle = 'black'
        context.lineWidth = 1
        context.moveTo(x1, y1)
        context.lineTo(x2, y2)
        context.stroke()
        context.closePath()
    }

    static collision(b1, b2) {
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

    //emulate gravity
    gravity() {
        this.velY *= .99
        this.velY += .25
    }

    draw(canvas_layer) {
        if (this.exists) {
            const ctx_blob = canvas_layer["blob"].getContext('2d')
            const ctx_tracing = canvas_layer["trace"].getContext('2d')

            let x = this.center[0]
            let y = this.center[1]

            // update velX, velY
            if ((!this.anti_gravity) || (this.center[1] + this.rect[3] / 2 < canvas_layer.height)) this.gravity()
            this.rect[0] += this.velX
            this.rect[1] += this.velY

            ctx_blob.drawImage(this.image, Math.floor(this.rect[0]), Math.floor(this.rect[1]), this.rect[2], this.rect[3])

            if (this.trace) {
                this.get_center()
                Blob.line(ctx_tracing, x, y, this.center[0], this.center[1]);
            }
            // console.log('blob is drawing')
        }
    }
}

class Blobs {
    constructor() {
        // collection of blobs, in which this blob belong to
        this.blobs = []
    }

    register(blobs) {
        blobs.forEach((blob) => {
            this.blobs.push(blob)
        })
    }

    //hit border return
    border(blob, canvas) {
        if (blob.rect[0] <= 0) {
            return "left"
        }
        if ((blob.rect[0] + blob.rect[2]) >= canvas.width) {
            return "right"
        }
        if (blob.rect[1] <= 0) {
            return "top"
        }
        if ((blob.rect[1] + blob.rect[3]) >= canvas.height) {
            return "bottom"
        }
    }

    //canvas_layer = {'blob': blobCanvas, 'trace': traceCanvas}
    draw(canvas_layer) {
        this.blobs.forEach((blob) => {
            if (blob.exists) {
                // update velX, velY
                this.detect_blob_collision(blob)
                this.detect_border_collision(blob, canvas_layer['blob'])

                blob.draw(canvas_layer)
            }
        })
    }

    detect_border_collision(blob, canvas) {
        if (this.border(blob, canvas) === "left" || (this.border(blob, canvas) === "right")) {
            blob.velX = -(blob.velX)
        }
        if (this.border(blob, canvas) === "top" || (this.border(blob, canvas) === "bottom")) {
            blob.velY = -(blob.velY)
        }
    }

    detect_blob_collision(blob) {
        for (let j = 0; j < this.blobs.length; j++) {
            if (blob !== this.blobs[j] && this.blobs[j].exists) {
                if (Blob.collision(blob, this.blobs[j])) {
                    blob.get_center()
                    // this.get_velocity()

                    const dx = blob.center[0] - this.blobs[j].center[0]
                    const dy = blob.center[1] - this.blobs[j].center[1]
                    const distance = Blob.distance(blob.center, this.blobs[j].center)

                    blob.velX = Math.floor(blob.velocity * dx / distance)
                    blob.velY = Math.floor(blob.velocity * dy / distance)

                    this.blobs[j].velX = -Math.floor(this.blobs[j].velocity * dx / distance)
                    this.blobs[j].velY = -Math.floor(this.blobs[j].velocity * dy / distance)
                }
            }
        }
    }

}

export {$, Point, bezierCurve, Blob, Blobs}
