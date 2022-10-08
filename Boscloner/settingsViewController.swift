//
//  settingsViewController.swift
//  Boscloner
//
//  Created by Phillip Bosco on 3/19/18.
//  Copyright © 2018 Phillip Bosco. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController {

    @IBAction func goToSettings(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        UIApplication.shared.open(URL(string:"App-Prefs:root=General&path=Cash")!, options: [:], completionHandler: nil)
        
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
