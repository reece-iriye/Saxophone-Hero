//
//  TableViewController.swift
//  Saxophone-Hero
//
//  Created by Chris Miller on 12/5/23.
//

import UIKit

class TableViewController: UITableViewController {

    public var levels: [String] = [
        "Level 01 - Hot Cross Buns",
        "Level 02 - Mario Theme"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = levels[indexPath.row]

        return cell
    }
    
    override public var shouldAutorotate: Bool {
        return false
      }
      override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
      }
      override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
      }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Request geometry update for landscape orientation
        if let windowScene = view.window?.windowScene {
            let orientationUpdate = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
            windowScene.requestGeometryUpdate(orientationUpdate) { error in
                print(error.localizedDescription)
            }
        }
    }
}
