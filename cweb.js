// utility function
function $(id) {
    return document.getElementById(id);
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

    draw_point(canvas, e) {
        if (this.isDraw) {
            let ctx = canvas.getContext('2d')
            ctx.save()
            ctx.fillStyle = this.color
            ctx.beginPath()

            //get mouse x,y
            this.mouse_xy(e)

            ctx.arc(this.x, this.y, 3, 0, 2 * Math.PI);
            ctx.fill()
            ctx.restore();
        }

    }

    draw_line(canvas, e) {
        if (this.isDraw) {
            let ctx = canvas.getContext('2d')
            ctx.beginPath();
            ctx.strokeStyle = 'black';
            ctx.lineWidth = 1;
            ctx.moveTo(this.x, this.y);

            this.mouse_xy(e)

            ctx.lineTo(this.x, this.y);
            ctx.stroke();
            ctx.closePath();
        }
    }

    draw_circle(canvas, e){
        //
        console.log("put your code here")
    }

    mouse_xy(e) {
        let el = e.target, c = el;
        let scaleX = c.width / c.offsetWidth || 1;
        let scaleY = c.height / c.offsetHeight || 1;

        if (!isNaN(e.offsetX)) {
            this.x = e.offsetX * scaleX
            this.y = e.offsetY * scaleY
        } else {
            let x = e.pageX, y = e.pageY;
            do {
                x -= el.offsetLeft;
                y -= el.offsetTop;
                el = el.offsetParent;
            } while (el);
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


export {$, Point, bezierCurve}
