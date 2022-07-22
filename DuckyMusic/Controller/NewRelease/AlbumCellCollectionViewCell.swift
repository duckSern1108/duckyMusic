//
//  AlbumCellCollectionViewCell.swift
//  DuckyMusic
//
//  Created by ghtk on 11/07/2022.
//

import UIKit

class AlbumCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    static let imageWidth = UIScreen.main.bounds.width - 48
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindData(cellData: Album) {
        nameLabel.text = cellData.name
        let artistStr = cellData.artists.map {
            $0.name
        }.joined(separator: ", ") + " \(cellData.totalTracks) songs"
        artistLabel.text = artistStr
        image.sd_setImage(with: URL(string: cellData.images[1].url))
        
        image.widthAnchor.constraint(equalToConstant: AlbumCellCollectionViewCell.imageWidth / 2).isActive = true
        image.heightAnchor.constraint(equalToConstant: AlbumCellCollectionViewCell.imageWidth / 2).isActive = true
    }
    
}
