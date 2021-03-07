// Grab elements, create settings, etc.
//By David Walsh on November 7, 2012

// Elements for taking the snapshot
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');
const video = document.getElementById('video');

// Get access to the camera!
// if(navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
//     // Not adding `{ audio: true }` since we only want video now
//     navigator.mediaDevices.getUserMedia({ video: true }).then(function(stream) {
//         //video.src = window.URL.createObjectURL(stream);
//         video.srcObject = stream;
//         video.play();
//     });
// }
// Prefer camera resolution nearest to 1280x720.
const constraints = {
    audio: {
      autoplay: false
    },
    video: {
        width: 1280,
        height: 720,
        autoplay: false
    }
};

navigator.mediaDevices.getUserMedia(constraints)
    .then(function (mediaStream) {
        // const video = document.querySelector('video');
        video.srcObject = mediaStream;
        video.onloadedmetadata = function (e) {
            // video.muted = true
            video.play();
        };
    })
    .catch(function (err) {
        console.log(err.name + ": " + err.message);
    });

// Trigger photo take
document.getElementById("snap").addEventListener("click", function () {
    context.drawImage(video, 0, 0, 640, 480);
});

function playPause() {
    if (video.paused)
        video.play();
    else
        video.pause();
}

function makeBig() {
    video.width = 780;
}

function makeSmall() {
    video.width = 320;
}

function makeNormal() {
    video.width = 640;
}