//
//  ViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 11.02.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    
    private let sessionManager = SessionManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        fetchData()
    }
    
    @objc private func addNewTask() {
       // SHOW ALERT
    }
    
    private func fetchData() {
        let fetchRequest = ToDoTask.fetchRequest()
        
        do {
            taskList = try sessionManager.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Private Methods for Alert Controller
    private func showAlert(title: String,
                           message: String,
                           placeholder: String?,
                           editHandler: (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let placeholder = placeholder {
            alert.addTextField { textField in
                textField.placeholder = placeholder
            }
            
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            
            present(alert, animated: true)
        }
    }
    
    private func save(_ taskName: String) {
        let task = ToDoTask(context: sessionManager.persistentContainer.viewContext)
        task.title = taskName
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        sessionManager.saveContext()
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let toDoTask = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = toDoTask.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            
            do {
                let context = sessionManager.persistentContainer.viewContext
                context.delete(taskToDelete)
                try context.save()
            } catch {
                print(error)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
