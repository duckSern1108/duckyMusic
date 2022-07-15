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
    var coordinator: MainCoordinator?
    var player:AVPlayer?
    
    var updateSliderTimer:Timer?
    
    let incrementPerSec:Float = 1000
    
    var viewModel = AudioPlayerViewModel()
    var canReplay = false
    weak var playObserver: NSObjectProtocol?
    
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(playObserver)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            updateSliderTimer?.invalidate()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVolume()
        setupDurationSlider()
        
        trackImage.sd_setImage(with: URL(string: viewModel.albumData.images[0].url))
        trackImage.translatesAutoresizingMaskIntoConstraints = false
        trackImage.widthAnchor.constraint(equalToConstant: view.frame.width - 40 * 2).isActive = true
        trackImage.heightAnchor.constraint(equalToConstant: view.frame.width - 40 * 2).isActive = true
        
        randomButton.tintColor = .gray
        refreshButton.tintColor = .gray
        
        title = viewModel.albumData.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(onShowPlaylist))
        
        viewModel.delegate = self
        
        playObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
        }
        
        getAlbumInfo()
    }
    
    func getAlbumInfo() {
        let loadingVC = LoadingViewController()
        add(loadingVC)
        firstly { () -> Promise<Void> in
            return viewModel.getAlbumInfo()
        }.ensure {
            loadingVC.remove()
        }
    }
    
    @objc func onShowPlaylist() {
        let currentTrack = viewModel.currentTrackIndexPath
        coordinator?.goToPlaylist(playlist: viewModel.albumData.tracks,
                                  audioVM: viewModel,
                                  currentPlayTrack: currentTrack)
    }
    
    
    //track control
    @IBAction func onPlayBtnTap(_ sender: Any) {
        switch self.player?.timeControlStatus {
        case .paused:
            playAudio()
        case .playing:
            pauseAudio()
        default:
            break
        }
    }
    
    func playAudio() {
        updateSliderTimer?.invalidate()
        updateSliderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDurationSlider), userInfo: nil, repeats: true)
        player?.play()
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func pauseAudio() {
        updateSliderTimer?.invalidate()
        player?.pause()
        playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func initAudioPlayer(from urlStr: String) {
        guard let url = URL(string: urlStr) else {
            return
        }
        let playerItem:AVPlayerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playAudio()
    }
    
    @IBAction func onPlayRandomTrack(_ sender: Any) {
        viewModel.togglePlayRandom()
        randomButton.tintColor = viewModel.playRamdomTrack ? .systemBlue : .gray
    }
    
    func replayTrack() {
        player?.pause()
        resetSlider()
        player?.seek(to: .zero)
        playAudio()
    }
    
    @IBAction func onReplayTrack(_ sender: Any) {
        canReplay = !canReplay
        refreshButton.tintColor = canReplay ? .systemBlue : .gray
    }
    
    @IBAction func onNextTrack(_ sender: Any) {
        nextTrack()
    }
    
    func nextTrack() {
        let didGoNextTrack = viewModel.nextTrack()
        if (!didGoNextTrack) {
            pauseAudio()
        }
    }
    
    
    @IBAction func onPreviousTrack(_ sender: Any) {
        let canPrev = viewModel.prevTrack()
        if (!canPrev) {
            replayTrack()
        }
        
    }
    
    //volume handle
    @IBOutlet weak var volumeSlider: UISlider!
    func setupVolume() {
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5
        player?.volume = 0.5
    }
    
    @IBAction func onMutePlayer(_ sender: Any) {
        player?.volume = 0
        volumeSlider.value = volumeSlider.minimumValue
    }
    @IBAction func onMaxVolumePlayer(_ sender: Any) {
        player?.volume = 1
        volumeSlider.value = volumeSlider.maximumValue
    }
    
    @IBAction func onVolumeSliderChange(_ sender: Any) {
        player?.volume = volumeSlider.value
    }
    
    
    //duration
    func resetSlider() {
        durationSlider.value = 0
        durationLabel.text = "0:00"
    }
    func setupDurationSlider() {
        resetSlider()
        let thumbImage = UIImage(systemName: "circle.fill")
        durationSlider.setThumbImage(thumbImage?.sd_tintedImage(with: .gray), for: .normal)
        durationSlider.isContinuous = false
    }
    
    @objc func updateDurationSlider() {
        guard let currentPlayTrack = viewModel.currentPlayTrack else {
            updateSliderTimer?.invalidate()
            return
        }
        if (durationSlider.value + incrementPerSec <= Float(currentPlayTrack.duration)) {
            durationSlider.value = durationSlider.value + incrementPerSec
            durationLabel.text = Double(durationSlider.value).convertMsToMinuteAndSecond()
            return
        }
        player?.pause()
        updateSliderTimer?.invalidate()
        if (canReplay) {
            replayTrack()
        } else {
            nextTrack()
        }
        
    }
    
    @IBAction func onDurationSliderChange(_ sender: Any) {
        updateSliderTimer?.invalidate()
        let time = CMTime(seconds: Double(durationSlider.value / 1000), preferredTimescale: 1)
        
        player?.seek(to: time) { [weak self] success in
            guard let self = self,success == false else {
                self?.pauseAudio()
                return
            }
        
            switch self.player?.timeControlStatus {
            case .playing:
                self.updateSliderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateDurationSlider), userInfo: nil, repeats: true)
            case.paused:
                self.pauseAudio()
            default:
                break
            }
        }
        durationLabel.text = Double(durationSlider.value).convertMsToMinuteAndSecond()
    }
    
}

extension AudioPlayerViewController:AudioPlayerViewModelDelegate {
    func onCurrentPlayTrackChange(_ viewModel: AudioPlayerViewModel) {
        guard  let newTrack = viewModel.currentPlayTrack else {
            pauseAudio()   
            return
        }
        player?.pause()
        updateSliderTimer?.invalidate()
        durationSlider.maximumValue = Float(newTrack.duration)
        maxDurationLabel.text = newTrack.durationText
        trackNameLabel.text = newTrack.name
        trackArtistLabel.text = newTrack.artistLabel
        resetSlider()
        initAudioPlayer(from: newTrack.previewUrl)
        
    }
}
