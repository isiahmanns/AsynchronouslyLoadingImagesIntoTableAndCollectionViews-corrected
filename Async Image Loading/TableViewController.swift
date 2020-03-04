/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The UITableViewController of the sample.
*/
import UIKit

class TableViewController: UITableViewController {
    
    var dataSource: UITableViewDiffableDataSource<Section, Item>! = nil

    private var imageObjects = [Item]()
    let opQueue = DispatchQueue(label: "com.apple.lazy.table")
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ImageTableViewCell.reuseIdentifier,
                for: indexPath) as? ImageTableViewCell else {
                    fatalError("Couldn't make a cell, please check your storyboard cell")
            }
            /// - Tag: update
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
        
        self.dataSource.defaultRowAnimation = .fade
        
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

