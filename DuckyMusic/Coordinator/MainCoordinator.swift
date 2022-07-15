//
//  MainCoordinator.swift
//  DuckyMusic
//
//  Created by ghtk on 11/07/2022.
//

import Foundation
import UIKit

class MainCoordinator {
    let navigationController:UINavigationController
    
    init(navigationController:UINavigationController) {
        self.navigationController = navigationController
//        navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        let newRelaseVC = NewReleaseViewController()
        newRelaseVC.coordinator = self
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(newRelaseVC, animated: true)
    }
    
    func fromAlbumToAudioPlay(albumData: Album) {
        let audioPlayVC = AudioPlayerViewController()
        audioPlayVC.viewModel.albumData = albumData
        audioPlayVC.coordinator = self
        navigationController.pushViewController(audioPlayVC, animated: true)
    }
    
    func goToPlaylist(playlist: [Track], audioVM: AudioPlayerViewModel, currentPlayTrack: IndexPath?) {
        let playlistVC = PlayListViewController()
        playlistVC.dataSource = audioVM
        playlistVC.delegate = audioVM
        audioVM.playlistVC = playlistVC
        playlistVC.currentPlayingIndexPath = currentPlayTrack
        navigationController.pushViewController(playlistVC, animated: true)        
    }
}
