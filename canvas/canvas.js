const reload = document.querySelectorAll('.reload')


reload.forEach((reload) => {
    reload.addEventListener('click', () => {
        window.setTimeout(() => {
            window.location.reload(true)
        }, 200);
    })
})

class mousePoint {
    constructor() {
        this.x = 0
        this.y = 0
        // this.color = 'rgb(' + Blob.random(0, 255) + ',' + Blob.random(0, 255) + ',' + Blob.random(0, 255) + ')'
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

    draw_circle(){
        //
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
        // $("mouse").innerHTML = this.x + "," + this.y;
    }
}

const pointCanvas = document.getElementById('pointCanvas')
const point = new mousePoint()

// Add the event listeners for mousedown, mousemove, and mouseup
pointCanvas.addEventListener('mousedown', e => {
    point.isDraw = true
    point.draw_point(pointCanvas, e)
    console.log('mouse down')
})

pointCanvas.addEventListener('mousemove', e => {
    point.draw_line(pointCanvas, e)
})

pointCanvas.addEventListener('mouseup', e => {
    point.isDraw = false
})

/////////////////////////////////////////////////////////////////////////////

class curvePoints {
    constructor() {
        // a list of point: (x and y)
        this.points = []
    }

    register(points) {
        points.forEach((point) => {
            this.points.push(point)
        })
    }

    drawSplines(canvas) {
        curvePoints.clear(canvas);
        if ($("showPoints").checked) this.drawPoints(canvas);
        this.bzCurve(canvas);
    }

    drawPoints(canvas) {
        for (let i = 0; i < this.points.length; i++) {
            curvePoints.showPt(canvas, this.points[i]);
        }
    }

    //Gradient function that return slope of the line
    static gradient(a, b) {
        return (b.y - a.y) / (b.x - a.x);
    }

    bzCurve(canvas, f, t) {
        let ctx = canvas.getContext('2d')
        if (typeof (f) == 'undefined') f = $("flexible").value //0.3
        if (typeof (t) == 'undefined') t = $("tension").value //0.6

        ctx.beginPath();
        ctx.moveTo(this.points[0].x, this.points[0].y);

        let m = 0;
        let dx1 = 0;
        let dy1 = 0;
        let dx2 = 0;
        let dy2 = 0;

        let preP = this.points[0];

        for (let i = 1; i < this.points.length; i++) {
            let curP = this.points[i];
            let nexP = this.points[i + 1];
            if (nexP) {
                m = curvePoints.gradient(preP, nexP);
                dx2 = (nexP.x - curP.x) * -f;
                dy2 = dx2 * m * t;
            } else {
                dx2 = 0;
                dy2 = 0;
            }

            ctx.bezierCurveTo(
                preP.x - dx1, preP.y - dy1,
                curP.x + dx2, curP.y + dy2,
                curP.x, curP.y
            );

            dx1 = dx2;
            dy1 = dy2;
            preP = curP;
        }
        ctx.stroke();
    }

    static clear(canvas) {
        let ctx = canvas.getContext('2d')
        ctx.save();
        // use alpha to fade out
        ctx.fillStyle = "rgba(255,255,255,.7)"; // clear screen
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.restore();
    }

    static showPt(canvas, p) {
        let ctx = canvas.getContext('2d')
        ctx.save();
        ctx.beginPath();
        if (p.color) {
            ctx.fillStyle = p.color;
        }
        ctx.arc(p.x, p.y, 5, 0, 2 * Math.PI);
        ctx.fill();
        ctx.restore();
    }
}


const curveCanvas = $("curveCanvas")
const curve = new curvePoints()

function updateCurve() {
    $("tension-value").innerHTML = "(" + $("tension").value + ")";
    $("flexible-value").innerHTML = "(" + $("flexible").value + ")";
    curve.drawSplines(curveCanvas);
}

// utility function
function $(id) {
    return document.getElementById(id);
}

$("showPoints").onchange = $("flexible").onchange = $("tension").onchange = updateCurve;


curveCanvas.onclick = function (e) {
    const point = new mousePoint()
    point.mouse_xy(e)
    curve.register([point]);
    curve.drawSplines(curveCanvas)
};

curveCanvas.onmousemove = function (e) {
    const p = new mousePoint()
    p.mouse_xy(e)
    $("mouse").innerHTML = Math.floor(p.x) + ",  " + Math.floor(p.y)
};

//////////////////////////////////////////////////////////////////////////

// setup canvas
import {Blob, Blobs} from "./blob";

const blobCanvas = document.getElementById('blobCanvas')
const canvas_tracing = document.getElementById('traceCanvas')
let count = 0

const ball = document.getElementById('ball')
const gate = document.getElementById('soccer-gate')

function loop() {
    const ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, width, height)
    // background(canvas)

    blobs.draw(blobCanvas)

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
