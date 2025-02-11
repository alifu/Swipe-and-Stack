//
//  StackedCardViewController.swift
//  Swipe and Stack
//
//  Created by Alif on 16/01/25.
//  reference: https://github.com/filletofish/CardsLayout/tree/master
//

import UIKit

func randomColor() -> UIColor {
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

import UIKit

class StackedCardViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var backImageView: UIImageView = UIImageView()
    private var currentTopIndex = 0
    private let totalItems = 10 // Number of cards
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        backImageView.image = UIImage(named: "funny-eggs-wallpaper-cd75ad666d6b3876841ce58940f36dc8")
        backImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        backImageView.contentMode = .scaleAspectFill
        backImageView.clipsToBounds = true
        self.view.addSubview(backImageView)
       
        let flowLayout = CardsCollectionViewLayout()
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300), collectionViewLayout: flowLayout)
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 250)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = true
        collectionView.superview?.clipsToBounds = true
        collectionView.layer.masksToBounds = true
        view.addSubview(collectionView)
    }
}

extension StackedCardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCell
        cell.backgroundColor = .white
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = randomColor().cgColor
        cell.layer.cornerRadius = 20
        let label = UILabel(frame: CGRect(x: 10, y: 50, width: 250, height: 100))
        label.textColor = randomColor()
        label.text = "index: \(indexPath.item)"
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 20, weight: .bold)
        cell.contentView.addSubview(label)
        cell.clipsToBounds = true
        return cell
    }
}


open class CardsCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: - Layout configuration
    
    public var itemSize: CGSize = CGSize(width: 200, height: 300) {
        didSet {
            invalidateLayout()
        }
    }
    
    public var spacing: CGFloat = 10.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    public var maximumVisibleItems: Int = 4 {
        didSet {
            invalidateLayout()
        }
    }
    
    // MARK: UICollectionViewLayout
    
    override open var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    override open var collectionViewContentSize: CGSize {
        let itemsCount = CGFloat(collectionView.numberOfItems(inSection: 0))
        let totalWidth = (itemSize.width + spacing) * itemsCount - spacing
        return CGSize(width: totalWidth, height: collectionView.bounds.height)
    }
    
    override open func prepare() {
        super.prepare()
        assert(collectionView.numberOfSections == 1, "Multiple sections aren't supported!")
        
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let totalItemsCount = collectionView.numberOfItems(inSection: 0)
        
        let minVisibleIndex = max(Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width), 0)
        let maxVisibleIndex = min(minVisibleIndex + maximumVisibleItems, totalItemsCount)
        
        let contentCenterX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
        
        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width
        
        let visibleIndices = stride(from: minVisibleIndex, to: maxVisibleIndex, by: 1)

        let attributes: [UICollectionViewLayoutAttributes] = visibleIndices.map { index in
            let indexPath = IndexPath(item: index, section: 0)
            return computeLayoutAttributesForItem(indexPath: indexPath,
                                                  minVisibleIndex: minVisibleIndex,
                                                  contentCenterX: contentCenterX,
                                                  deltaOffset: CGFloat(deltaOffset),
                                                  percentageDeltaOffset: percentageDeltaOffset)
        }
        
        return attributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let contentCenterX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
        let minVisibleIndex = Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width
        return computeLayoutAttributesForItem(indexPath: indexPath,
                                              minVisibleIndex: minVisibleIndex,
                                              contentCenterX: contentCenterX,
                                              deltaOffset: CGFloat(deltaOffset),
                                              percentageDeltaOffset: percentageDeltaOffset)
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let visibleRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
        let pageWidth = visibleRect.width
        let proposedPage = round((proposedContentOffset.x + (spacing * 7)) / pageWidth)
        let nearestPageOffset = proposedPage * pageWidth
        return CGPoint(x: nearestPageOffset - (spacing * 5), y: proposedContentOffset.y)
    }
}

// MARK: - Layout computations

fileprivate extension CardsCollectionViewLayout {
    
    private func scale(at index: Int) -> CGFloat {
        let translatedCoefficient = CGFloat(index) - CGFloat(self.maximumVisibleItems) / 2
        return CGFloat(pow(0.95, translatedCoefficient))
    }
    
    private func transform(atCurrentVisibleIndex visibleIndex: Int, percentageOffset: CGFloat) -> CGAffineTransform {
        var rawScale = visibleIndex < maximumVisibleItems ? scale(at: visibleIndex) : 1
        if visibleIndex != 0 {
            let previousScale = scale(at: visibleIndex - 1)
            let delta = (previousScale - rawScale) * percentageOffset
            rawScale += delta
        }
        return CGAffineTransform(scaleX: rawScale, y: rawScale)
    }
    
    func computeLayoutAttributesForItem(indexPath: IndexPath,
                                        minVisibleIndex: Int,
                                        contentCenterX: CGFloat,
                                        deltaOffset: CGFloat,
                                        percentageDeltaOffset: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributes = CardCollectionViewLayoutAttributes(forCellWith: indexPath)
        let visibleIndex = indexPath.row - minVisibleIndex
        attributes.size = itemSize
        let midY = self.collectionView.bounds.midY
        
        attributes.transform = transform(atCurrentVisibleIndex: visibleIndex,
                                         percentageOffset: percentageDeltaOffset)
        
        attributes.center = CGPoint(x: contentCenterX + (spacing * 1.5) * CGFloat(visibleIndex),
                                    y: midY)
        attributes.zIndex = maximumVisibleItems - visibleIndex
        
        switch visibleIndex {
        case 0:
            attributes.center.x -= deltaOffset
            attributes.contentAlpha = 1
            attributes.alpha = 1
            break
        case 1..<maximumVisibleItems:
            attributes.center.x -= (spacing * 1.5) * percentageDeltaOffset
            
            if visibleIndex == maximumVisibleItems - 1 {
                attributes.contentAlpha = 0
                attributes.alpha = percentageDeltaOffset
            } else if visibleIndex == 1 {
                attributes.contentAlpha = percentageDeltaOffset
            }
            break
        default:
            attributes.alpha = 0
            attributes.contentAlpha = 0
            break
        }
        
        return attributes
    }
}

class CardCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var contentAlpha: CGFloat = 0.0
}

class CardCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContent()
    }
   
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let customAttributes = layoutAttributes as? CardCollectionViewLayoutAttributes {
            self.contentView.alpha = customAttributes.contentAlpha
        }
    }
    
    private func setupContent() {
        // Add subviews or configure the cell's content here
    }
}

