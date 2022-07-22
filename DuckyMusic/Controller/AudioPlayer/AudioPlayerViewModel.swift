//
//  AudioPlayerViewModel.swift
//  DuckyMusic
//
//  Created by ghtk on 13/07/2022.
//

import Foundation
import PromiseKit

protocol AudioPlayerViewModelDelegate: AnyObject {
    func onCurrentPlayTrackChange(_ viewModel:AudioPlayerViewModel)
    
}

class AudioPlayerViewModel {
    var playedTrackIndex:[Int] = [0]
    var playRamdomTrack = false
    
    var albumData: Album!
    weak var playlistVC: PlayListCommand?
    weak var delegate:AudioPlayerViewModelDelegate?
    
    var trackIndex: Int? {
        didSet {
            delegate?.onCurrentPlayTrackChange(self)
            playlistVC?.onCurrentPlayingIndexChange(currentValue: trackIndex, oldValue: oldValue)
            guard let trackIndex = trackIndex else {
                
                return
            }
            if (!playedTrackIndex.contains(trackIndex)) {
                playedTrackIndex.append(trackIndex)
            }
        }
    }
    var isPlayingAudio = false {
        didSet {
            playlistVC?.onAudioStateChange(currentValue: isPlayingAudio)
        }
    }
    
    var currentTrackIndexPath:IndexPath? {
        guard let trackIndex = trackIndex else {
            return nil
        }
        return IndexPath(row: trackIndex, section: 0)
    }
    
    func getAlbumInfo() -> Promise<Void> {
        return firstly {
            AlbumRouter.shared.getAlbumInfo(id: albumData.id)
        }.done {
            self.albumData = $0
            self.startPlay()
        }
    }
    
    var currentPlayTrack:Track? {
        guard let trackIndex = trackIndex, trackIndex < albumData.tracks.count else {
            return nil
        }
        return albumData.tracks[trackIndex]
    }
    
    func startPlay() {
        trackIndex = 0
    }
    
    func nextTrack() -> Bool {
        guard playedTrackIndex.count < albumData.tracks.count else {
            return false
        }
        if (playRamdomTrack) {
            var index = Int.random(in: 0...(albumData.tracks.count - 1))
            while playedTrackIndex.contains(index) {
                index = Int.random(in: 0...(albumData.tracks.count - 1))
            }
            trackIndex = index
            return true
        }
        if trackIndex != nil {
            trackIndex! += 1
        }
        return true
    }
    
    
    func prevTrack() -> Bool {
        guard playedTrackIndex.count > 1 else {
            return false
        }
        let _ = playedTrackIndex.popLast()
        guard let lastIndex = playedTrackIndex.last else {
            return false
        }
        trackIndex = lastIndex
        return true
    }
    
    func togglePlayRandom() {
        playRamdomTrack = !playRamdomTrack
    }
}

extension AudioPlayerViewModel:PlayListDelegate {
    func onChangeTrack(_ playlistVC:PlayListViewController, indexPath: IndexPath) {
        trackIndex = indexPath.row
    }
    func removeTrackFromPlayList(_ playlistVC: PlayListViewController, at index: Int) {
        albumData.tracks.remove(at: index)
        playlistVC.tableview.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
        if (albumData.tracks.isEmpty) {
            trackIndex = nil
        }
        
        if (trackIndex != nil) {
            if (index == trackIndex!) {
                let popIndex = playedTrackIndex.popLast()
                if (popIndex == albumData.tracks.count) {
                    if (trackIndex! > 0) {
                        trackIndex! -= 1
                    } else {
                        trackIndex = nil
                    }
                    
                } else {
                    trackIndex! += 0
                }
            }
            if (index < trackIndex!) {
                trackIndex! -= 1
            }
            
        }
    }
    func onReloadAlbumData(_ playlistVC: PlayListViewController) {
        albumData.tracks = albumData.staticTracks
        playlistVC.tableview.reloadData()
        startPlay()
    }
}

extension AudioPlayerViewModel:PlayListDataSource {
    func isAudioPlayerRunning() -> Bool {
        isPlayingAudio
    }
    
    func numberOfTrack() -> Int {
        albumData.tracks.count
    }
    func trackAtIndex(at indexPath: IndexPath) -> Track {
        albumData.tracks[indexPath.row]
    }
    func currentPlayTrackIndexPath() -> IndexPath? {
        currentTrackIndexPath
    }
    
}
