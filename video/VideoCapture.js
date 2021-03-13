import {$} from "../cweb.js";


const video = $("videoID");
const video2 = $("videoID-Second");
const stopRecord = $("stopRecord")
const downloadButton = $("download")


class VideoCapture {

    constructor(video, videoIDX, audioIDX) {
        this.video = video;
        this.videoIDX = videoIDX;
        this.audioIDX = audioIDX;
        this.size = [1024, 768];
        this.source = 'user';
        this.boolean_record = false;
    }

    setSize(width, height) {
        this.size[0] = width;
        this.size[1] = height;
    }

    // 'user', 'display'
    setSource(source) {
        this.source = source;
    }

    //
    setRecord(boolean_record) {
        this.boolean_record = boolean_record;
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

            //
            const stream = _this.device(audio, video);
            console.log('device ALL: ', audio, video, stream);
            return stream;

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
            audio: {deviceId: audio},
            video: {
                width: {ideal: _this.size[0]},
                height: {ideal: _this.size[1]},
                deviceId: video
            }
        };

        // window.constraints = constraints;   // make constrains available to browser console
        console.log('Got stream with constraints:', constraints);

        let stream;
        try {
            if (_this.source === 'display') {
                stream = await navigator.mediaDevices.getDisplayMedia(constraints);
            } else if (_this.source === 'user') {
                stream = await navigator.mediaDevices.getUserMedia(constraints);
            } else {
                stream = undefined;
            }
            _this.mediaStream(stream);    // get user media successfully
            return stream;
        } catch (e) {
            console.error('navigator.getUserMedia error:', e);
        }  // always check for errors at the end.
    }

    // media stream process here
    mediaStream(stream) {
        const videoTracks = stream.getVideoTracks();
        const audioTracks = stream.getAudioTracks();
        console.log('Using video device: ', videoTracks);
        console.log('Using video device: ', audioTracks);

        // window.stream = stream;    // make stream available to browser console
        this.video.srcObject = stream;

        if(this.boolean_record) this.record(stream).then(this.download);
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

        stopRecord.addEventListener('click', ()=>{
            recorder.stop();
            this.stop(stream);
        })

        return Promise.all([
            stopped,
        ]).then(() => data);    // Once that resolves, the array data is returned
    }

    download(data) {
        let recordedBlob = new Blob(data, {type: "video/webm"});
        downloadButton.href = URL.createObjectURL(recordedBlob);
        downloadButton.download = "RecordedVideo.webm";

        console.log("Successfully recorded " + recordedBlob.size + " bytes of " +
            recordedBlob.type + " media.");
    }

    stop(stream) {
        stream.getTracks().forEach(track => track.stop());
    }
}

const cam = new VideoCapture(video, 2, 0);
cam.setSize(1280, 720);
cam.start();

const cam2 = new VideoCapture(video2, 0, 1);
cam2.setSize(640, 480);
cam2.setSource('display')
cam2.setRecord(true)
cam2.start();

document.addEventListener('dblclick', () => {
    cam2.setRecord(false);
});
