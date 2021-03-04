import {$, Point} from "../cweb.js"

const pointCanvas = document.getElementById('point-canvas')
const point = new Point()

// Add the event listeners for mousedown, mousemove, and mouseup
pointCanvas.addEventListener('mousedown', e => {
    point.isDraw = true
    point.draw_point(e, pointCanvas)
    // console.log('mouse down')
})

pointCanvas.addEventListener('mousemove', e => {
    point.draw_curve(e, pointCanvas)
    $("mouse").innerHTML = "x: " + Math.floor(point.x) + "," + " y: " + Math.floor(point.y);
})

pointCanvas.addEventListener('mouseup', e => {
    point.isDraw = false
})
