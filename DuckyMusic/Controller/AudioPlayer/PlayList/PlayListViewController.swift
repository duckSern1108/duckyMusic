//
//  PlayListViewController.swift
//  DuckyMusic
//
//  Created by ghtk on 13/07/2022.
//

import UIKit

protocol PlayListDelegate: AnyObject {
    func onChangeTrack(_ playlistVC:PlayListViewController, indexPath: IndexPath)
    func removeTrackFromPlayList(_ playlistVC:PlayListViewController,at index: Int)
    func onReloadAlbumData(_ playlistVC:PlayListViewController)
}

protocol PlayListDataSource:AnyObject {
    func numberOfTrack() -> Int
    func trackAtIndex(at: IndexPath) -> Track
    func currentPlayTrackIndexPath() -> IndexPath?
    func isAudioPlayerRunning() -> Bool
}

protocol PlayListCommand: AnyObject {
    func onCurrentPlayingIndexChange(currentValue: Int?,oldValue: Int?)
    func onAudioStateChange(currentValue: Bool)
}

class PlayListViewController: UIViewController {
    weak var delegate:PlayListDelegate?
    weak var dataSource:PlayListDataSource?
    @IBOutlet weak var tableview: UITableView!
    
    var didLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = UINib(nibName: "TrackCell", bundle: .main)
        tableview.register(cell, forCellReuseIdentifier: "cell")
        tableview.dataSource = self
        tableview.delegate = self
        title = "Now playing"
        didLoad = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(onReloadAlbumData))
    }
    
    @objc func onReloadAlbumData() {
        delegate?.onReloadAlbumData(self)
    }
}

extension PlayListViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trackCell = tableview.dequeueReusableCell(withIdentifier: "cell") as! TrackCell
        guard let cellData = dataSource?.trackAtIndex(at: indexPath) else {
            return trackCell
        }
        let currentPlayingIndexPath = dataSource?.currentPlayTrackIndexPath()
        let isPlayingAudio = dataSource?.isAudioPlayerRunning()
        trackCell.bindData(cellData: cellData)
        if (indexPath.row == currentPlayingIndexPath?.row && cellData.playable == true) {
            if (isPlayingAudio != nil && isPlayingAudio! == true) {
                trackCell.startPlay()
            } else {
                trackCell.pause()
            }
            
        } else {
            trackCell.stopPlay()
        }
        return trackCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.numberOfTrack() ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

extension PlayListViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.onChangeTrack(self,indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (dataSource?.numberOfTrack() == 1) {
            return nil
        }
        // delete
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                return
            }
            self.delegate?.removeTrackFromPlayList(self, at: indexPath.row)
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let play = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                return
            }
            self.delegate?.onChangeTrack(self,indexPath: indexPath)
            completionHandler(true)
        }
        play.backgroundColor = .systemBlue
        play.image = UIImage(systemName: "play.fill")?.withTintColor(.white)
        let swipe = UISwipeActionsConfiguration(actions: [play])
        return swipe
    }
}

extension PlayListViewController:PlayListCommand {
    func onCurrentPlayingIndexChange(currentValue: Int?,oldValue: Int?) {
        guard let currentValue = currentValue, didLoad == true else {
            return
        }
        tableview.beginUpdates()
        let currentIndexPath = IndexPath(row: currentValue, section: 0)
        if (oldValue != nil && oldValue != currentValue) {
            tableview.reloadRows(at: [currentIndexPath,IndexPath(row: oldValue!, section: 0)], with: .fade)
        } else {
            tableview.reloadRows(at: [currentIndexPath], with: .fade)
        }
        tableview.endUpdates()
    }
    
    func onAudioStateChange(currentValue: Bool) {
        guard let currentPlayingIndexPath = dataSource?.currentPlayTrackIndexPath(), didLoad == true else {
            return
        }
        tableview.reloadRows(at: [currentPlayingIndexPath], with: .fade)
    }
}
