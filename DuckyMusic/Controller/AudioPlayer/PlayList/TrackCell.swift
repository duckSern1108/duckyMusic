//
//  TrackCell.swift
//  DuckyMusic
//
//  Created by ghtk on 13/07/2022.
//

import UIKit
import ESTMusicIndicator

class TrackCell: UITableViewCell {
    
    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    var indicator:ESTMusicIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        indicator = ESTMusicIndicatorView.init(frame: CGRect.zero)
        indicator.tintColor = .red
        indicator.sizeToFit()
        indicator.translatesAutoresizingMaskIntoConstraints = false
    }
    func startPlay() {
        indicator.state = .playing
        trackNumberLabel.isHidden = true
        stackView.removeArrangedSubview(trackNumberLabel)
        stackView.insertArrangedSubview(indicator, at: 0)
        indicator.isHidden = false
    }
    
    func stopPlay() {
        stackView.removeArrangedSubview(indicator)
        indicator.isHidden = true
        trackNumberLabel.isHidden = false
        stackView.insertArrangedSubview(trackNumberLabel, at: 0)
        
        indicator.state = .stopped
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
