/*
 You are free to use and modify this code in anyway you find useful. Please leave this comment in the code
 to acknowledge its original source. If you feel like it, I enjoy hearing about projects that use my code,
 but don't feel like you have to let me know or ask permission.

 author: chenliru@yahoo.com

*/


// utility function
function $(id) {
    return document.getElementById(id);
}

const reload = document.querySelectorAll('.reload');

reload.forEach((reload) => {
    reload.addEventListener('click', () => {
        window.setTimeout(() => {
            window.location.reload(true);
        }, 200);
    })
})

class Point {
    constructor(canvas) {
        this.x = 0;
        this.y = 0;
        this.canvas = canvas

        this.color = 'red';
        this.isDraw = false;
    }

    draw_point(event) {
        if (this.isDraw) {
            if (typeof (this.canvas) == 'undefined') this.canvas = event.target;
            const ctx = this.canvas.getContext('2d');

            ctx.save();
            ctx.fillStyle = this.color;
            ctx.beginPath();

            //get mouse x,y
            this.mouse_xy(event);

            ctx.arc(this.x, this.y, 2, 0, 2 * Math.PI);
            ctx.fill();
            ctx.restore();
        }
    }

    draw_curve(event) {
        if (this.isDraw) {
            if (typeof (this.canvas) == 'undefined') this.canvas = event.target;
            const ctx = this.canvas.getContext('2d');

            ctx.beginPath();
            ctx.strokeStyle = 'black';
            ctx.lineWidth = 1;
            ctx.moveTo(this.x, this.y);

            this.mouse_xy(event);

            ctx.lineTo(this.x, this.y);
            ctx.stroke();
            ctx.closePath();
        }
    }

    draw_circle(event) {
        //
        console.log("put your code here");
    }

    mouse_xy(event) {
        if (typeof (this.canvas) == 'undefined') this.canvas = event.target;
        // let canvas =  event.target;

        let c = this.canvas;
        let scaleX = c.width / c.offsetWidth || 1;
        let scaleY = c.height / c.offsetHeight || 1;
        console.log(c.width, c.offsetWidth);

        if (!isNaN(event.offsetX)) {
            this.x = event.offsetX * scaleX;
            this.y = event.offsetY * scaleY;
        } else {
            let x = event.pageX, y = event.pageY;
            do {
                x -= this.canvas.offsetLeft;
                y -= this.canvas.offsetTop;
                this.canvas = this.canvas.offsetParent;
            } while (this.canvas)
            this.x = x * scaleX;
            this.y = y * scaleY;
        }
    }
}


class bezierCurve {
    constructor(canvas) {
        this.flexible = 0.3;
        this.tension = 0.6;
        this.canvas = canvas;

        // a list of point: (x and y)
        this.points = [];
        this.showPoints = true;
    }

    register(points) {
        points.forEach((point) => {
            this.points.push(point);
        });
    }

    draw_splines() {
        this.clear();
        if (this.showPoints) {
            for (let i = 0; i < this.points.length; i++) {
                this.show_point(this.points[i]);
            }
        }
        this.bzCurve();
    }

    //Gradient function that return slope of the line
    static gradient(a, b) {
        return (b.y - a.y) / (b.x - a.x);
    }

    bzCurve() {
        const ctx = this.canvas.getContext('2d');
        // if (typeof (f) == 'undefined') f = $("flexible").value; //0.3
        // if (typeof (t) == 'undefined') t = $("tension").value; //0.6
        let f = this.flexible;
        let t = this.tension;

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
                m = bezierCurve.gradient(preP, nexP);
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

    clear() {
        const ctx = this.canvas.getContext('2d');
        ctx.save();
        // use alpha to fade out
        ctx.fillStyle = "rgba(255,255,255,.7)"; // clear screen
        ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        ctx.restore();
    }

    show_point(p) {
        const ctx = this.canvas.getContext('2d');
        ctx.save();
        ctx.beginPath();
        ctx.fillStyle = p.color;
        ctx.arc(p.x, p.y, 5, 0, 2 * Math.PI);
        ctx.fill();
        ctx.restore();
    }
}

class Blob {
    constructor(label, image, rect, vector) {
        this.exists = true;
        // this.firstFrame = true;
        // this.preImageData = undefined;
        this.label = label;
        this.rect = rect;
        this.image = image;

        this.get_center();
        this.get_diagonal();

        this.vector = vector;
        this.velX = vector[0];
        this.velY = vector[1];
        this.get_velocity();

        this.anti_gravity = false;
        this.trace = false;

        this.color = 'rgb(' + Blob.random(0, 255) + ',' + Blob.random(0, 255) + ',' + Blob.random(0, 255) + ')';
    }

    get_center() {
        this.center = [Math.floor(this.rect[0] + this.rect[2] / 2), Math.floor(this.rect[1] + this.rect[3] / 2)];
        return this.center;
    }

    get_diagonal() {
        this.diagonal = Math.floor(Math.sqrt(this.rect[2] ** 2 + this.rect[3] ** 2));
        return this.diagonal;
    }

    get_velocity() {
        this.velocity = Math.sqrt(this.vector[0] * this.vector[0] + this.vector[1] * this.vector[1]);
        return this.velocity;
    }

    // function to generate random number
    static random(min, max) {
        return Math.floor(Math.random() * (max - min)) + min;
    }

    static distance(p1, p2) {
        const dx = p1[0] - p2[0];
        const dy = p1[1] - p2[1];

        return Math.hypot(dx, dy);
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

    static collision(b1, b2) {
        // return b1.x < b2.x + b2.w && b1.x + b1.w > b2.x && b1.y < b2.y + b2.h && b1.h + b1.y > b2.y
        //
        b1.get_center();
        b2.get_center();

        b1.get_diagonal();
        b2.get_diagonal();

        return Blob.distance(b1.center, b2.center) < (b1.diagonal + b2.diagonal) / 2;
    }

    static inside(outside, inside) {
        let x_o = outside.rect[0];
        let y_o = outside.rect[1];
        let w_o = outside.rect[2];
        let h_o = outside.rect[3];

        let x_i = inside.rect[0];
        let y_i = inside.rect[1];
        let h_i = inside.rect[2];
        let w_i = inside.rect[3];

        return x_i > x_o && y_i > y_o && x_i + w_i < x_o + w_o && y_i + h_i < y_o + h_o;
    }

    //emulate gravity
    gravity() {
        this.velY *= .99;
        this.velY += .25;
    }

    draw_blob(canvas) {
        if (this.exists) {
            const ctx_blob = canvas.getContext('2d');

            // update velX, velY
            if (!this.anti_gravity) this.gravity();
            this.rect[0] += this.velX;
            this.rect[1] += this.velY;

            ctx_blob.drawImage(this.image,
                Math.floor(this.rect[0]),
                Math.floor(this.rect[1]),
                this.rect[2],
                this.rect[3]);
            // console.log('blob is drawing');
        }
    }

    draw_trace(canvas) {
        if (this.exists) {
            const ctx_tracing = canvas.getContext('2d');

            let x = this.center[0];
            let y = this.center[1];

            if (this.trace) {
                this.get_center();
                Blob.line(ctx_tracing, x, y, this.center[0], this.center[1]);
            }
            // console.log('blob is drawing');
        }
    }
}

class Blobs {
    constructor() {
        // collection of blobs, in which this blob belong to
        this.blobs = [];
    }

    register(blobs) {
        blobs.forEach((blob) => {
            this.blobs.push(blob);
        });
    }

    //hit border return
    border(blob, canvas) {
        if (blob.rect[0] <= 0) {
            return "left";
        }
        if ((blob.rect[0] + blob.rect[2]) >= canvas.width) {
            return "right";
        }
        if (blob.rect[1] <= 0) {
            return "top";
        }
        if ((blob.rect[1] + blob.rect[3]) >= canvas.height) {
            return "bottom";
        }
    }

    //canvas_layer = {'blob': blobCanvas, 'trace': traceCanvas}
    draw(canvas_layer) {
        this.blobs.forEach((blob) => {
            if (blob.exists) {
                // update velX, velY
                this.detect_blob_collision(blob);
                this.detect_border_collision(blob, canvas_layer['blob']);

                blob.draw_blob(canvas_layer['blob']);
                blob.draw_trace(canvas_layer['trace']);
            }
        });
    }

    //change directions while reach border
    detect_border_collision(blob, canvas) {
        if (this.border(blob, canvas) === "left" || (this.border(blob, canvas) === "right")) {
            blob.velX = -(blob.velX);
        }
        if (this.border(blob, canvas) === "top" || (this.border(blob, canvas) === "bottom")) {
            blob.velY = -(blob.velY);
        }
    }

    //change directions while collision
    detect_blob_collision(blob) {
        for (let j = 0; j < this.blobs.length; j++) {
            if (blob !== this.blobs[j] && this.blobs[j].exists) {
                if (Blob.collision(blob, this.blobs[j])) {
                    blob.get_center();
                    // this.get_velocity();

                    const dx = blob.center[0] - this.blobs[j].center[0];
                    const dy = blob.center[1] - this.blobs[j].center[1];
                    const distance = Blob.distance(blob.center, this.blobs[j].center);

                    blob.velX = Math.floor(blob.velocity * dx / distance);
                    blob.velY = Math.floor(blob.velocity * dy / distance);

                    this.blobs[j].velX = -Math.floor(this.blobs[j].velocity * dx / distance);
                    this.blobs[j].velY = -Math.floor(this.blobs[j].velocity * dy / distance);
                }
            }
        }
    }

}

class Food {
    constructor(canvas) {
        this.x = 0;
        this.y = 0;
        this.b = 10;

        this.w = this.b;
        this.h = this.b;

        this.color = 'red';
        this.bowl = 'yellow';
        this.canvas = canvas;

        this.renew();   // set food random locations
        this.serve();   // draw foods
    }

    renew() {
        this.x = Math.floor(Math.random() * (this.canvas.width - 200) + 10);
        this.y = Math.floor(Math.random() * (this.canvas.height - 200) + 30);
    }

    serve() {
        const ctx = this.canvas.getContext('2d');

        ctx.beginPath();    //draw food
        ctx.lineWidth = 1;
        ctx.fillStyle = this.color;
        ctx.arc(this.x, this.y, this.b - 5, 0, 2 * Math.PI);
        ctx.fill();

        ctx.beginPath();    //draw bawl
        ctx.arc(this.x, this.y, this.b - 5, 0, Math.PI);
        ctx.strokeStyle = this.bowl;
        ctx.lineWidth = 10;
        ctx.stroke();

    }
}

class Snake {
    constructor(canvas) {
        this.w = 15;
        this.h = 15;
        this.canvas = canvas;

        this.snake = [];

        //init snake in the middle of canvas
        let body = {
            x: canvas.width / 2,
            y: canvas.height / 2
        };

        //assign 5 snake body object {x:, y:} to snake array []
        for (let i = 0; i < 5; i++) {
            this.snake.push(Object.assign({}, body));
            body.x += this.w;
        }
        console.log(this.snake);

        this.foods = [];
        //10 foods
        for (let i = 0; i < 10; i++) this.foods.push(new Food(canvas));
    }

    eat(food) {
        return this.snake[0].x < food.x + food.w
            && this.snake[0].x + this.w > food.x
            && this.snake[0].y < food.y + food.h
            && this.h + this.snake[0].y > food.y;
    }

    //update snake positions according to arrow keys
    move_on(key) {
        const ctx = this.canvas.getContext('2d');
        let arrow_key = key && key.search("Arrow") > -1;
        let food_number = -1;

        if (arrow_key) {
            // arrayLike is now iterable, spread operator is used to extract
            // its elements into an array: [...arrayLike]
            let head = {
                ...this.snake[0]
            };

            "ArrowUp" === key && (head.y -= this.h);
            "ArrowDown" === key && (head.y += this.h);
            "ArrowLeft" === key && (head.x -= this.w);
            "ArrowRight" === key && (head.x += this.w);

            head.x >= this.canvas.width ? head.x = 0 : head.x < 0 && (head.x = this.canvas.width - this.w);
            head.y > this.canvas.height ? head.y = 0 : head.y < 0 && (head.y = this.canvas.height);

            //returns the index of the first element in the array that satisfies the provided testing function
            food_number = this.foods.findIndex(food => this.eat(food));

            //adds one or more elements to the beginning of an array and returns the new length of the array.
            this.snake.unshift(head);

            //food was eaten, and return without pop last snake body. (added one body)
            if (-1 !== food_number) {
                this.foods[food_number].renew(ctx);
                document.getElementById("score").innerText = Number(document.getElementById("score").innerText) + 1 + '';
                return console.log(`eat item: ${food_number}`);
            }
            this.snake.pop();
        }

        // forEach callback function:
        // the value of the element
        // the index of the element
        // the Array object being traversed
        this.snake.forEach((body, idx, snake) => {
            // snake body
            ctx.beginPath();    //green body
            ctx.fillStyle = "#37ea18";
            ctx.fillRect(body.x, body.y, this.w, this.h);
            ctx.arc(body.x + 10, body.y + 2, 5, 360, 0);
            ctx.fill();

            ctx.beginPath();    // red texture
            ctx.lineWidth = 1;
            ctx.strokeStyle = "#961e5c";
            snake.length - 1 !== idx && 0 !== idx && ctx.strokeRect(body.x, body.y, this.w, this.h);

            // snake head
            if (0 === idx) {
                ctx.beginPath();
                ctx.fillStyle = "#ead518";  // yellow head
                ctx.fillRect(body.x, body.y, this.w, this.h);
                ctx.fillStyle = "#ea18c7";  // red eyes
                ctx.arc(body.x + 10, body.y + 2, 8, 360, 0);
                ctx.fill();
            }
        })
    }
}

export {$, Point, bezierCurve, Blob, Blobs, Snake}
