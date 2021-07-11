//
//  FilteredGroupViewController.swift
//  PlannerApp
//
//  Created by user198300 on 6/20/21.
//

import UIKit

class FilteredGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // Setting up values of FilteredGroupViewController.
    @IBOutlet var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var itemCells = [PlannerItem]()
    
    // Setting up view.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let nib = UINib(nibName: "itemCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "itemCell")
        populateTableItems()
        tableView.delegate = self
        tableView.dataSource = self
        colorConfigs()
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
    
    // Determining color of cell based on proximity to deadline.
    func cellColor(date: Date) -> UIColor
    {
        let today = Date()
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        if (Calendar.current.isDate(today, inSameDayAs: date))
        {
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
    
    // Configuring color of UI componenets.
    func colorConfigs()
    {
        tableView.backgroundColor = UIColor(rgb: 0x51C2D5)
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x51C2D5)
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
    
    // Populates backing array of items.
    func populateTableItems()
    {
        do	
        {
            itemCells = try context.fetch(PlannerItem.fetchRequest())
            itemCells = itemCells.filter {
                cell in return cell.category == title && !(pastDue(date: cell.dueDate!))
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


