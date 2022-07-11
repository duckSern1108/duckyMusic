//
//  AudioPlayerViewController.swift
//  DuckyMusic
//
//  Created by ghtk on 08/07/2022.
//

import UIKit
import AVFoundation
import PromiseKit

class AudioPlayerViewController: UIViewController {
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playButton:UIButton?
    
    var updateSliderTimer:Timer?
    
    let duration: Float = 30000
    let incrementPerSec:Float = 1000
    
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var durationSlider: UISlider!
    @IBAction func onPlayBtnTap(_ sender: Any) {
        if player?.rate == 0 {
            playAudio()
            
        } else {
            pauseAudio()
        }
    }
    
    func playAudio() {
        updateSliderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDurationSlider), userInfo: nil, repeats: true)
        player!.play()
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func pauseAudio() {
        updateSliderTimer?.invalidate()
        player!.pause()
        playBtn.setImage(UIImage(systemName: "play.fill" ), for: .normal)
    }
    @IBOutlet weak var playBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        durationSlider.minimumValue = 0
        durationSlider.maximumValue = duration
        volumeSlider.value = 0.5
        durationSlider.value = 0
        player?.volume = 0.5
        maxDurationLabel.text = convertMsToMinuteAndSecond(ms: duration)
        firstly {
            AlbumRouter.getNewRelease()
        }.done {
            result in
            print("albums :: ",result)
        }.catch {
            err in
            print(err)
        }
    }
    
    func convertMsToMinuteAndSecond(ms: Float) -> String {
        let minute = (ms / 60000).rounded(.down)
        let seconds = (ms - minute * 60000) / 1000
        let minuteDisplay = "\(Int(minute))"
        let secondsDisplay = "\(Int(seconds))"
        return minuteDisplay + ":" + secondsDisplay
    }
    
    @objc func updateDurationSlider() {
        if (durationSlider.value + incrementPerSec <= duration) {
            durationSlider.value = durationSlider.value + incrementPerSec
            durationLabel.text = convertMsToMinuteAndSecond(ms: durationSlider.value)
            return
        }
        updateSliderTimer?.invalidate()
        player?.pause()
        playBtn.setImage(UIImage(systemName: "play.fill" ), for: .normal)
        
    }
    
    @IBAction func onVolumeSliderChange(_ sender: Any) {
        print(volumeSlider.value)
        player?.volume = volumeSlider.value
    }
    
    @IBAction func onSliderChangeEnd(_ sender: Any) {
        print(durationSlider.value)
    }
    @IBAction func onDurationSliderChange(_ sender: Any) {
        durationLabel.text = "\(round(durationSlider.value))"
//        playAudio()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = URL(string: "https://p.scdn.co/mp3-preview/3b7bb38fd34d6cc497b18456924866c558626d79?cid=82db669bedd846bfa068d9273c185dee")
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
    }
    
}
