//
//  GroupsViewController.swift
//  PlannerApp
//
//  Created by user198300 on 6/20/21.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Setting up values of GroupsViewController.
    @IBOutlet var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var itemCells = [PlannerItem]()
    private var filteredItemCells = [PlannerItem]()
    var groups: [String: Int] = [:]
    var groupsEarliestDates: [String: Date] = [:]
    var groupArr = [String]()
    
    // Configuring view.
    override func viewWillAppear(_ animated: Bool) {
        itemCells = [PlannerItem] ()
        groups = [:]
        groupsEarliestDates = [:]
        groupArr = [String]()
        retrieveData()
        populateTableGroups()
    }

    // Ensuring data is refreshed properly each time this view controller is accessed.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "groupCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "groupCell")
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "Groups"
        tabBarItem.title = "Groups"
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
    
    // Configuring color of UI components.
    func colorConfigs()
    {
        tableView.backgroundColor = UIColor(rgb: 0x51C2D5)
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x51C2D5)
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
    
    // Returns number of cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    // Returns desired cell height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = CGFloat(70.0)
        return cellHeight
    }
    
    // Setting up cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupKey = groupArr[indexPath.row]
        let groupCell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! groupCell
        groupCell.groupLabel.text = groupKey
        groupCell.freqLabel.text = String(groups[groupKey]!)
        groupCell.contentView.backgroundColor = cellColor(date: groupsEarliestDates[groupKey]!)
        return groupCell
    }
    
    // Hnadling logic for when a cell is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupKey = groupArr[indexPath.row]
        let filterViewController = storyboard?.instantiateViewController(identifier: "filtered_vc") as! FilteredGroupViewController
        filterViewController.title = groupKey
        let filterViewNavigationController = UINavigationController(rootViewController: filterViewController)
        filterViewNavigationController.navigationBar.barTintColor = UIColor.systemBlue
        present(filterViewNavigationController, animated: true, completion: nil)
    }
    
    // Fetching data from CoreData.
    func retrieveData()
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
    
    // Populates backing array/dictionary with items + relevant information.
    func populateTableGroups()
    {
        for item in itemCells {
            if(groups[item.category!] != nil)
            {
                groups[item.category!] = groups[item.category!]! + 1
            }
            else
            {
                groups[item.category!] = 1
                groupArr.append(item.category!)
            }
        }
        
        for item in itemCells {
            if (groupsEarliestDates[item.category!] != nil)
            {
                if item.dueDate! < groupsEarliestDates[item.category!]!
                {
                    groupsEarliestDates[item.category!] = item.dueDate
                }
            }
            else
            {
                groupsEarliestDates[item.category!] = item.dueDate
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
