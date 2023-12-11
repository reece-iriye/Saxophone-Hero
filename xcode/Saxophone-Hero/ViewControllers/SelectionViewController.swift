//
//  SelectionViewController.swift
//  Saxophone-Hero
//
//  Created by Reece Iriye on 11/30/23.
//

import UIKit

class SelectionViewController: UIViewController, UITextFieldDelegate {

    let gameManager = GameManager.shared
    
    @IBOutlet weak var level1ScoreLabel: UILabel!
    @IBOutlet weak var level2ScoreLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.reloadLabels()
    }
    
    func reloadLabels() {
        level1ScoreLabel.text = gameManager.levels[0].getScores(difficulty: gameManager.currentDifficulty)[0]
        level2ScoreLabel.text = gameManager.levels[1].getScores(difficulty: gameManager.currentDifficulty)[0]
    }
    
    @IBAction func level1ButtonPress(_ sender: Any) {
        gameManager.currentLevel = 0
    }
    
    @IBAction func level2ButtonPress(_ sender: Any) {
        gameManager.currentLevel = 1
    }
    
    @IBAction func textFieldChange(_ sender: Any) {
        if let newText = textField.text, !newText.isEmpty {
            gameManager.currentPlayer = newText
            print(gameManager.currentPlayer)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
