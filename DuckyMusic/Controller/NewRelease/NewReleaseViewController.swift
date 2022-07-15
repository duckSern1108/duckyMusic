//
//  NewReleaseViewController.swift
//  DuckyMusic
//
//  Created by ghtk on 11/07/2022.
//

import UIKit
import PromiseKit
import SDWebImage

class NewReleaseViewController: UIViewController {
    
    var coordinator: MainCoordinator?
    var offset = 0
    var limit = 20
    var isLoadingData = false
    var canNotLoadMore = false
    var isInitLoad = true
    lazy var loadingVC = LoadingViewController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let screenWidth = UIScreen.main.bounds.width - 32
    var albumList:[Album] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Release"
        let albumCell = UINib(nibName: "AlbumCellCollectionViewCell", bundle: .main)
        collectionView.register(albumCell, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        getData()
    }
    
    
    func getData(){
        if (canNotLoadMore == true || isLoadingData == true) {return }
        firstly { () -> Promise<[Album]> in
            if (isInitLoad) {
                add(loadingVC)
            }
            self.isLoadingData = true
            return AlbumRouter.shared.getNewRelease(offset: offset, limit: limit)
        }.done {
            self.isLoadingData = false
            if ($0.count == 0) {
                self.canNotLoadMore = true
                return
            }
            self.offset += self.limit
            self.albumList += $0
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }.ensure {
            if(self.isInitLoad) {
                self.isInitLoad = false
                self.loadingVC.remove()
            }
                        
        }.catch{err in
            self.canNotLoadMore = true
        }
        
    }
}

extension NewReleaseViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = albumList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCellCollectionViewCell
        cell.nameLabel.text = cellData.name
        let artistStr = cellData.artists.map {
            $0.name
        }.joined(separator: ", ") + " \(cellData.totalTracks) songs"
        cell.artistLabel.text = artistStr
        cell.image.sd_setImage(with: URL(string: cellData.images[1].url))
        
        cell.image.widthAnchor.constraint(equalToConstant: (screenWidth - 16) / 2).isActive = true
        cell.image.heightAnchor.constraint(equalToConstant: (screenWidth - 16) / 2).isActive = true
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albumList.count
    }
    
    
}

extension NewReleaseViewController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.fromAlbumToAudioPlay(albumData: albumList[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == albumList.count - 1 ) {
            getData()
        }
    }
}

extension NewReleaseViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth - 16)/2, height: screenWidth / 2 + 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
}
