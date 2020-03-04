/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection UICollectionViewCell and UITableViewCell subclasses that contains a UIImageView.
*/
import UIKit

public class ImageTableViewCell: UITableViewCell {
    static let reuseIdentifier = "cell"
    @IBOutlet public weak var imgView: UIImageView!
}

public class ImageCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "cell"
    @IBOutlet public weak var imgView: UIImageView!
}

enum Section {
    case main
}

class Item: Hashable {
    
    var image: UIImage!
    let url: URL!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage, url: URL) {
        self.image = image
        self.url = url
    }

}
