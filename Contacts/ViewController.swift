//
//  ViewController.swift
//  Contacts
//
//  Created by urichese on 20.09.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var storage: ContactStorageProtocol!
    private var contacts: [ContactProtocol] = [] {
        didSet{
            contacts.sort{$0.title < $1.title}
            storage.save(contacts: contacts)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage = ContactStorage()
        loadContacts()
    }
    private func loadContacts() {
        contacts = storage.load()
    }
    @IBAction func showNewContactAlert() {
        let allertController = UIAlertController(title: "Создайте новый контакт", message: "Введите номер и телефон", preferredStyle: .alert)
        allertController.addTextField{ textfield in
            textfield.placeholder = "Имя"
        }
        allertController.addTextField{ textfield in
            textfield.placeholder = "Номер телефона"
        }
        let createButton = UIAlertAction(title: "Создать", style: .default) {
            _ in
            guard let contactName = allertController.textFields?[0].text,
                  let contactPhone = allertController.textFields?[1].text else { return }
            let contact = Contact(title: contactName, phone: contactPhone)
            self.contacts.append(contact)
            self.tableView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        // add buttons to Alert Controller
        allertController.addAction(cancelButton)
        allertController.addAction(createButton)
        self.present(allertController, animated: true, completion: nil)
    }
}
extension ViewController: UITableViewDataSource {
    //MARK: data source metod
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    //MARK: data source metod which returns cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            print("Используем старую ячейку для строки с индексом \(indexPath.row)")
            cell = reuseCell
        } else {
            print("Создаем новую ячейку для строки с индексом \(indexPath.row)")
            cell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        }
        configure(cell: &cell, for: indexPath)
        return cell
    }
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        // конфигурируем ячейку
        var configuration = cell.defaultContentConfiguration()
        configuration.text = contacts[indexPath.row].title
        configuration.secondaryText = contacts[indexPath.row].phone
        cell.contentConfiguration = configuration
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // delete action
        let actionDelete = UIContextualAction(style: .destructive, title: "Удалить") {_,_,_ in
            // deleting contact
            self.contacts.remove(at: indexPath.row)
            // rebuilding the table view
            tableView.reloadData()
        }
        // we form an instance describing the available actions
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}
