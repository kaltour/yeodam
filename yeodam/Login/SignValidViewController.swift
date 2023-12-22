//
//  SignValidViewController.swift
//  yeodam
//
//  Created by Kaltour_Dawoon on 12/19/23.
//

import UIKit
import SnapKit


class SignValidViewController: UIViewController {
    
    var fullNameString: String = ""
    
    var fullNameLabel:UILabel = {
        let lb = UILabel()
        return lb
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        view.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
     
        fullNameLabel.text = fullNameString


        // Do any additional setup after loading the view.
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
