//
//  TasksListControllerTableViewController.swift
//  To do manager
//
//  Created by Чаусов Николай on 22.02.2022.
//

import UIKit

class TasksListController: UITableViewController {
    
    var taskStorage: TaskStorageProtocol = TaskStorage()
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
            for (taskGroupPriority, tasksGroup) in tasks {
                tasks[taskGroupPriority] = tasksGroup.sorted { task1, task2 in
                    task1.status.rawValue < task2.status.rawValue
                }
            }
        }
    }
    
    var sectionTyperPosition: [TaskPriority] = [.important,.normal]

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTasks()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func loadTasks(){
        sectionTyperPosition.forEach { taskType in
            tasks[taskType] = []
        }
        taskStorage.loadTask().forEach
        { task in
            tasks[task.type]?.append(task)
        }
        

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionTyperPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskType = sectionTyperPosition[sourceIndexPath.section]
        let taskTypeTO = sectionTyperPosition[destinationIndexPath.section]
        
        guard let movedTask = tasks[taskType]?[sourceIndexPath.row] else {
            return
        }
        
        tasks[taskType]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeTO]!.insert(movedTask, at: destinationIndexPath.row)

        if taskType != taskTypeTO {
            tasks[taskTypeTO]![destinationIndexPath.row].type = taskTypeTO
        }
        tableView.reloadData()

    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionTyperPosition[section]
        guard let currentTaskType = tasks[taskType] else {return 0}
        return currentTaskType.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return getConfigeredTaskCell_Constraints(for: indexPath)
        return getConfigeredTaskCell_StackView(for: indexPath)
    }
    
    private func getConfigeredTaskCell_Constraints(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellConstraints", for: indexPath)
        let taskType = sectionTyperPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {return cell}
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        let titleLabel = cell.viewWithTag(2) as? UILabel
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        titleLabel?.text = currentTask.title
        
        if currentTask.status == .planned{
            titleLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            titleLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
            
        }
        
        return cell
    }
    
    private func getConfigeredTaskCell_StackView(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskSellStack", for: indexPath) as! TaskCell
        let taskType = sectionTyperPosition[indexPath.section]
        
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
        return cell }
        
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        if currentTask.status == .planned{
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        
        return cell
    }
    
    private func getSymbolForTask(with status: TaskStatus) -> String{
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        var title: String
        let taskType = sectionTyperPosition[section]
        if taskType == .important {
            title = "Важные"
        } else {
            title = "Текущие"
        }
        return title
    }
}

extension TasksListController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionTyperPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {return}
        
        guard tasks[taskType]![indexPath.row].status == .planned else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        tasks[taskType]![indexPath.row].status = .completed
        
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionTyperPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        guard tasks[taskType]![indexPath.row].status == .completed else {
            return nil
        }
        let actionSwipe = UIContextualAction(style: .normal, title: "Перепланировать") {
            _,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [actionSwipe])
    }
}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

