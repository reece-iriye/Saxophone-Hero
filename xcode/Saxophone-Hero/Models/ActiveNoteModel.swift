//
//  ActiveNoteModel.swift
//  Saxophone-Hero
//
//  Created by Ethan Haugen on 12/6/23.
//

import UIKit

class ActiveNoteModel: NSObject {
    
    var note:Int = 13
    var timeData:[Float] = []
    
    
    
    func getCurrentNote() -> Int{
        return note
    }
    
    func updateData(timeData:[Float]) {
        self.timeData = timeData
    }
    
    func queryModel() {
        
    }
}
