import Foundation
import UIKit
import AsyncDisplayKit
import Display

open class IconLeftButtonNode: HighlightTrackingButtonNode {
    private var textSizeForLayout: CGSize = .zero
    private var imageSizeForLayout: CGSize = .zero
    
    
    override open var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.6 : 1.0
            titleNode.isHidden = false
            highlightedTitleNode.isHidden = true
        }
    }


    public override init(pointerStyle: PointerStyle? = nil) {
        super.init(pointerStyle: pointerStyle)
        self.laysOutHorizontally = true
        self.contentHorizontalAlignment = .middle
    }

    override open func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let horizontalInsets = contentEdgeInsets.left + contentEdgeInsets.right
        let verticalInsets = contentEdgeInsets.top + contentEdgeInsets.bottom

        let imageSize = imageNode.image?.size ?? .zero
        let widthForText = max(1.0,
                              constrainedSize.width
                                - horizontalInsets
                                - imageSize.width
                                - (imageSize.width.isZero ? 0 : contentSpacing))
        let textSize = titleNode.updateLayout(
            CGSize(width: widthForText,
                   height: max(1.0, constrainedSize.height - verticalInsets))
        )

        textSizeForLayout = textSize
        imageSizeForLayout = imageSize

        let spacing = (imageSize.width.isZero || textSize.width.isZero) ? 0 : contentSpacing
        let totalWidth = imageSize.width + spacing + textSize.width
        let totalHeight = max(imageSize.height, textSize.height)

        return CGSize(
            width: min(constrainedSize.width, totalWidth + horizontalInsets),
            height: min(constrainedSize.height, totalHeight + verticalInsets)
        )
    }

    override open func layout() {
        let size = bounds.size
        let contentRect = CGRect(
            x: contentEdgeInsets.left,
            y: contentEdgeInsets.top,
            width: size.width - contentEdgeInsets.left - contentEdgeInsets.right,
            height: size.height - contentEdgeInsets.top - contentEdgeInsets.bottom
        )

        let imageSize = imageSizeForLayout
        let textSize = textSizeForLayout

        let spacing = (imageSize.width.isZero || textSize.width.isZero) ? 0 : contentSpacing
        let totalBlockWidth = imageSize.width + spacing + textSize.width

        let startX = contentRect.minX + floor((contentRect.width - totalBlockWidth) / 2.0)
        let centerY = contentRect.minY + floor(contentRect.height / 2.0)

        let iconOrigin = CGPoint(
            x: startX,
            y: centerY - floor(imageSize.height / 2.0)
        )
        imageNode.frame = CGRect(origin: iconOrigin, size: imageSize)
        selectedImageNode.frame = imageNode.frame
        highlightedImageNode.frame = imageNode.frame
        highlightedSelectedImageNode.frame = imageNode.frame
        disabledImageNode.frame = imageNode.frame

        let titleOrigin = CGPoint(
            x: startX + imageSize.width + spacing,
            y: centerY - floor(textSize.height / 2.0)
        )
        titleNode.frame = CGRect(origin: titleOrigin, size: textSize)
        highlightedTitleNode.frame = titleNode.frame
        disabledTitleNode.frame = titleNode.frame

        backgroundImageNode.frame = CGRect(origin: .zero, size: size)
        highlightedBackgroundImageNode.frame = backgroundImageNode.frame
    }
}

