import {$} from "../cweb.js";


const video = $("videoID");

class VideoCapture {
    constructor(videoIDX, audioIDX) {
        this.videoIDX = videoIDX;
        this.audioIDX = audioIDX;

        this.devices()
    }

    //Define cameras and microphones.
    devices() {
        const _this = this;
        let audio;
        let video;
        if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
            console.log("enumerateDevices() not supported.");
            return;
        }

        navigator.mediaDevices.enumerateDevices().then(function (devices) {
            let i = 0;
            let j = 0;
            let k = 0;

            devices.forEach(function (device) {
                // console.log(device.kind + ": " + device.label + " id = " + device.deviceId);

                if (device.kind === 'audioinput') {
                    // if(i === this.audioIDX) this.audioInputLabel = device.label;
                    if (i === _this.audioIDX) audio = device.deviceId;
                    i++;
                } else if (device.kind === 'audiooutput') {
                    // if(j === this.audioIDX) this.audioOutputLabel = device.label;
                    // if(j === this.audioIDX) this.audioOutputID = device.deviceId;
                    j++;
                } else if (device.kind === 'videoinput') {
                    // if(k === this.videoIDX) this.videoLabel = device.label;
                    if (k === _this.videoIDX) video = device.deviceId;
                    k++;
                } else {
                    console.log('Some other kind of source/device: ', device);
                }
            });

            _this.start(audio, video);
            console.log('device ALL: ', audio, video);

        }).catch(function (err) {
            console.log('device error: ', err.name + ": " + err.message);
        });
    }

    async getMedia(constraints) {
        let stream = null;

        try {
            stream = await navigator.mediaDevices.getUserMedia(constraints);
            /* use the stream */
            window.stream = stream;
            video.srcObject = stream;
            video.onloadedmetadata = function () {
                video.play();
            };

        } catch (err) {
            /* handle the error */
            console.log('get media error: ', err.name + ": " + err.message);
        }

    }

    start(audio, video) {
        if (window.stream) {
            window.stream.getTracks().forEach(track => {
                track.stop();
            });
        }

        const constraints = {
            audio: {deviceId: audio},
            video: {deviceId: video}
        };

        const promise = this.getMedia(constraints);
    }
}

new VideoCapture(2, 2);
