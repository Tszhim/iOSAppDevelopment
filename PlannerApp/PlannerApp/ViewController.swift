//
//  ViewController.swift
//  PlannerApp
//
//  Created by user198300 on 6/19/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Setting up values of ViewController.
    @IBOutlet var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemCells = [PlannerItem]()
    var badgeNumber = 0
    
    // Configuring view.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "itemCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "itemCell")
        populateTableItems()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = currDate()
        tabBarItem.title = "Tasks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        colorConfigs()
    }
    
    // Call notifConfigs() after view setup completion.
    override func viewDidAppear(_ animated: Bool) {
        notifConfigs()
    }
    
    // Retrieves current date.
    func currDate() -> (String)
    {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    
    // Checks if a date is past due.
    func pastDue(date: Date) -> (Bool)
    {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if(date < yesterday)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // Configuring color of UI components.
    func colorConfigs()
    {
        tableView.backgroundColor = UIColor(rgb: 0x51C2D5)
        tabBarController?.tabBar.barTintColor = UIColor(rgb: 0x51C2D5)
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x51C2D5)
        navigationItem.rightBarButtonItem!.tintColor = UIColor.white
    }
    
    // Determining color of cell based on proximity to deadline.
    func cellColor(date: Date) -> UIColor
    {
        let today = Date()
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        if (Calendar.current.isDate(today, inSameDayAs: date))
        {
            badgeNumber = badgeNumber + 1
            print(badgeNumber)
            return UIColor(rgb: 0xFF577F)
        }
        else if (Calendar.current.isDate(nextDay, inSameDayAs: date))
        {
            return UIColor(rgb: 0xFF884B)
        }
        else
        {
            return UIColor(rgb: 0xFFC764)
        }
    }
    
    // Setting up badge notifications.
    func notifConfigs()
    {
        print(badgeNumber)
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _,_  in}
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // Handling logic for when add button is clicked.
    @objc func addButtonClicked()
    {
        let addMenu = UIAlertController(title: "Add Item", message: "Enter the associated information.", preferredStyle: .alert)
        addMenu.addTextField { (textField : UITextField!) in
            textField.placeholder = "Title"
        }
        addMenu.addTextField { (textField : UITextField!) in
            textField.placeholder = "Category"
        }
        addMenu.addTextField { (textField : UITextField!) in
            textField.placeholder = "Date (mm::dd::yy)"
        }
        
        addMenu.addAction(UIAlertAction(title: "Save Entry", style: .cancel, handler: {
        _ in guard let titleInput = addMenu.textFields?[0],
                       let categoryInput = addMenu.textFields?[1],
                       let dueDateInput = addMenu.textFields?[2],
                       let titleInputText = titleInput.text,
                       let categoryInputText = categoryInput.text,
                       let dueDateInputText = dueDateInput.text,
                       !titleInputText.isEmpty && !categoryInputText.isEmpty && !dueDateInputText.isEmpty
            else {
                let errorMenu = UIAlertController(title: "Invalid Input", message: "Fields cannot be blank.", preferredStyle: .alert)
                errorMenu.addAction(UIAlertAction(title: "Close", style: .cancel, handler: {_ in }))
                self.present(errorMenu, animated: true)
                
                return
            }
        
        let dateFormatChecker = DateFormatter()
        dateFormatChecker.dateFormat = "MM/dd/yyyy"
        let date = dateFormatChecker.date(from: dueDateInputText)
        
        if date != nil
        {
            self.addItem(title: titleInputText, category: categoryInputText, dueDate: date!)
        }
        else
        {
            let errorMenu = UIAlertController(title: "Invalid Input", message: "Incorrect date format.", preferredStyle: .alert)
            errorMenu.addAction(UIAlertAction(title: "Close", style: .cancel, handler: {_ in }))
            self.present(errorMenu, animated: true)
        }}))
        
        present(addMenu, animated: true)
    }
    
    // Handling logic for entry deletion via swiping cells.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete")
        { (action, view, completionHandler) in
            
            self.context.delete(self.itemCells[indexPath.row])
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.populateTableItems()
            
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // Returns number of cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCells.count
    }
    
    // Returns desired cell height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = CGFloat(70.0)
        return cellHeight
    }
    
    // Setting up cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemCells[indexPath.row]
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! itemCell
        itemCell.titleLabel.text = item.title
        itemCell.categoryLabel.text = item.category
        
        let date = item.dueDate!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        itemCell.dateLabel.text = dateFormatter.string(from: date)
        
        itemCell.contentView.backgroundColor = cellColor(date: item.dueDate!)
        
        return itemCell
    }
    
    // Adds item.
    func addItem(title: String, category: String, dueDate: Date)
    {
        let item = PlannerItem(context: context)
        item.title = title
        item.category = category
        item.dueDate = dueDate
        
        do
        {
            try context.save()
            populateTableItems()
        }
        catch
        {
            
        }
    }
    
    // Populates backing array of items.
    func populateTableItems()
    {
        do
        {
            itemCells = try context.fetch(PlannerItem.fetchRequest())
            itemCells = itemCells.filter{
                cell in return !(pastDue(date: cell.dueDate!))
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch
        {
            
        }
    }
}

// Allows UIColor class to take hex-string in constructor.
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: (rgb) & 0xFF
        )
    }
}
