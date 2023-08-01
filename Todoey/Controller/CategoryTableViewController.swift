//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Sahil  on 20/06/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeViewController {

    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        loadCategory()
        tableView.rowHeight = 70
    }
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .flatSkyBlue()
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add category", style: .default) {
            (action) in
            if let safeString = textfield.text {
                let newCategory = Category()
                newCategory.name = safeString
                newCategory.backGroundColor = UIColor.randomFlat().hexValue()
                self.saveCategory(category: newCategory)
                self.tableView.reloadData()
            }
        }
        alert.addTextField {(alterTextField) in
            alterTextField.placeholder = "Create new Category"
            textfield = alterTextField
        }
        alert.addAction(action)
        present(alert,animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "NO Categories Added yet"
        let color = UIColor(hexString: categoryArray?[indexPath.row].backGroundColor ?? "#90EE90")
        cell.backgroundColor = color
        cell.selectionStyle = .none
        cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
        return cell
    }
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error in saving data \(error)")
        }
    }
    
    func loadCategory() {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - TableView Delegate Methods
//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("error in deleting item , \(error)")
            }
        }
    }
}
