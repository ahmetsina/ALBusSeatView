//
//  ALBusSeatView.swift
//  ALBusSeatView
//
//  Created by Soner Güler on 14.02.2020.
//

import UIKit

public protocol ALBusSeatViewDataSource {
    func seatView(_ seatView: ALBusSeatView, seatTypeForIndex index: Int) -> ALBusSeatType
    func seatView(_ seatView: ALBusSeatView, seatNumberForIndex index: Int) -> String
    func numberOfSections(in seatView: ALBusSeatView) -> Int
    func seatView(_ seatView: ALBusSeatView, numberOfSeatInSection section: Int) -> Int
}

public protocol ALBusSeatViewDelegate: class {
    func seatView(_ seatView: ALBusSeatView, shouldSelectAtIndex index: Int, seatType: ALBusSeatType) -> Bool
    func seatView(_ seatView: ALBusSeatView, shouldDeSelectAtIndex index: Int, seatType: ALBusSeatType) -> Bool
    func seatView(_ seatView: ALBusSeatView, didSelectAtIndex index: Int, seatType: ALBusSeatType)
    func seatView(_ seatView: ALBusSeatView, deSelectAtIndex index: Int, seatType: ALBusSeatType)
}

// To make methods optional!
public extension ALBusSeatViewDelegate {
    func seatView(_ seatView: ALBusSeatView, shouldSelectAtIndex index: Int, seatType: ALBusSeatType) -> Bool { return true }
    func seatView(_ seatView: ALBusSeatView, shouldDeSelectAtIndex index: Int, seatType: ALBusSeatType) -> Bool { return true }
    func seatView(_ seatView: ALBusSeatView, didSelectAtIndex index: Int, seatType: ALBusSeatType) {}
    func seatView(_ seatView: ALBusSeatView, deSelectAtIndex index: Int, seatType: ALBusSeatType) {}
}


public class ALBusSeatView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Public
    public var config = ALBusSeatViewConfig()
    
    public var dataSource: ALBusSeatViewDataSource?
    public var delegate: ALBusSeatViewDelegate?
    
    
    // MARK: - Private
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: bounds, collectionViewLayout: layout)
        view.collectionViewLayout = layout
        view.register(ALBusSeatCell.self, forCellWithReuseIdentifier: cellID)
        view.backgroundColor = .cyan
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var collectionBGView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    private let cellID = "SeatCell"
    private let headerID = "HeaderView"
    
    
    public init(withConfig config: ALBusSeatViewConfig) {
        super.init(frame: .zero)
        self.config = config
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    public func reload() {
        collectionView.reloadData()
    }
    
    
    // MARK: - Private
    private func commonInit() {
        backgroundColor = .brown
        clipsToBounds = false
        addSubview(collectionView)
        
        collectionView.backgroundView = collectionBGView
        collectionBGView.addSubview(infoLabel)
        
        infoLabel.font = config.centerHallInfoTextFont
        infoLabel.text = config.centerHallInfoText
        infoLabel.textColor = config.centerHallInfoTextColor
        
        // Drive position setup
        if config.leftHandDrivePosition == true {
            print("leftHand active")
            let layout = ALBusLeftHandDriveLayout()
            layout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = layout
        }
        
        // Bus front image setup
        collectionView.register(ALBusSeatViewHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerID)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        
        let colW = collectionView.frame.width
        let infoX = config.busFrontImage != nil ? config.busFrontImageWidth : 20.0
        let infoWidth = config.busFrontImage != nil ? colW - config.busFrontImageWidth : colW - 20.0
        let infoFrame = CGRect(x: infoX, y: 0, width: infoWidth, height: collectionView.frame.height)
        infoLabel.frame = infoFrame
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID,
                                                      for: indexPath) as! ALBusSeatCell
        
        guard let seatType = dataSource?.seatView(self, seatTypeForIndex: indexPath.item),
            let seatNumber = dataSource?.seatView(self, seatNumberForIndex: indexPath.item) else {
            return cell
        }
        cell.title = seatNumber
        cell.type = seatType
        
        //TODO: Bazı otobüslerde en arka orta koltuk olabiliyor. Ona göre düzenleme yapılmalı
        if ((indexPath.item - 2) % 5 == 0) {
            cell.type = .none
        }
        
        cell.label.font = config.seatNumberFont
        cell.label.textColor = config.seatNumberColor
        
        switch seatType {
        case .empty:
            cell.coverView.backgroundColor = config.emptySeatBGColor
        case .selected:
            cell.coverView.backgroundColor = config.selectedSeatBGColor
            if config.seatRemoveImage != nil {
                cell.removeImageView.isHidden = false
                cell.removeImageView.image = config.seatRemoveImage
            }
            cell.label.font = config.seatNumberSelectedFont
            cell.label.textColor = config.seatNumberSelectedColor
        case .soldMan:
            cell.coverView.backgroundColor = config.soldManBGColor
        case .soldWoman:
            cell.coverView.backgroundColor = config.soldWomanBGColor
        case .none:
            cell.coverView.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            cell.coverView.isHidden = true
        }
        
        cell.coverView.layer.borderWidth = config.seatBorderWidth
        cell.coverView.layer.borderColor = config.seatBorderColor.cgColor
        cell.coverView.layer.cornerRadius = config.seatCornerRadius
        cell.coverView.layer.shadowColor = config.seatShadowColor.cgColor
        cell.coverView.layer.shadowRadius = config.seatCornerRadius
        cell.coverView.layer.shadowOffset = config.seatShadowSize
        cell.coverView.layer.shadowOpacity = config.seatShadowOpacity
        cell.coverView.layer.masksToBounds = false
        
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return dataSource?.seatView(self, numberOfSeatInSection: section) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return config.marginBetweenSeats
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return config.marginBetweenSeats / 2
    }
    
//    public func collectionView(_ collectionView: UICollectionView,
//                               layout collectionViewLayout: UICollectionViewLayout,
//                               referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return .zero
//    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: headerID,
                                                                         for: indexPath) as! ALBusSeatViewHeaderView
        headerView.imageView.image = config.busFrontImage
        if config.busFrontImage == nil {
            headerView.frame = .zero
        }
        return headerView
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && config.busFrontImage != nil {
            return CGSize(width: config.busFrontImageWidth, height: collectionView.frame.height)
        } else {
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let colH = collectionView.frame.height
        let totalMargin = config.marginBetweenSeats * 4
        
        var itemH = (colH - totalMargin - config.centerHallHeight) / 4
        let itemW = itemH
        //Center Hall
        if ((indexPath.item - 2) % 5 == 0) {
            itemH = config.centerHallHeight
        }
        
        return CGSize(width: itemW, height: itemH)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ALBusSeatCell else {
            return
        }
        
        print("DidSelect at:\(indexPath.item) \(cell.type)")
        
        if cell.type == .empty {
            delegate?.seatView(self, didSelectAtIndex: indexPath.item, seatType: cell.type)
        } else if cell.type == .selected {
            delegate?.seatView(self, deSelectAtIndex: indexPath.item, seatType: cell.type)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ALBusSeatCell else {
            return false
        }
        
        if cell.type == .empty {
            print("Should Select at:\(indexPath.item)")
            return delegate?.seatView(self, shouldSelectAtIndex: indexPath.item,
            seatType: cell.type) ?? true
        } else if cell.type == .selected {
            print("Should DeSelect at:\(indexPath.item)")
            return delegate?.seatView(self, shouldDeSelectAtIndex: indexPath.item,
            seatType: cell.type) ?? true
        }
        
        return false
    }
}