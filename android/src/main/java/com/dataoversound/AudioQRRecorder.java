package com.dataoversound;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Handler;
import android.os.Looper;
import android.os.Process;
import android.util.Log;

import io.flutter.plugin.common.MethodChannel;

public class AudioQRRecorder {
    private static final int audioSource = MediaRecorder.AudioSource.DEFAULT;
    //Mono=8b, Stereo=16b
    private  static final int channelConfig = AudioFormat.CHANNEL_IN_MONO;
    //16b or 8b per sample
    private  static final int audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
    //Number of samples in 1sec
    private int sampleRate = 44100;
    //Recording thread;

    private AudioRecord recorder = null;
    private int minBufferSize = 0;
    private Thread recordingThread = null;
    private boolean isRecording = false;
    private int optimalBufSize = 12000;

    private MethodChannel audioChannel;
    private static final String LOG_TAG = "AudioRecorder";

    public AudioQRRecorder(MethodChannel CHANNEL) {
         minBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioEncoding);
        audioChannel = CHANNEL;
    }

    public void startRecording() {

        optimalBufSize = 12000;
        if (optimalBufSize < minBufferSize) {
            optimalBufSize = minBufferSize;
        }
        //Sets the chosen buffer size in analyzing (father) Dart code

        //Create recorder
        recorder = new AudioRecord(audioSource, sampleRate, channelConfig, audioEncoding, optimalBufSize);
        audioChannel.invokeMethod("setBufferSize",  optimalBufSize);
        int i = recorder.getState();
        if (i == 1)
            recorder.startRecording();

        isRecording = true;

        recordingThread = new Thread(new Runnable() {
            @Override
            public void run() {
                Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO);
                writeAudioDataToFile();
            }
        }, "AudioRecorder Thread");

        recordingThread.start();
    }

    private void writeAudioDataToFile() {

        if (recorder.getState() == AudioRecord.STATE_UNINITIALIZED) {
            Thread.currentThread().interrupt();
            return;
        } else {
            Log.i(LOG_TAG, "Started. without interruption");
        }

       final byte[] buffer = new byte[minBufferSize];
        // byte data[] = new byte[minBufferSize];



            while (isRecording &&  (recorder.read(buffer, 0, minBufferSize)) > 0) {

                if (recorder.getState() != AudioRecord.STATE_UNINITIALIZED) {
                    try {
                        new Handler(Looper.getMainLooper()).post(new Runnable() {
                            @Override
                            public void run() {
                                audioChannel.invokeMethod("onBufferAvailable", buffer);
                            }
                        });
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }



    }

    public void stopRecording() {
        if (null != recorder) {
            isRecording = false;

            int i = recorder.getState();
            if (i == 1)
                recorder.stop();
            recorder.release();

            recorder = null;
            recordingThread = null;
        }
    }





}