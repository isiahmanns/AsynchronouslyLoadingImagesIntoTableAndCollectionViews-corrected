/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The UICollectionViewController of the sample.
*/
import UIKit

class CollectionViewController: UICollectionViewController {
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil

    private var imageObjects = [Item]()
    let opQueue = DispatchQueue(label: "com.apple.lazy.collection")
    
    // MARK: View
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout()
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
        
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier,
                for: indexPath) as? ImageCollectionViewCell else {
                    fatalError("Couldn't make a cell, please check your storyboard cell")
            }
            
            cell.imgView.image = item.image
            ImageCache.publicCache.load(url: item.url as NSURL) { (image) in
                if let img = image, img != item.image {
                    var updatedSnapshot = self.dataSource.snapshot()
                    self.opQueue.async {
                        let item = self.imageObjects[indexPath.row]
                        item.image = img
                        updatedSnapshot.reloadItems([item])
                        self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                    }
                }
            }
            
            return cell
        }
        
        // Get our image URLs for processing.
        if imageObjects.isEmpty {
            opQueue.async {
                for index in 1...100 {
                    if let url = Bundle.main.url(forResource: "UIImage_\(index)", withExtension: "png") {
                        self.imageObjects.append(Item(image: ImageCache.publicCache.placeholderImage, url: url))
                    }
                }
                var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                initialSnapshot.appendSections([.main])
                initialSnapshot.appendItems(self.imageObjects)
                self.dataSource.apply(initialSnapshot, animatingDifferences: true)
            }
        }
    }

}
