//
//  ViewController.swift
//  To Do List
//
//  Created by Michael Jajou on 12/27/18.
//  Copyright © 2018 Apptomistic. All rights reserved.
//

import UIKit
import CoreData
import TransitionButton


class ViewController: UIViewController {

    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var tasksLabel: UILabel!
    @IBOutlet var imageViewBG: UIView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var quoteViewBG: UIView!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressBGView: UIView!
    @IBOutlet var clearList: UIView!
    @IBOutlet var clearListImage: UIImageView!
    @IBOutlet var addItemBtn: UIView!
    @IBOutlet var addItemBtnImage: UIImageView!
    @IBOutlet var collectionViewX: NSLayoutConstraint!
    let mutableString = NSMutableAttributedString(string: "Tasks:")
    let defaults = UserDefaults.standard
    var addedPGradient = false
    
    
    var items = [Items]()
    var data = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var colorItems = [UIColor.tealBlue, UIColor.orangeTint, UIColor.hotPink, UIColor.coolGreen, UIColor.purple, UIColor.black, UIColor.red, UIColor.yellow]
    
    var quotes = ["The secret of getting ahead is getting started.", "You can't have a million dollar dream with a minimum wage work ethic", "Just Do It!", "Our greatest glory is not in never falling, but in rising every time we fall.", "All our dreams can come true, if we have the courage to pursue them.", "Success is not final, failure is not fatal: it is the courage to continue that counts.", "There is only one thing that makes a dream impossible to achieve: the fear of failure.", "Your true success in life begins only when you make the commitment to become excellent at what you do.", "If you believe it will work out, you’ll see opportunities. If you believe it won’t, you will see obstacles.", "Your mind is a powerful thing. When you fill it with positive thoughts, your life will start to change.", "Start by doing what’s necessary; then do what’s possible; and suddenly you are doing the impossible.", "The future belongs to those who believe in the beauty of their dreams", "I am not a product of my circumstances. I am a product of my decisions.", "Do you really need a motivational quote to get to work?", "It's not about motivation, it's about discipline", "Without hustle, talent will only carry you so far.", "Working hard for what we don't care about is called stressed; working hard for what we love is called passion.", "Energy and persistence conquer all things."]
    var authors = ["-Mark Twain", "-Stephen Hogan", "-Shia Labeouf", "-Confucius", "-Walt Disney", "-Winston Churchill", "-Paulo Coelho", "-Brian Tracy", "-Wayne Dyer", "-Unknown", "-Francis of Assisi", "-Franklin D. Roosevelt", "-Stephen Covey", "-Michael Jajou", "-Unknown", "-Gary Vaynerchuk", "-Simon Sinek", "-Benjamin Franklin"]
    
    
    var addItemOn = false
    var nextColor = UIColor.orangeTint
    var nextColorString = "orangeTint"
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy var emptyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "emptyList.png")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Lato-Bold", size: 17)
        label.textAlignment = .center
        label.text = "Nothing to do"
        return label
    }()
    
    lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var addItemBGView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var itemCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var itemCardTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.text = "What do you need to get done?"
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        textView.textColor = UIColor.lightGray
        textView.returnKeyType = .done
        textView.autocapitalizationType = UITextAutocapitalizationType.words
        textView.autocorrectionType = .no
        textView.font = UIFont(name: "Lato-Bold", size: 13)
        textView.textAlignment = .center
        return textView
    }()
    
    lazy var itemCardBullet: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    func saveFirstTimeOnApp() {
        if defaults.value(forKey: "lastTimeFrame") == nil {
            let number = Int(Date().timeIntervalSince1970)
            defaults.set(number, forKey: "lastTimeFrame")
        }
        loadQuote()
    }
    
    func loadQuote() {
        print("loadingQuote")
        guard let firstTime = defaults.value(forKey: "lastTimeFrame") as? Int else { return }
        let currentTime = Int(Date().timeIntervalSince1970)
        let secondsInWeek = 604800
        let timeRange = currentTime - firstTime
        let index = timeRange / secondsInWeek
        if index >= 18 {
            quoteLabel.text = quotes[0]
            authorLabel.text = authors[0]
            defaults.set(currentTime, forKey: "lastTimeFrame")
        } else {
            quoteLabel.text = quotes[index]
            authorLabel.text = authors[index]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveFirstTimeOnApp()
        progressLabel.text = "Progress: 0%"
        let date = Date()
        var welcomeText = date.dayOfWeek()!
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        welcomeText = welcomeText + ", " + timestamp
        welcomeLabel.text = welcomeText
        layoutAddItemView()
        addGestureRecognizers()
        
        progressBGView.layer.cornerRadius = (7/375) * view.frame.width
        loadItems()
        initializeProgressView()
        if items.isEmpty {
            addEmptyView()
        } else {
            addedPGradient = true
            addProgressGradient()
            updateProgressView()
            progressBGView.isHidden = false
        }
        
        addItemBtn.layer.cornerRadius = addItemBtn.frame.width / 2
        addItemBtn.clipsToBounds = true
        addGradient()
        collectionView.dataSource = self
        profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
        imageViewBG.layer.cornerRadius = 57
        imageViewBG.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        quoteViewBG.layer.cornerRadius = 15
        quoteViewBG.clipsToBounds = true
        loadPicture()
        
        
        let radius = clearList.frame.width / 2
        clearList.layer.cornerRadius = radius
        // shadow
        clearList.layer.shadowColor = UIColor.black.cgColor
        clearList.layer.shadowOffset = CGSize(width: 3, height: 3)
        clearList.layer.shadowOpacity = 0.3
        clearList.layer.shadowRadius = 4.0
        clearList.layer.shouldRasterize = true
        clearList.layer.rasterizationScale = UIScreen.main.scale
        

        addItemBtnImage.transform = addItemBtnImage.transform.rotated(by: CGFloat.pi * 0.75)
    }
    
    
    func layoutAddItemView() {
        // Add the whole background
        addItemBGView.frame = collectionView.frame
        addItemBGView.frame.origin.x = view.frame.width
        view.addSubview(addItemBGView)
        
        // Add card to the background
        let viewWidth = Double(view.frame.width)
        let addItemWidth = Double(addItemBGView.frame.width)
        let sizeRatio = Double(150.0 / 375.0)
        let cardSize = Double(viewWidth * sizeRatio)
        let midX = Double(addItemWidth / 2) - Double(cardSize / 2)
        itemCardView.frame = CGRect(x: midX, y: 0, width: cardSize, height: cardSize)
        addItemBGView.addSubview(itemCardView)
        itemCardView.layer.cornerRadius = 15
        itemCardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Add bullet to the card
        let bulletRatio = Double(11.0 / 130.0)
        let bulletSize = Double(cardSize * bulletRatio)
        let bulletX = Double(cardSize / 2) - Double(bulletSize / 2)
        let bulletYRatio = Double(15.0 / 130.0)
        let bulletY = Double(cardSize * bulletYRatio)
        itemCardBullet.frame = CGRect(x: bulletX, y: bulletY, width: bulletSize, height: bulletSize)
        itemCardView.addSubview(itemCardBullet)
        itemCardBullet.layer.cornerRadius = CGFloat(bulletSize / 2)
        
        // Add text view to the card
        itemCardTextView.delegate = self
        let textViewXRatio = Double(8.0 / 130.0)
        let textViewX = Double(cardSize * textViewXRatio)
        let textViewWidth = Double(cardSize) - Double(2 * textViewX)
        let textViewYRatio = Double(12.0 / 130)
        let textViewY = Double(cardSize * textViewYRatio) + Double(bulletY + bulletSize)
        let textViewHeightRatio = Double(33.0 / 130.0)
        let textViewHeightSub = Double(cardSize * textViewHeightRatio)
        let textViewHeight = cardSize - textViewY - textViewHeightSub
        itemCardTextView.frame = CGRect(x: textViewX, y: textViewY, width: textViewWidth, height: textViewHeight)
        itemCardView.addSubview(itemCardTextView)
    }
    
    func addGestureRecognizers() {
        // Clear Items
        let tapToClear = UITapGestureRecognizer(target: self, action: #selector(wipeList))
        tapToClear.numberOfTapsRequired = 1
        clearList.isUserInteractionEnabled = true
        clearList.addGestureRecognizer(tapToClear)
        
        // Add Item BG View
        addItemBtn.isUserInteractionEnabled = true
        addItemBtnImage.isUserInteractionEnabled = true
        let tapAddItem = UITapGestureRecognizer(target: self, action: #selector(toggleAddItem))
        tapAddItem.numberOfTapsRequired = 1
        addItemBtnImage.addGestureRecognizer(tapAddItem)
        
        let tapViewAddItem = UITapGestureRecognizer(target: self, action: #selector(toggleAddItem))
        tapViewAddItem.numberOfTapsRequired = 1
        addItemBtn.addGestureRecognizer(tapViewAddItem)
        
        
        // Add gesture recognizer for profile picture
        let tapToImage = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        tapToImage.numberOfTapsRequired = 1
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapToImage)
        
    }
    
    @objc func completeTheList() {
        let alert = UIAlertController(title: "Clear List", message: "Are you sure you want to delete all your tasks?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Clear List", style: .destructive) { (action) in
            for item in self.items {
                self.context.delete(item)
            }
            self.items.removeAll()
            self.collectionView.reloadData()
            self.clearList.isHidden = true
            self.animateButton(button: self.clearList, imageView: self.clearListImage, location: self.clearList.center, newImage: #imageLiteral(resourceName: "greenCheck"), color: UIColor.white)
            self.addEmptyView()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.animateButton(button: self.clearList, imageView: self.clearListImage, location: self.clearList.center, newImage: #imageLiteral(resourceName: "greenCheck"), color: UIColor.white)
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func toggleAddItem() {
        let point = addItemBtn.center
        if !addItemOn {
            animateButton(button: addItemBtn, imageView: addItemBtnImage, location: point, newImage: #imageLiteral(resourceName: "exitAdd.png"), color: UIColor.trashRed)
            animateImageButton(button: addItemBtn, imageView: addItemBtnImage, location: point, identity: true, color: UIColor.trashRed)
            // Handle moving view
            addItemBGView.isHidden = false
            addItemBGView.frame.origin.x = view.frame.width
            itemCardTextView.becomeFirstResponder()
            itemCardBullet.backgroundColor = nextColor
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.frame.origin.x = 0 - self.collectionView.frame.width
                self.addItemBGView.frame.origin.x = self.collectionViewX.constant
            }) { (completed) in
                self.collectionView.isHidden = true
            }
        } else {
            animateImageButton(button: addItemBtn, imageView: addItemBtnImage, location: point, identity: false, color: UIColor.progressLeft)
            // Handle moving view
            self.collectionView.isHidden = false
            itemCardTextView.resignFirstResponder()
            self.collectionView.frame.origin.x = 0 - self.collectionView.frame.width
            UIView.animate(withDuration: 0.2, animations: {
                self.addItemBGView.frame.origin.x = self.view.frame.width
                self.collectionView.frame.origin.x = self.collectionViewX.constant
            }) { (completed) in
                self.addItemBGView.isHidden = true
            }
        }
        addItemBGView.frame.origin.y = collectionView.frame.origin.y
        addItemOn = !addItemOn
    }
    
    @objc func wipeList(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: clearList)
        animateButton(button: clearList, imageView: clearListImage, location: point, newImage: #imageLiteral(resourceName: "finishCheck.png"), color: UIColor.progressLeft)
        completeTheList()
        
    }
    
    func animateButton(button: UIView, imageView: UIImageView, location: CGPoint, newImage: UIImage, color: UIColor) {
        let point = location
        let colorView = UIView()
        colorView.frame = CGRect(x: point.x, y: point.y, width: 2, height: 2)
        colorView.backgroundColor = color
        button.insertSubview(colorView, at: 0)
        UIView.animate(withDuration: 0.15, animations: {
            colorView.frame = self.clearList.bounds
            colorView.layer.cornerRadius = self.clearList.bounds.width / 2
            imageView.image = newImage
        }) { (completed) in
            button.backgroundColor = color
            colorView.removeFromSuperview()
        }
    }
    
    func animateImageButton(button: UIView, imageView: UIImageView, location: CGPoint, identity: Bool, color: UIColor) {
        let point = location
        let colorView = UIView()
        colorView.frame = CGRect(x: point.x, y: point.y, width: 2, height: 2)
        colorView.backgroundColor = color
        button.insertSubview(colorView, at: 0)
        UIView.animate(withDuration: 0.15, animations: {
            if identity {
                imageView.transform = .identity
            } else {
                imageView.transform = imageView.transform.rotated(by: CGFloat.pi * 0.75)
            }
            colorView.frame = self.clearList.bounds
            colorView.layer.cornerRadius = self.clearList.bounds.width / 2
        }) { (completed) in
            button.backgroundColor = color
            colorView.removeFromSuperview()
        }
    }
    
    func loadPicture() {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "picture.jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            profilePicture.image = UIImage(data: imageData)
        } catch {
            profilePicture.image = #imageLiteral(resourceName: "default_pic")
        }
    }
    
    func loadItems() {
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        do {
            try items = context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        let colorValues = getNextColor()
        nextColorString = colorValues.1
        nextColor = colorValues.0
        updateProgressView()
        let count = items.count
        tasksLabel.text = "Tasks: \(count)"
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteItem(itemNumber: Int) {
        if items.indices.contains(itemNumber) {
            let object = items[itemNumber]
            context.delete(object)
            items.remove(at: itemNumber)
            self.collectionView.reloadData()
            self.saveItems()
            if items.count == 0 {
                self.addEmptyView()
                self.progressBGView.isHidden = true
            } else {
                self.progressBGView.isHidden = false
                updateProgressView()
            }
            let count = items.count
            tasksLabel.text = "Tasks: \(count)"
        }
    }
    
    func updateItemNumberValues() {
        let count = collectionView.numberOfItems(inSection: 0) - 1
        for i in 0...count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemTaskCollectionViewCell
            cell.itemNumber = i
        }
    }
    
    
    func initializeProgressView() {
        progressView.frame = CGRect(x: 0, y: 0, width: 0, height: progressBGView.frame.height)
        progressBGView.addSubview(progressView)
        progressBGView.clipsToBounds = true
    }
    
    func updateProgressView() {
        let totalItems = items.count
        if totalItems != 0 {
            self.progressBGView.isHidden = false
            var completedItems = 0
            for item in items {
                if item.completed {
                    completedItems += 1
                }
            }

            let completionPercentage = CGFloat(completedItems) / CGFloat(totalItems)
            let displayPercent = Int(completionPercentage * 100)
            progressLabel.text = "Progress: \(displayPercent)%"
            let _ = progressView.frame.width
            let width = progressBGView.frame.width * completionPercentage
            print(width)
            UIView.animate(withDuration: 0.25) {
                self.progressView.frame.size.width = width
                self.progressGradient.frame.size.width = width
            }
            
            if completedItems == totalItems {
                // User has finished tasks
                clearList.isHidden = false
            } else {
                clearList.isHidden = true
            }
            
        } else {
            self.progressBGView.isHidden = true
        }
    }
    
    let gradient = CAGradientLayer()
    let progressGradient = CAGradientLayer()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = quoteViewBG.bounds
        progressGradient.frame = progressView.bounds
    }
    func addGradient() {
        gradient.frame = quoteViewBG.bounds
        gradient.colors = [UIColor.topQuoteGradient.cgColor, UIColor.bottomQuoteGradient.cgColor]
        quoteViewBG.layer.insertSublayer(gradient, at: 0)
    }
    
    func addProgressGradient() {
        progressGradient.frame = progressView.bounds
        progressGradient.colors = [UIColor.progressLeft.cgColor, UIColor.progressRight.cgColor]
        progressGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        progressGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        progressView.layer.insertSublayer(progressGradient, at: 0)
    }
    
    func addEmptyView() {
        emptyLabel.alpha = 0
        emptyImage.alpha = 0
        collectionView.addSubview(emptyImage)
        collectionView.addSubview(emptyLabel)
        
        emptyImage.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        emptyImage.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        emptyImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        emptyImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        emptyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 10).isActive = true
        emptyLabel.widthAnchor.constraint(equalToConstant: 400).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.progressBGView.isHidden = true
        self.progressLabel.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            self.emptyLabel.alpha = 1.0
            self.emptyImage.alpha = 1.0
        }
    }
    
    func removeEmptyView() {
        emptyImage.removeFromSuperview()
        emptyLabel.removeFromSuperview()
        self.progressLabel.isHidden = false
        self.progressBGView.isHidden = false
    }
    
    func generateCellColor(color: UIColor) -> String {
        switch color {
        case UIColor.tealBlue:
            return "orangeTint"
        case UIColor.orangeTint:
            return "hotPink"
        case UIColor.hotPink:
            return "coolGreen"
        case UIColor.coolGreen:
            return "purple"
        case UIColor.purple:
            return "black"
        case UIColor.black:
            return "tealBlue"
        default:
            return "black"
        }
    }
    
    func convertColor(color: String) -> UIColor {
        switch color {
        case "orangeTint":
            return UIColor.orangeTint
        case "hotPink":
            return UIColor.hotPink
        case "coolGreen":
            return UIColor.coolGreen
        case "purple":
            return UIColor.purple
        case "black":
            return UIColor.black
        case "tealBlue":
            return UIColor.tealBlue
        default:
            return UIColor.black
        }
    }
    
    func getNextColor() -> (UIColor, String) {
        if items.count == 0 {
            let color = UIColor.orangeTint
            let string = "orangeTint"
            return (color, string)
        }
        let lastItem = items.last!
        if let colorString = lastItem.color {
            let color = convertColor(color: colorString)
            let newColorString = generateCellColor(color: color)
            let newColor = convertColor(color: newColorString)
            return (newColor, newColorString)
        } else {
            let color = UIColor.orangeTint
            let string = "orangeTint"
            return (color, string)
        }
    }
    
    @objc func selectImage() {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.allowsEditing = true
        imageController.sourceType = .photoLibrary
        present(imageController, animated: true, completion: nil)
    }
}

var previousColor = UIColor.black

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemTaskCollectionViewCell
        let item = items[indexPath.row]
        cell.itemNumber = indexPath.row
        cell.label.text = item.name
        cell.isFinished = item.completed
        if let colorString = item.color {
            let color = convertColor(color: colorString)
            cell.color = color
        } else {
            cell.color = UIColor.black
        }
        cell.delegate = self
        return cell
    }
}

extension ViewController: ItemTaskCollectionViewCellDelegate {
    func deleteTask(itemNumber: Int) {
        self.deleteItem(itemNumber: itemNumber)
    }
    
    func toggleTaskCompletion(itemNumber: Int, isFinished: Bool) {
        if items.indices.contains(itemNumber) {
            items[itemNumber].completed = isFinished
            self.updateProgressView()
            self.saveItems()
            print("saved")
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText == "\nWhat do you need to get done?" {
            toggleAddItem()
            textView.text = "What do you need to get done?"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        }

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            //confirmBtn.isEnabled = false
            textView.text = "What do you need to get done?"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            //confirmAddBtn.isUserInteractionEnabled = false
        }

            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            //confirmAddBtn.isUserInteractionEnabled = true
            textView.textColor = itemCardBullet.backgroundColor
            textView.text = text
            //confirmAddBtn.backgroundColor = UIColor.white
            //confirmAddBtnImage.image = #imageLiteral(resourceName: "greenCheck.png")
            //confirmBtn.isEnabled = true
        }

            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text!
        if text.contains("\n") || text == "\n" {
            textView.resignFirstResponder()
            let item = Items(context: context)
            item.name = text.replacingOccurrences(of: "\n", with: "")
            item.completed = false
            item.color = nextColorString
            items.append(item)
            textView.text = "What do you need to get done?"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            collectionView.reloadData()
            clearList.isHidden = true
            removeEmptyView()
            let colorValues = getNextColor()
            nextColor = colorValues.0
            nextColorString = colorValues.1
            let count = items.count
            tasksLabel.text = "Tasks: \(count)"
            if addedPGradient == false {
                addProgressGradient()
                addedPGradient = true
            }
            updateProgressView()
        }
    }
}


extension UIView {
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
           profilePicture.image = image
        }
        
        if let imgUrl = info["UIImagePickerControllerReferenceURL"] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSTemporaryDirectory()
            let _ = documentDirectory.appending(imgName)
            
            let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
            let data = image.jpegData(compressionQuality: 0.5)
            
            // get the documents directory url
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // choose a name for your image
            let fileName = "picture.jpg"
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            // get your UIImage jpeg data representation and check if the destination file url already exists
            
            do {
                try data?.write(to: fileURL)
            } catch {
                print("There was an error saving the photo: ", error.localizedDescription)
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}


extension UILabel {
    func halfTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
        self.attributedText = attribute
    }
}



