package com.dataoversound;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;

/** DataoversoundPlugin */
public class DataoversoundPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native
    /// Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine
    /// and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private AudioQRRecorder wavRecorder;
    private AudioTrack myTone = null;

    private boolean isRecording = false;

    private static final String LOG_TAG = "DataOverSoundMain";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "dataoversound");
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It
    // supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new
    // Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith
    // to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith
    // will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both
    // be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "dataoversound");

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
        case "registerAudio":
            registerAudio();

            if (myTone != null) {
                result.success("Audio Track set");
            } else {
                result.error("UNAVAILABLE", "Unable to register AudioTrack.", null);
            }
            break;
        case "releaseTone":
            releaseTone();
            if (myTone != null) {
                result.success("Tone Released");
            } else {
                result.error("UNAVAILABLE", "Unable to release AudioTrack", null);
            }
            break;
        case "playTone":
            byte[] generatedSnd = call.argument("generatedSnd");
            playTone(generatedSnd);
            if (myTone != null) {
                result.success("Tone Played");
            } else {
                result.error("UNAVAILABLE", "Unable to play AudioTrack", null);
            }
            break;
        case "start":
            Log.d(LOG_TAG, "Start");
            startWavRecording();
            isRecording = true;
            result.success("stop");
            break;
        case "stop":
            Log.d(LOG_TAG, "Stop");
            stopWavRecording();
            isRecording = false;
            result.success("Recording Finished");
            break;
        case "isRecording":
            Log.d(LOG_TAG, "Get isRecording");
            result.success(isRecording);
            break;
        /*
         * case "hasPermissions": Log.d(LOG_TAG, "Get hasPermissions"); Context context
         * = this; PackageManager pm = context.getPackageManager(); int hasStoragePerm =
         * pm.checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE,
         * context.getPackageName()); int hasRecordPerm =
         * pm.checkPermission(Manifest.permission.RECORD_AUDIO,
         * context.getPackageName()); boolean hasPermissions = hasStoragePerm ==
         * PackageManager.PERMISSION_GRANTED && hasRecordPerm ==
         * PackageManager.PERMISSION_GRANTED; result.success(hasPermissions); break;
         */
        default:
            result.notImplemented();
            break;
        }

    }

    private void registerAudio() {
        int sampleRate = 44100;
        int bufferSize = AudioTrack.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT);
        myTone = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate, AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT, bufferSize, AudioTrack.MODE_STREAM);
        myTone.play();
    }

    private void playTone(byte[] generatedSnd) {
        myTone.write(generatedSnd, 0, generatedSnd.length);
    }

    private void releaseTone() {
        myTone.release();
    }

    private void startWavRecording() {
        wavRecorder = new AudioQRRecorder(channel);
        wavRecorder.startRecording();
    }

    private void stopWavRecording() {
        wavRecorder.stopRecording();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
