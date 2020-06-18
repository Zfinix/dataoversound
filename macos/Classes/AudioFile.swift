//
//  AudioFile.swift
//  Runner
//
//  Created by Chiziaruhoma Ogbonda on 02/04/2020.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

struct readFile {
    static var arrayFloatValues:[Float] = []
    static var points:[CGFloat] = []
}

let audioEngine: AVAudioEngine = AVAudioEngine()
let audioPlayer: AVAudioPlayerNode = AVAudioPlayerNode()

class AudioAnalisys : NSObject {
    
    class func open_audiofile(url:URL) {
        var audioFile:AVAudioFile;
        var audioFileBuffer:AVAudioPCMBuffer;
        
        do{
            audioFile = try AVAudioFile(forReading: url)
            print(url)
            let audioFormat = audioFile.processingFormat
            _ = UInt32(audioFile.length)
            //how many channels?
            //print(audioFile.fileFormat.channelCount)
            
            //Setup the buffer for audio data
            
            do{
                audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(audioFile.length))!
                //put audio data in the buffer
                try audioFile.read(into: audioFileBuffer)
                let mainMixer = audioEngine.mainMixerNode
                audioEngine.attach(audioPlayer)
                audioPlayer.volume = 10;
                audioEngine.connect(audioPlayer, to:mainMixer, format: audioFileBuffer.format)
                audioPlayer.scheduleBuffer(audioFileBuffer, completionHandler: nil)
                audioEngine.prepare()
                
                //readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: audioFileBuffer!.floatChannelData?[0], count:Int(audioFileBuffer!.frameLength)))
                do {
                    try audioEngine.start()
                    print("engine started")
                } catch let error {
                    print(error)
                }
                audioPlayer.play()
            }catch let error{
                
                print(error)
            }
            
            
            //Init engine and player
            
        }catch let error{
            
            print(error)
        }
        //put it in an AVAudioFile
        
        //Get the audio file format
        //let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        
        
        
    }
}
