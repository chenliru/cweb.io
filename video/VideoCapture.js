import {$} from "../cweb.js";


const video = $("videoID");
const video2 = $("videoID-Second");


class VideoCapture {

    constructor(video, videoIDX, audioIDX) {
        this.video = video;
        this.videoIDX = videoIDX;
        this.audioIDX = audioIDX;
        this.size = [1024, 768];
    }

    setSize(width, height) {
        this.size[0] = width;
        this.size[1] = height;
    }

    //Define cameras and microphones.
    start() {
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

            const stream = _this.getMedia(audio, video);
            console.log('device ALL: ', audio, video, stream);
            return stream;

        }).catch(function (err) {
            console.log('device error: ', err.name + ": " + err.message);
        });
    }

    async getMedia(audio, video) {
        const _this = this;
        if (window.stream) {
            window.stream.getTracks().forEach(track => {
                track.stop();
            });
        }

        const constraints = {
            audio: {deviceId: audio},
            video: {
                width: {ideal: _this.size[0]},
                height: {ideal: _this.size[1]},
                deviceId: video
            }
        };

        window.constraints = constraints;   // make constrains available to browser console
        console.log('Got stream with constraints:', constraints);

        try {
            const stream = await navigator.mediaDevices.getUserMedia(constraints);
            _this.mediaStream(stream);    // get user media successfully
            return stream;
        } catch (e) {
            console.error('navigator.getUserMedia error:', e);
        }  // always check for errors at the end.
    }

    mediaStream(stream) {
        const videoTracks = stream.getVideoTracks();
        console.log(`Using video device: ${videoTracks[0].label}`);
        // media stream process here:
        window.stream = stream;    // make stream available to browser console
        this.video.srcObject = stream;
    }
}

let cam = new VideoCapture(video, 2, 0);
cam.setSize(1280, 720);
const stream = cam.start();

let cam2 = new VideoCapture(video2, 0, 1);
cam2.setSize(640, 480);
cam2.start()
