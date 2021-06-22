//
//  ViewController.swift
//  Step On Landmines
//
//  Created by Ryan Chang on 2021/6/16.
//

import UIKit

class ViewController: UIViewController {
    
    var t_r: Int = 3
    var t_l: Int = 5
    var t_width: Int = 50
    var t_hight: Int = 50
    let t_margin_x: Int = 75
    let t_margin_y: Int = 100
    
    var bBtns: [UIButton] = []
    var ctn:Int = 0
    var ctns: [Int] = []
    
    var bobPic:[[Int]] = []
    
    var bobSw: UISwitch = UISwitch(frame: CGRect(x: 175, y: 50, width: 50, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newGame()
        // Do any additional setup after loading the view.
    }
    
    func newGame() {
        bBtns = []
        ctn = 0
        ctns = []
        
        for i in stride(from: 0, to: t_r, by: 1){
            var bobPicRow: [Int] = []
            
            for j in stride(from: 0, to: t_l, by: 1){
                let btn = UIButton()
                btn.frame = CGRect(x: t_margin_x + j * t_width, y: t_margin_y + i * t_hight, width: t_width, height: t_hight)
                if (i % 2 == 0) {
                    btn.backgroundColor = j % 2 == 0 ? UIColor.gray : UIColor.darkGray
                }else {
                    btn.backgroundColor = j % 2 != 0 ? UIColor.gray : UIColor.darkGray
                }
                view.addSubview(btn)
                
                bBtns.append(btn)
                ctns.append(ctn)
                ctn += 1
                bobPicRow.append(0)
                btn.isEnabled = true
            }
            bobPic.append(bobPicRow)
        }
        setBob()
        setAns()
        poBobPic()
        self.view.addSubview(bobSw)
        bobSw.addTarget(self, action: #selector(swChange(_:)), for: .valueChanged)
        bobSw.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
    }
    
   @objc func clickButton() {
        // 為基底的 self.view 的底色在黑色與白色兩者間切換
        if self.view.backgroundColor!.isEqual(
            UIColor.white) {
            self.view.backgroundColor =
                UIColor.black
        } else {
            self.view.backgroundColor =
                UIColor.white
        }
    }
    
    @objc func swChange(_ sender:UISwitch){
        for i in 0 ..< bobPic.count{
            for j in 0 ..< bobPic[i].count {
                if bobSw.isOn {
                    bBtns[i * t_l + j].setTitle(String(bobPic[i][j]), for: .normal)
                }else {
                    bBtns[i * t_l + j].setTitle("", for: .normal)
                }
            }
        }
    }
    
    func setBob(){
        let numberBob = t_r * t_l * 3 / 10
        
        for _ in 1...numberBob{
            let r = Int(arc4random()) % ctns.count
            let bobIndex = ctns[r]
            bobPic[bobIndex / t_l][bobIndex % t_l] = -1
            ctns.remove(at: r)
        }
    }
    
    func poBobPic(){
        for i in 0..<bobPic.count {
            for j in bobPic[i]{
                print(String(format: "%2d ", j), terminator: "")
            }
            print()
        }
    }
    
    func setAns(){
        for i in 0 ..< t_r{
            for j in 0 ..< t_l{
                if bobPic[i][j] != -1{
                    bobPic[i][j] = fBobNumbet(x:j, y:i)
                }
            }
        }
    }
    
    func fBobNumbet(x:Int ,y:Int) -> Int{
        var number = 0
        let left :Int = x - 1 < 0 ? x : x - 1
        let right : Int = x + 1 == t_l ?  x : x + 1
        let top : Int = y - 1 < 0 ? y : y - 1
        let bottom :Int = y + 1 == t_r ? y : y + 1
        for i in top ... bottom {
            for j in left ... right{
                if (bobPic[i][j] == -1){
                     number += 1
                }
            }
        }
        return number
    }
    
    
    
    
}
