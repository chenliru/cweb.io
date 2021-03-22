import {$, Point, bezierCurve} from "../cweb.js"


const curveCanvas = $("curve-canvas")
const curve = new bezierCurve(curveCanvas)

let show_points = $("show-points")
let tension = $("tension")
let flexible = $("flexible")


function update_curve() {
    $("tension-value").innerHTML = "(" + tension.value + ")";
    $("flexible-value").innerHTML = "(" + flexible.value + ")";

    curve.showPoints = show_points.checked
    curve.tension = tension.value
    curve.flexible = flexible.value
    curve.draw_splines()
}

show_points.onchange = update_curve
flexible.onchange = update_curve
tension.onchange = update_curve

curveCanvas.onclick = function (e) {
    const point = new Point(curveCanvas)
    point.mouse_xy(e)
    curve.register([point])
    curve.draw_splines()
}

curveCanvas.onmousemove = function (e) {
    const p = new Point(curveCanvas)
    p.mouse_xy(e)
    $("mouse").innerHTML = Math.floor(p.x) + ",  " + Math.floor(p.y)
}
