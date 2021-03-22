import {$, Point} from "../js/cweb.js"

const pointCanvas = document.getElementById('point-canvas')
const point = new Point(pointCanvas)

// Add the event listeners for mousedown, mousemove, and mouseup
pointCanvas.addEventListener('mousedown', e => {
    point.isDraw = true
    point.draw_point(e)
})

pointCanvas.addEventListener('mousemove', e => {
    point.draw_curve(e)
    $("mouse").innerHTML = "x: " + Math.floor(point.x) + "," + " y: " + Math.floor(point.y)
})

pointCanvas.addEventListener('mouseup', e => {
    point.draw_point(e)
    point.isDraw = false
})
