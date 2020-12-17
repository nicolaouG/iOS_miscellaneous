//
//  InfiniteCollectionView.swift
//  Eshop
//
//  Created by george on 29/09/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit
import AMAUI

public enum ScrollSpeed: Double {
    case veryFast = 0.5
    case fast = 0.8
    case average = 1
    case slow = 2
    case verySlow = 3
    case snail = 4
    case zero = 0
}

/**
 Customize the collection view.
 
 - Parameters:
    - images: supports [UIImage] and [String] urls
    - horizontalCount: number of images to fit horizontally (defaults to 4)
    - verticalCount: number of images to fit vertically (defaults to 3)
    - speed: Enum to control the automatic scrolling speed (defaults to *.snail*)
  
 # Sample initialization code:
  ```
  lazy var infiniteCollection: InfiniteCollectionView = {
      let imageURLs: [String] = ["https://picsum.photos/200/300?grayscale", "https://picsum.photos/200", "https://picsum.photos/300", "https://picsum.photos/400/300", "https://picsum.photos/250/250", "https://picsum.photos/200/100", "https://picsum.photos/320", "https://picsum.photos/450/350", "https://picsum.photos/260/420"]
      let v = InfiniteCollectionView(images: imageURLs, horizontalCount: 4, verticalCount: 4, speed: .snail)
      v.viewStyle = .titled(title: "Title goes here", subtitle: "This is a Subtitle")
      // to update the tableView cell's height
      v.onSetupCompletionHandler = {
          self.tableView.performBatchUpdates {
              self.infiniteCollection.frame.size.height = self.infiniteCollection.getCollectionViewHeight()
          } completion: { _ in }
      }
      return v
  }()
  ```
 */
public class InfiniteCollectionView: UIView {
    public enum ViewStyle {
        case plain
        case titled(title: String?, subtitle: String?)
    }
    
    public enum ImagesType {
        case url, image
    }
    
    private var images: [UIImage] = []
    private var imageURLs: [String] = []
    public var horizontalCount: Int = 4
    public var verticalCount: Int = 3
    
    public private(set) var initialImages: [UIImage] = []
    public private(set) var initialImageUrls: [String] = []
    
    private let cellReuseID = "imageCellIdentifier"
    private var timer: Timer?
    private var imagesType: ImagesType = .url
    public var onSetupCompletionHandler: (() -> Void)?


    public var viewStyle: ViewStyle = .plain {
        didSet {
            DispatchQueue.main.async {
                switch self.viewStyle {
            case .titled(let title, let subtitle):
                self.titleLabel.text = title
                self.subtitleLabel.text = subtitle
            default: break
            }
                self.setupVisibilities()
                self.setupConstraints()
            }
        }
    }
            
    private var itemSize: CGSize = CGSize(width: 80, height: 80) {
        didSet {
            guard itemSize != oldValue ||
                    collectionView.frame.height != getCollectionViewHeight()
            else { return }
            stopTimer()
            setupConstraints()
            collectionViewFlowLayout.itemDimensions = itemSize
            collectionView.reloadData()
            onSetupCompletionHandler?()
            startTimer()
        }
    }
    
    public var itemsSpacing: CGFloat = 10 {
        didSet {
            calculateNewItemSize()
        }
    }
    
    public var speed: Double = ScrollSpeed.average.rawValue {
        didSet {
            stopTimer()
            DispatchQueue.main.async {
                self.startTimer()
            }
        }
    }

    private lazy var collectionViewFlowLayout: OffsetCollectionViewFlowLayout = {
        let f = OffsetCollectionViewFlowLayout(columns: horizontalCount, rows: verticalCount)
        f.scrollDirection = .horizontal
        f.estimatedItemSize = .zero
        f.minimumLineSpacing = itemsSpacing
        f.minimumInteritemSpacing = itemsSpacing
        f.sectionInset = UIEdgeInsets(top: itemsSpacing, left: 0, bottom: itemsSpacing, right: 0)
        return f
    }()

    public lazy var collectionView: UICollectionView = {
        let c = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        c.register(ImageCollectionCell.self, forCellWithReuseIdentifier: cellReuseID)
        c.delegate = self
        c.dataSource = self
        c.isScrollEnabled = false
        c.allowsSelection = false
        c.backgroundColor = .red
        c.clipsToBounds = true
        c.cornerRadius = 10
        return c
    }()
    
    public lazy var titleLabel: AMALabel = {
        let l = AMALabel(theme: MainApp.shared.theme)
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.numberOfLines = 3
        return l
    }()

    public lazy var subtitleLabel: AMALabel = {
        let l = AMALabel(theme: MainApp.shared.theme)
        l.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        l.numberOfLines = 3
        return l
    }()
    
    private lazy var titlesStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        s.axis = .vertical
        s.distribution = .fill
        s.alignment = .leading
        return s
    }()


    public init(images: [UIImage], horizontalCount: Int = 4, verticalCount: Int = 3, speed: ScrollSpeed = .snail) {
        super.init(frame: .zero)
        self.imagesType = .image
        self.images = images
        self.initialImages = images
        commonSetup(horizontalCount, verticalCount, speed)
    }

    public init(images: [String], horizontalCount: Int = 4, verticalCount: Int = 3, speed: ScrollSpeed = .snail) {
        super.init(frame: .zero)
        self.imagesType = .url
        self.imageURLs = images
        self.initialImageUrls = images
        commonSetup(horizontalCount, verticalCount, speed)
    }
    
    private func commonSetup(_ horizontalCount: Int, _ verticalCount: Int, _ speed: ScrollSpeed) {
        self.horizontalCount = horizontalCount
        self.verticalCount = verticalCount
        self.speed = speed.rawValue
        setupView()
        setupVisibilities()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopTimer()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.calculateNewItemSize()
    }
    
    
    private func setupView() {
        addSubview(titlesStackView)
        addSubview(collectionView)
    }
    
    private func setupVisibilities() {
        switch viewStyle {
        case .plain:
            [titlesStackView].forEach({
                $0.isHidden = true
            })
        case .titled:
            [titlesStackView].forEach({
                $0.isHidden = false
            })
        }
    }
    
    private func setupConstraints() {
        let collectionHeight = getCollectionViewHeight()
        
        switch viewStyle {
        case .plain:
            titlesStackView.snp.remakeConstraints({ make in
                make.height.equalTo(0)
                make.top.left.right.equalToSuperview()
            })
            collectionView.snp.remakeConstraints({ make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(collectionHeight).priority(990)
            })
            
        case .titled:
            titlesStackView.snp.remakeConstraints({ make in
                make.top.left.right.equalToSuperview()
            })
            collectionView.snp.remakeConstraints({ make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(titlesStackView.snp.bottom).offset(8)
                make.height.equalTo(collectionHeight).priority(990)
            })
        }
    }
    
    private func calculateNewItemSize() {
        let newWidth = (collectionView.frame.width - (itemsSpacing * CGFloat(horizontalCount - 1))) / CGFloat(horizontalCount)
        itemSize = CGSize(width: newWidth, height: newWidth)
    }
    
    func getCollectionViewHeight() -> CGFloat {
        let verticalSpacing = itemsSpacing * CGFloat(verticalCount - 1) + collectionViewFlowLayout.sectionInset.top + collectionViewFlowLayout.sectionInset.bottom
        let itemsHeight = itemSize.height * CGFloat(verticalCount)
        return verticalSpacing + itemsHeight
    }
    
    private func startTimer() {
        guard timer == nil, speed != .zero else { return }
        let interval: TimeInterval = self.speed / 100
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [unowned self] _ in
            let currentOffset = self.collectionView.contentOffset
            let updatedOffset = CGPoint(x: currentOffset.x + CGFloat(1 / self.speed), y: currentOffset.y)
            self.collectionView.setContentOffset(updatedOffset, animated: false)
        }
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


// MARK: - Collection delegate

extension InfiniteCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesType == .url ? imageURLs.count : images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseID, for: indexPath) as? ImageCollectionCell
        switch imagesType {
        case .url:
            cell?.imageView.kf.setImage(with: URL(string: imageURLs[indexPath.row]), placeholder: #imageLiteral(resourceName: "placeholder_full"))
        default:
            cell?.imageView.image = images[indexPath.row]
        }
        cell?.imageView.cornerRadius = itemSize.width * 0.1
        return cell ?? UICollectionViewCell()
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        showImagesFromBeginning(indexPath)
    }
    
    func showImagesFromBeginning(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            let endIndex = (self.imagesType == .url ? self.imageURLs.count : self.images.count)
            if indexPath.item >= endIndex - self.verticalCount {
                let newArray = Array(repeating: (Any).self, count: (self.imagesType == .url ? self.initialImageUrls.count : self.initialImages.count))
                
                if self.imagesType == .url {
                    self.imageURLs.append(contentsOf: self.initialImageUrls)
                } else {
                    self.images.append(contentsOf: self.initialImages)
                }
                
                var newIndexPaths: [IndexPath] = []
                for index in 0..<newArray.count {
                    newIndexPaths.append(IndexPath(item: endIndex + index, section: 0))
                }
                
                self.collectionViewFlowLayout.calculateNewAttributes(for: newIndexPaths)
                self.collectionView.insertItems(at: newIndexPaths)
            }
        }
    }
}


