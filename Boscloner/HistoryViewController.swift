//
//  HistoryViewController.swift
//  Boscloner
//
//  Created by Phillip Bosco on 3/18/18.
//  Copyright © 2018 Phillip Bosco. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var VC = ViewController()
    
    // Creating Timer to Update historyTableView on a Regular Interval
    var historyViewTableUpdateTimer = Timer()
    
    var selectedBadge = 0
    
    // Terminal Output (In original file)
    var characteristicASCIIValue = NSString()
    
    
    // IBAction && IBOutlets
    @IBOutlet weak var historyTableView: UITableView!
    
    
    @IBAction func historyShareButton(_ sender: UIBarButtonItem) {
        
        // Converting the Log File to Text for easy sharing
        let historyFileTxt = String(describing: historyLogFile)
        
        let activityVC = UIActivityViewController(activityItems: [historyFileTxt], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func historyDeleteButton(_ sender: UIBarButtonItem) {
        // Adding the Pop-Up Dialog
        showInputDialogDeleteHistory()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the delegates for historyTableView
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        // History Timer in Action - Calls Func to update the tableview
        historyViewTableUpdateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(HistoryViewController.updateTableView), userInfo: nil, repeats: true)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    
    // Table View Protocol Stubs
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return historyLogFile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let text = historyLogFile[indexPath.row]
        
        cell.textLabel?.text = text
        cell.textLabel?.textColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBadge = indexPath.row
        showInputDialogMoreDetails()
        
    }
    
    // Func to Call from historyViewTableUpdate Timer to update on a regular interval
    @objc func updateTableView() {
        historyTableView.reloadData()
    }
    
    func showInputDialogDeleteHistory() {
        let alertController = UIAlertController(title: "Delete History File", message: "Are you sure you want to delete the history file?", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Delete", style: .default) { (_) in
            
            // Clears the Global historyLogFile Variable
            historyLogFile = [String]()
            historyLogFileShort = [String]()
            
            // Clears the User Default HistoryLogFileKey Value
            UserDefaults.standard.set(historyLogFile, forKey: "HistoryLogFileKey")
            UserDefaults.standard.set(historyLogFile, forKey: "HistoryLogFileShortKey")
            
        }
        
        //Cancel Action Trigged, Nothing Happens
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //Adding the Appropriate Action to Dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //Presenting the Dialog Box to the User
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showInputDialogMoreDetails() {
        
        if isBLEAlive == false {
            notConnectedWarning()
        } else {
        
        let alertController = UIAlertController(title: "Write RFID Tag", message: "Write New RFID Badge from History File Entry? \n \((historyLogFileShort[selectedBadge])) ", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Write", style: .default) { (_) in
            writeFromHistoryFile = true
            self.VC.writeCustomBadgeFromHistory(historyBadge: "\(historyLogFileShort[self.selectedBadge])")
            terminalOutput.append("Written from History: \(historyLogFileShort[self.selectedBadge])")
        }
        
        //Cancel Action Trigged, Nothing Happens
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //Adding the Appropriate Action to Dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //Presenting the Dialog Box to the User
        self.present(alertController, animated: true, completion: nil)
    }
    }
    
    // BLE Device Not Connected Dialog Alert Pop-up
    func notConnectedWarning() {
        let alertController = UIAlertController(title: "Boscloner Unavailable", message: "Ensure the Boscloner boards are powered on and within range.", preferredStyle: .alert)
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (_) in }
        
        //adding the action to dialogbox
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
}

