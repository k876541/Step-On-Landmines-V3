//
//  StepOnLadnminesViewController.swift
//  Step On Landmines
//
//  Created by Ryan Chang on 2021/6/18.
//

import UIKit


class StepOnLadnminesViewController: UIViewController {
    
    
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet var landMinesButtons: [UIButton]!
    @IBOutlet weak var startButton: UIButton!
    var bomb:[[Int]] = [] //炸彈位置紀錄
    var column: Int = 5 //行數
    var row: Int = 5 //列數
    var recordLand:[Int] = []//設置地雷的陣列
    var abomb: [Int] = []//存取地雷與無地雷數字的陣列
    var boolBomb:[Bool] = []//檢查無地雷的地板掀開數量

    
    var timer : Timer? //宣告使用計時器
    var timerState = false // false: 暫停 ; true: 播放
    var ms = 0 //計算基數
    var start = false //使用Bool來讓同一個按鈕可以做不同的事情
    
    var min = 0
    var sec = 0
    var milSec = 0
    
    var showMin = ""
    var showSec = ""
    var showMilSec = ""
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        changColor()
        setBumb()
        ans()
        final()
        setBombToButton()
        
        // Do any additional setup after loading the view.
    }
    
    //設置地板顏色
    func changColor(){
        for i in 0...(row * column) - 1{
            if landMinesButtons[i].tag % 2 == 0{
                landMinesButtons[i].backgroundColor = UIColor.darkGray
            }else{
                landMinesButtons[i].backgroundColor = UIColor.gray
            }
            landMinesButtons[i].titleLabel?.text = String(i)
            recordLand.append(i)
            abomb.append(i)
            boolBomb.append(true)
        }
    }
    
    
    //設置炸彈
    func setBumb(){
        let bombNumber = Int(row * column * 2 / 10) //炸彈數目
        for _ in 1...row{
            var bombRow: [Int] = [] //炸彈行數
            for _ in 1...column{
                bombRow.append(0)
            }
            bomb.append(bombRow)
        }
        
        //使用arc4random來隨機生成炸彈位置
        for _ in 1 ... bombNumber{
            let a = Int(arc4random()) % recordLand.count
            let index = recordLand[a]
            bomb[index % row][index / row] = -1
            recordLand.remove(at: a)
        }
    }
    
    //把沒有地雷的地板座標傳入 findBumb()
    func ans(){
        for i in 0..<row{
            for j in 0..<column{
                if bomb[i][j] != -1{
                    bomb[i][j] = findBumb(x: j, y: i)  //這裡的x & y 分別是j & i
                }
            }
        }
    }
    
    //把沒有地雷的地板設置四周的數字,findBumb中給的x,y表示地雷圖中的第y列第x行
    func findBumb(x:Int, y:Int) -> Int{
        var number = 0
        let left = x - 1 < 0 ? x : x - 1
        let right = x + 1 == column ? x : x + 1
        let top = y - 1 < 0 ? y : y - 1
        let buttom = y + 1 == row ? y : y + 1
        for i in top ... buttom {
            for j in left ... right{
                if bomb[i][j] == -1{
                    number += 1
                }
            }
        }
        return number
    }
    
    //列印出目前二維陣列(地雷)地圖
    func final(){
        for i in 0 ..< bomb.count{
            for j in bomb[i]{
                print(String(format: "%2d ",j),terminator: "")
            }
            print()
        }
    }
    
    //把炸彈位置存到abomb[Int]用來跟[UIButton]做應對
    func setBombToButton(){
        var n = 0
        for i in 0 ..< row{
            for j in 0 ..< column{
                abomb[n] = bomb[i][j]
                if abomb[n] == -1{
                    boolBomb[n] = false
                }
                landMinesButtons[n].setTitle("", for: .normal)
                n += 1
            }
        }
        print(abomb)
    }
    
    func restart(){
        abomb.removeAll()
        bomb.removeAll()
        boolBomb.removeAll()
    }
    
    //計算沒有地雷且還沒掀開的地板數量
    func checkFloor(){
        var count = 0
        for i in 0 ..< row * column{
            if boolBomb[i] == true {
                count += 1
            }
        }
        //如果count == 0 則代表沒有地雷的地板都掀開了
        if count == 0 {
            let controller = UIAlertController(title: "恭喜你！！", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            controller.addAction(action)
            present(controller, animated: true,completion: nil)
        }
    }
    
    func startTimer(){
        //執行間隔為0.01則表示每毫秒
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(startCount), userInfo: nil, repeats: true)
        startButton.setTitle("停止", for:.normal)
        startButton.setTitleColor(.red, for: .normal)
    }
    
    func stopTimer(){
        timer?.invalidate()//讓timer停止不要在背景運作
        ms = 0
        startButton.setTitle("開始", for:.normal)
        startButton.setTitleColor(.blue, for: .normal)
    }
    
    
    @objc func startCount(){
     ms += 1 //每次執行+1就是執行一毫秒
     min = ms / 6000
     sec = (ms / 100) % 60
     milSec = ms % 100
     
     showMin = min > 9 ? "\(min)" : "0\(min)"
     showSec = sec > 9 ? "\(sec)" : "0\(sec)"
     showMilSec = milSec > 9 ? "\(milSec)" : "0\(milSec)"
     
     let timeString = "\(showMin):\(showSec).\(showMilSec)"
     self.clockLabel.text = timeString
     }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func restartButton(_ sender: UIButton) {
        restart()
        changColor()
        setBumb()
        ans()
        final()
        print()
        setBombToButton()
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        startTimer()
        
        if abomb[sender.tag] == -1 {
            stopTimer()

            //掀開地板
            for i in 0 ..< row * column{
                landMinesButtons[i].setTitle(String(abomb[i]), for: .normal)
                if abomb[i] == -1 {
                    landMinesButtons[i].backgroundColor = UIColor.red
                }else {
                    landMinesButtons[i].backgroundColor = UIColor.white
                }
            }
            
            let controller = UIAlertController(title: "你爆了！！", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }else {
            landMinesButtons[sender.tag].setTitle(String(abomb[sender.tag]), for: .normal)
            landMinesButtons[sender.tag].backgroundColor = UIColor.white
            boolBomb[sender.tag] = false
        }
        checkFloor() //計算沒有地雷且還沒掀開的地板數量
    }
    
    
    
    
    
    
    
}
