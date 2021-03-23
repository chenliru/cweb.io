/*
 You are free to use and modify this code in anyway you find useful. Please leave this comment in the code
 to acknowledge its original source. If you feel like it, I enjoy hearing about projects that use my code,
 but don't feel like you have to let me know or ask permission.

 author: chenliru@yahoo.com

*/

import {$} from "../cweb.js";

let audioInputMenu;
let audioOutputMenu;
let videoMenu;
let screenButton;

audioInputMenu = document.querySelector('#audioInputSourceMenu');
audioOutputMenu = document.querySelector('#audioOutputSourceMenu');
videoMenu = document.querySelector('#videoSourceMenu');
screenButton = document.querySelector('#screenInputSourceButton');

let video;
video = document.querySelector('#video');
if (!video) {
    video = document.createElement('video');
}

let startRecordButton;
let stopRecordButton;

startRecordButton = document.querySelector('#record');
stopRecordButton = document.querySelector('#stop');
stopRecordButton.disabled = true;


let downloadLink;
downloadLink = document.querySelector('#download');

let mainControls;
mainControls = document.querySelector('.main-controls');

let replay;
replay = document.querySelector('#replay');

class VideoCapture {
    constructor(video, videoIDX = 0, audioIDX = 0) {
        this.video = video;
        this.videoIDX = videoIDX;
        this.audioIDX = audioIDX;

        this.size = [1024, 768];
        this.boolean_record = false;
    }

    setSize(width, height) {
        this.size[0] = width;
        this.size[1] = height;
    }

    //
    setRecord(boolean_record) {
        this.boolean_record = boolean_record;
    }

    //Define cameras and microphones.
    start() {
        const _this = this;
        if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
            console.log("enumerateDevices() not supported.");
            return;
        }

        let audio;
        let video;
        let stream;
        navigator.mediaDevices.enumerateDevices().then(function (devices) {
            let i = 0;
            let j = 0;
            let k = 0;

            devices.forEach(device => {
                // console.log(device.kind + ": " + device.label + " id = " + device.deviceId);
                const li = document.createElement("li");
                const a = document.createElement("a");

                function addMenu(menu, device, num) {
                    a.innerHTML = device.label || `device ${num}`;
                    a.setAttribute("class", "dropdown-item");
                    a.setAttribute("href", "#");
                    a.addEventListener("click", (e) => {
                        if (device.kind === 'audioinput') {
                            audio = device.deviceId;
                        } else if (device.kind === 'videoinput') {
                            video = device.deviceId;
                        }
                        stream = _this.device(audio, video)
                    })
                    menu.appendChild(li).appendChild(a);
                }

                if (device.kind === 'audioinput') {
                    // if(i === this.audioIDX) this.audioInputLabel = device.label;
                    if (i === _this.audioIDX) audio = device.deviceId;
                    i++;
                    if (audioInputMenu) {
                        addMenu(audioInputMenu, device, i);
                    }
                } else if (device.kind === 'audiooutput') {
                    // if(j === this.audioIDX) this.audioOutputLabel = device.label;
                    // if(j === this.audioIDX) this.audioOutputID = device.deviceId;
                    j++;
                    if (audioOutputMenu) {
                        addMenu(audioOutputMenu, device, j);
                    }
                } else if (device.kind === 'videoinput') {
                    // if(k === this.videoIDX) this.videoLabel = device.label;
                    if (k === _this.videoIDX) video = device.deviceId;
                    k++;
                    if (videoMenu) {
                        addMenu(videoMenu, device, k);
                    }
                } else {
                    console.log('Some other kind of source/device: ', device);
                }
            });

            //
            stream = _this.device(audio, video);
            console.log('device ALL: ', audio, video, stream);

        }).catch(function (err) {
            console.log('device error: ', err.name + ": " + err.message);
        });
    }

    async device(audio, video) {
        const _this = this;
        if (window.stream) {
            window.stream.getTracks().forEach(track => {
                track.stop();
            });
        }

        const constraints = {
            audio: {
                deviceId: audio,
                echoCancellation: true,  // fix echo issues
            },
            video: {
                deviceId: video,
                width: {ideal: _this.size[0]},
                height: {ideal: _this.size[1]},
            }
        };

        // window.constraints = constraints;   // make constrains available to browser console
        console.log('Got stream with constraints:', constraints);

        let stream;
        try {
            stream = await navigator.mediaDevices.getUserMedia(constraints);
            window.stream = stream;
            _this.mediaStream(stream);    // get user media successfully
        } catch (e) {
            console.error('navigator.getUserMedia error:', e);
        }  // always check for errors at the end.

        screenButton.addEventListener("click", async (e) => {
            let displayMediaOptions = {
                video: true,
                audio: {
                    echoCancellation: true,  // fix echo issues
                }
            };
            if (window.stream) {
                window.stream.getTracks().forEach(track => {
                    track.stop();
                });
            }
            try {
                stream = await navigator.mediaDevices.getDisplayMedia(displayMediaOptions);
                window.stream = stream;
                _this.mediaStream(stream);    // get user media successfully
            } catch (e) {
                console.error('navigator.getDisplayMedia error:', e);
            }

        })
    }

    // media stream process here
    mediaStream(stream) {
        const _this = this;
        const audioTracks = stream.getAudioTracks();
        const videoTracks = stream.getVideoTracks();
        console.log('Using audio device: ', audioTracks);
        console.log('Using video device: ', videoTracks);

        // window.stream = stream;    // make stream available to browser console
        this.video.srcObject = stream;

        if (this.boolean_record) {
            startRecordButton.onclick = function () {
                _this.record(stream).then(_this.download);
                startRecordButton.disabled = true;
                stopRecordButton.disabled = false;
            };
            stopRecordButton.onclick = function () {
                _this.stop(stream);
                startRecordButton.disabled = false;
                stopRecordButton.disabled = true;
            };
        }

        // demonstrates how to detect that the user has stopped
        // sharing the screen via the browser UI.
        stream.getVideoTracks()[0].addEventListener('ended', () => {
            console.log('The user has ended Media Source');
        });
    }

    record(stream) {
        let recorder = new MediaRecorder(stream);
        let data = [];

        recorder.ondataavailable = event => data.push(event.data);
        recorder.start();

        let stopped = new Promise((resolve, reject) => {
            recorder.onstop = resolve;
            recorder.onerror = event => reject(event.name);
        });

        return Promise.all([
            stopped,
        ]).then(() => data);    // Once that resolves, the array data is returned
    }

    download(data) {
        const _this = this;
        let recordedBlob = new Blob(data, {type: "video/webm"});

        // downloadLink.href = URL.createObjectURL(recordedBlob);

        const clipName = prompt('Enter a name for your sound clip?', 'My unnamed clip');

        const clipContainer = document.createElement('article');
        const clipLabel = document.createElement('a');
        const video = document.createElement('video');
        const deleteButton = document.createElement('button');

        clipContainer.classList.add('clip');
        video.setAttribute('controls', '');
        deleteButton.textContent = 'Delete';
        deleteButton.className = 'delete';

        if (clipName === null) {
            clipLabel.textContent = 'My unnamed clip';
        } else {
            clipLabel.textContent = clipName;
        }

        clipContainer.appendChild(video);
        clipContainer.appendChild(clipLabel);
        clipContainer.appendChild(deleteButton);
        mainControls.appendChild(clipContainer);

        // let name = "RecordedVideo" + (new Date().toISOString()) + ".webm";
        // downloadLink.download = clipName;

        video.controls = true;
        video.src = URL.createObjectURL(recordedBlob);
        console.log("recorder stopped");

        deleteButton.onclick = function (e) {
            let evtTgt = e.target;
            evtTgt.parentNode.parentNode.removeChild(evtTgt.parentNode);
        }

        clipLabel.href = URL.createObjectURL(recordedBlob);
        clipLabel.download = clipLabel.textContent;

        console.log("Successfully recorded " + recordedBlob.size + " bytes of " +
            recordedBlob.type + " media.");
    }

    stop(stream) {
        stream.getTracks().forEach(track => track.stop());
        console.log("data available after MediaRecorder.stop() called.");
    }
}

// test VideoCapture basic function, open camera and show video:
const cam = new VideoCapture(video, 0, 0);
cam.setSize(640, 480);
cam.setRecord(true);
cam.start();

// Filter camera using css
const filterSelects = document.querySelectorAll('.filter');
filterSelects.forEach((filter) => {
    filter.addEventListener("click", (e) => {
        video.className = filter.innerHTML;
    })
});


// SnapShot
let snapshotButton;
snapshotButton = document.querySelector('#snapshot');

snapshotButton.onclick = function () {
    const div = document.createElement('div');
    const button = document.createElement('button');
    const canvas = document.createElement('canvas');
    canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);

    div.className = "alert alert-info alert-dismissible fade show";
    div.setAttribute("role", "alert");
    div.appendChild(canvas);
    button.className = "btn-close"
    button.type = "button";
    button.setAttribute("data-bs-dismiss", "alert");
    button.setAttribute("aria-label", "Close");
    div.appendChild(button);
    mainControls.appendChild(div, mainControls.childNodes[2]);
};
