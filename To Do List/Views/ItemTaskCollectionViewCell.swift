//
//  ItemTaskCollectionViewCell.swift
//  To Do List
//
//  Created by Michael Jajou on 12/28/18.
//  Copyright © 2018 Apptomistic. All rights reserved.
//

import UIKit

protocol ItemTaskCollectionViewCellDelegate {
    func toggleTaskCompletion(itemNumber: Int, isFinished: Bool)
    func deleteTask(itemNumber: Int)
}

class ItemTaskCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var bullet: UIView!
    @IBOutlet var label: UITextView!
    @IBOutlet var actionButton: UIButton!
    var delegate: ItemTaskCollectionViewCellDelegate?
    var isFinished = false
    var itemNumber: Int?
    
    lazy var touchView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    var color: UIColor? {
        didSet {
            updateView()
        }
    }
    
    
    func updateView() {
        if isFinished {
            self.bullet.backgroundColor = UIColor.white
            self.label.textColor = UIColor.white
            self.actionButton.setImage(#imageLiteral(resourceName: "finishCheck"), for: .normal)
            self.contentView.backgroundColor = UIColor.completeItemBG
        } else {
            self.bullet.backgroundColor = color
            self.label.textColor = color
            self.actionButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
            self.contentView.backgroundColor = UIColor.white
        }
        label.centerVertically()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func awakeFromNib() {
        bullet.layer.cornerRadius = bullet.frame.height / 2
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        actionButton.imageView?.contentMode = .scaleAspectFit
        
        label.isUserInteractionEnabled = true
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        labelTap.numberOfTapsRequired = 1
        label.addGestureRecognizer(labelTap)
    }
    
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        toggleTask(point: location)
    }
    
    
    @objc func toggleTask(point: CGPoint) {
        touchView.frame = CGRect(x: point.x, y: point.y, width: 5, height: 5)
        //touchView.layer.cornerRadius = 0.5
        
        if !isFinished {
            touchView.backgroundColor = UIColor.completeItemBG
            contentView.insertSubview(touchView, at: 0)
            UIView.animate(withDuration: 0.15, animations: {
                //self.touchView.transform = CGAffineTransform(scaleX: 200, y: 200)
                self.touchView.frame = self.contentView.frame
                self.bullet.backgroundColor = UIColor.white
                self.label.textColor = UIColor.white
                self.actionButton.setImage(#imageLiteral(resourceName: "finishCheck"), for: .normal)
            }) { (completed) in
                self.contentView.backgroundColor = UIColor.completeItemBG
                //self.touchView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.touchView.removeFromSuperview()
            }
        } else {
            touchView.backgroundColor = UIColor.white
            contentView.insertSubview(touchView, at: 0)
            UIView.animate(withDuration: 0.15, animations: {
                //self.touchView.transform = CGAffineTransform(scaleX: 200, y: 200)
                self.touchView.frame = self.contentView.frame
                self.bullet.backgroundColor = self.color
                self.label.textColor = self.color
                self.actionButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
            }) { (completed) in
                self.contentView.backgroundColor = UIColor.white
                //self.touchView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.touchView.removeFromSuperview()
            }
        }

        isFinished = !isFinished
        if let number = itemNumber {
            delegate?.toggleTaskCompletion(itemNumber: number, isFinished: isFinished)
        }
    }
    
    @IBAction func actionBtn_TchUpInside(_ sender: Any) {
        guard let image = actionButton.imageView?.image else { return }
        if image == #imageLiteral(resourceName: "trash") {
            guard let number = itemNumber else { return }
            delegate?.deleteTask(itemNumber: number)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        toggleTask(point: point)
    }
    
}


extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
