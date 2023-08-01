//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeViewController{

    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        loadItems()
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        
////         Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.backGroundColor {
            let color = UIColor(hexString: colourHex)
            title = selectedCategory?.name
            
            guard let navbar = navigationController?.navigationBar else {fatalError("Havigation controller does not exist.")}
            navbar.tintColor = ContrastColorOf(color!, returnFlat: true)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hexString: colourHex)
            appearance.titleTextAttributes = [.foregroundColor : ContrastColorOf(color!, returnFlat: true)]
            appearance.largeTitleTextAttributes = [.foregroundColor : ContrastColorOf(color!, returnFlat: true)]
            navigationController?.navigationBar.standardAppearance = appearance;
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
//            searchBar.barTintColor = .red
            self.searchBar?.backgroundColor = color
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let colour =  UIColor(hexString: selectedCategory?.backGroundColor ?? "#90EE90")?.darken(byPercentage: CGFloat(Float(indexPath.row)/Float(2*(todoItems?.count ?? 7)+9))) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            cell.accessoryType = item.done == true ? .checkmark : .none
        } else {
            print("NO Items")
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        todoItems?[indexPath.row].done = !todoItems?[indexPath.row].done
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
//                    realm.delete(item)
                }
            } catch {
                print("error in saving status , \(error)")
            }
        }
        tableView.reloadData()
//        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default) {(action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new Items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

//    func saveItems() {
//        do {
//           try context.save()
//        } catch {
//            print("error in saving data \(error)")
//        }
//    }
    
//    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(),having predicate : NSPredicate? = nil) {
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//        do {
//            itemArray = try context.fetch(request)
//            print(itemArray.count)
//        } catch {
//            print("error in fetching data \(error)")
//        }
//    }
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title",ascending: true)
    }
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
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

//MARK:- Search Bar Methods
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request,having: NSPredicate(format : "title CONTAINS[cd] %@",searchBar.text!))
        todoItems = todoItems?.filter("title CONTAINS[cd] %@",searchBar.text!).sorted(byKeyPath:"dateCreated", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

