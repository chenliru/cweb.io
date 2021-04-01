// Task: Implement a class named 'RangeList'
/* A pair of integers define a range, for example: [1, 5). This range includes integers: 1, 2, 3, and 4.
/* A range list is an aggregate of these ranges: [1, 5), [10, 11), [100, 201)
/**
*
* NOTE: Feel free to add any extra member variables/functions you like.
*/

/*
 You are free to use and modify this code in anyway you find useful. Please leave this comment in the code
 to acknowledge its original source. If you feel like it, I enjoy hearing about projects that use my code,
 but don't feel like you have to let me know or ask permission.

 author: chenliru@yahoo.com

*/

class RangeList {
    constructor() {
        // Array holds all added ranges(objects)
        this.range_list = [];
    }

    /**
     * Check ranges position relationship: in, out, left, right
     * @param {Object<number>} range, - Object of two properties(integers) that specify
     beginning and end of range.
     * @param {Object<number>} new_range, - Object of two properties(integers) that specify
     beginning and end of range.
     */
    static intersection(new_range, range) {
        return range.start <= new_range.start && new_range.start <= range.end
            || range.start <= new_range.end && new_range.end <= range.end
            || new_range.start <= range.start && range.start <= new_range.end
            || new_range.start <= range.end && range.end <= new_range.end;
    }

    // "new range" in "range"
    static in(new_range, range) {
        return RangeList.intersection(new_range, range)
            && range.start <= new_range.start && new_range.end <= range.end;
    }

    // "new range" outside "range", ("range" in "new range")
    static out(new_range, range) {
        return RangeList.intersection(new_range, range)
            && new_range.start <= range.start && range.end <= new_range.end;
    }

    // "new range" on the left hand side of "range"
    static left(new_range, range) {
        return RangeList.intersection(new_range, range)
            && new_range.start <= range.start && new_range.end <= range.end;
    }

    // "new range" on the right hand side of "range"
    static right(new_range, range) {
        return RangeList.intersection(new_range, range)
            && range.start <= new_range.start && range.end <= new_range.end;
    }

    /**
     * Adds a range to the list
     * @param {Array<number>} range - Array of two integers that specify
     beginning and end of range.
     */
    add(range) {
        // TODO: implement this
        let new_range = {
            start: Math.min(...range),
            end: Math.max(...range)     // end always bigger than start
        };

        let intersection = false;
        // console.log("intersection", RangeList.intersection(new_range, range), new_range, range)

        for (let range of this.range_list) {
            if (RangeList.intersection(new_range, range)) {
                range.start = Math.min(new_range.start, range.start);
                range.end = Math.max(new_range.end, range.end);
                intersection = true
            }
        }

        if (!intersection) {
            this.range_list.push(new_range);
        }
    }

    /**
     * Removes a range from the list
     * @param {Array<number>} range - Array of two integers that specify
     beginning and end of range.
     */
    remove(range) {
    // TODO: implement this
        let new_range = {
            start: Math.min(...range),
            end: Math.max(...range)     // end always bigger than start
        };

        let split_range;    // split range when new_range in it
        let boolean_split_range = false;

        let idx_range = []; // holds RangeList index which item should be removed when new_range cover it
        let boolean_idx_range = false;

        let idx = -1;

        for (let range of this.range_list) {
            ++idx;  // idx always start from 0
            if (RangeList.out(new_range, range)) {
                idx_range.push(idx);
                boolean_idx_range = true;
                continue;
            }

            // console.log("left", RangeList.left(new_range, range), new_range, range)
            if (RangeList.left(new_range, range)) {
                range.start = new_range.end;
                continue;
            }

            // console.log("right", RangeList.right(new_range, range), new_range, range)
            if (RangeList.right(new_range, range)) {
                range.end = new_range.start;
                continue;
            }

            // console.log("in", RangeList.in(new_range, range), new_range, range)
            if (RangeList.in(new_range, range)) {
                split_range = {
                    start : new_range.end,
                    end : range.end
                };
                boolean_split_range = true
                console.log("split_range", split_range);

                range.end = new_range.start;
            }

        }

        if(boolean_split_range) this.range_list.push(split_range);
        if(boolean_idx_range) {
            idx_range.forEach(idx => {
                this.range_list.splice(idx, idx);
            })
        }

    }

    /**
     * Prints out the list of ranges in the range list
     */
    print() {
    // TODO: implement this
        console.log("start log: ")
        this.range_list.forEach(range => {
            console.log(range.start, range.end);
            alert(`[${range.start}, ${range.end})`);
        })
    }
}


// Example run
const rl = new RangeList();
rl.add([1, 5]);
rl.print();
// Should display: [1, 5)
rl.add([10, 20]);
rl.print();
// Should display: [1, 5) [10, 20)
rl.add([20, 20]);
rl.print();
// Should display: [1, 5) [10, 20)
rl.add([20, 21]);
rl.print();
// Should display: [1, 5) [10, 21)
rl.add([2, 4]);
rl.print();
// Should display: [1, 5) [10, 21)
rl.add([3, 8]);
rl.print();
// Should display: [1, 8) [10, 21)
rl.remove([10, 10]);
rl.print();
// Should display: [1, 8) [10, 21)
rl.remove([10, 11]);
rl.print();
// Should display: [1, 8) [11, 21)
rl.remove([15, 17]);
rl.print();
// Should display: [1, 8) [11, 15) [17, 21)
rl.remove([3, 19]);
rl.print();
// Should display: [1, 3) [19, 21)