//
//  StepOnLadnminesViewController.swift
//  Step On Landmines
//
//  Created by Ryan Chang on 2021/6/18.
//

import UIKit
import CoreData

class StepOnLandminesViewController: UIViewController {
    
    var container: NSPersistentContainer! //core data 使用
    var leaderBoardList = [LeaderBoard]() //呼叫core data 的型別
    
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet var landMinesButtons: [UIButton]!
    var column: Int = 5 //行數
    var row: Int = 5 //列數
    var recordLand:[Int] = []//設置地雷的陣列
    var abomb: [Int] = []//存取地雷與無地雷數字的陣列
    var boolBomb:[Bool] = []//檢查無地雷的地板掀開數量 true:有地雷 false:無地雷
    var bomb:[[Int]] = [] //地雷位置紀錄
    
    var timer : Timer? //宣告使用計時器
    var ms = 0 //計算毫秒基數
    
    var leaderboardA:[String] = [] //計分板
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var thirdNameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getRecord() //呼叫core data的資料
        
        setFloor()//生成地圖
        setBumb()//生成地雷隨機放置在地圖裡
        otherFloor()//沒有地雷的地圖做標示
        finalLandminesMap()//列印出整張地圖（看解答用）
        setBombToButton()//把炸彈的位置跟UIButton的位置做連接
        // Do any additional setup after loading the view.
    }
    
  
    //設置地板顏色 同時把recordLand /abomb /boolBomb 的陣列內容加入
    func setFloor(){
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
    
    
    //設置炸彈數量 基礎設定為地圖全部的 3/10
    func setBumb(){
        let bombNumber = Int(row * column * 3 / 10) //炸彈數目
        for _ in 1...row{
            var bombRow: [Int] = [] //炸彈行數
            for _ in 1...column{
                bombRow.append(0)
            }
            bomb.append(bombRow) //把一維陣列存到一個陣列裡面變成二維陣列
        }
        
        //使用arc4random來隨機生成炸彈位置
        for _ in 1 ... bombNumber{
            let a = Int(arc4random()) % recordLand.count
            let index = recordLand[a]
            bomb[index % row][index / row] = -1 //
            recordLand.remove(at: a) //移除陣列內容避免位置重複
        }
    }
    
    //把沒有地雷的地板座標傳入 findBumb() 用來畫出沒有地雷的地板周圍有幾顆地雷
    func otherFloor() -> Void {
        for i in 0..<row{
            for j in 0..<column{
                if bomb[i][j] != -1{
                    bomb[i][j] = findNonLandmines(x: j, y: i)  //這裡的x & y 分別是j & i
                }
            }
        }
    }
    //把沒有地雷的地板設置四周的數字,findBumb中給的x,y表示地雷圖中的第y列第x行，用二維陣列來看 bomb[i][j] i指的是上下即Ｙ軸，j指的是左右即Ｘ軸
    func findNonLandmines(x:Int, y:Int) -> Int{
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
    func finalLandminesMap(){
        for i in 0 ..< bomb.count{
            for j in bomb[i]{
                print(String(format: "%2d ",j),terminator: "")
            }
            print()
        }
        print()
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
            self.stopTimer()
            let controller = UIAlertController(title: "恭喜你！！", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default){ [self]_ in
                buttonEnable()
            }
            controller.addAction(action)
            present(controller, animated: true) {[self] in
                record() //把時間丟入排名裡面
//                save(first: firstLabel.text!, second: secondLabel.text!, thrid: thirdLabel.text!)//把排行榜存入core data
            }
        }
    }
    
    //讓button 不能動作,否則遊戲結束還可以繼續操作button
    func buttonEnable(){
        if landMinesButtons[0].isEnabled == true {
            for i in 0...24{
                landMinesButtons[i].isEnabled = false
            }
        }else {
            for i in 0...24{
                landMinesButtons[i].isEnabled = true
            }
            
        }
    }
    
    //把用來存取的陣列都清除
    func resetAllArray(){
        abomb.removeAll()
        bomb.removeAll()
        boolBomb.removeAll()
    }
    
    
    // 計時器的部分
    //計時器開始
    func startTimer(){
        timer?.invalidate()//為確保Timer.scheduledTimer不會因為重複呼叫而無法停止，所以先宣告停止再重新跑一次Timer.scheduledTimer
        //執行間隔為0.01則表示每毫秒
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(startCount), userInfo: nil, repeats: true)
    }
    
    //計時器停止
    func stopTimer(){
        timer?.invalidate()//讓timer停止不要在背景運作
    }
    
    //每0.01秒更改一次clockLabel，看起來就會像碼表一樣
    @objc func startCount(){
     ms += 1 //每次執行+1就是執行一毫秒
     let min = ms / 6000
     let sec = (ms / 100) % 60
     let milSec = ms % 100
     
     let showMin = min > 9 ? "\(min)" : "0\(min)"
     let showSec = sec > 9 ? "\(sec)" : "0\(sec)"
     let showMilSec = milSec > 9 ? "\(milSec)" : "0\(milSec)"
     
     let timeString = "\(showMin):\(showSec).\(showMilSec)"
     self.clockLabel.text = timeString
     }
    
    //把前三名的時間（字串）和遊戲完成的時間（字串）都丟到array並且排列，之後再丟出前三個
    func record(){
        let a = clockLabel.text!
        let b = firstLabel.text!
        let c = secondLabel.text!
        let d = thirdLabel.text!
        
        leaderboardA.append(a)
        leaderboardA.append(b)
        leaderboardA.append(c)
        leaderboardA.append(d)
        leaderboardA.sort() //排序文字
        
        firstLabel.text = leaderboardA[0]
        secondLabel.text = leaderboardA[1]
        thirdLabel.text = leaderboardA[2]
        
        save(first: leaderboardA[0], second: leaderboardA[1], thrid: leaderboardA[2])
        leaderboardA.removeAll()
    }
    
    //存入core data
    func save(first:String, second:String, thrid:String){
        
        let context = container.viewContext
        let aList = LeaderBoard(context: context)
        let bList = LeaderBoard(context: context)
        let cList = LeaderBoard(context: context)

        while leaderBoardList.count > 0 {
        context.delete(leaderBoardList[leaderBoardList.count - 1])
        leaderBoardList.removeLast()
        }
        
        aList.time = first
        leaderBoardList.append(aList)

        bList.time = second
        leaderBoardList.append(bList)
        
        cList.time = thrid
        leaderBoardList.append(cList)
    
        container.saveContext() //core data儲存
    }
    
    //取得core data紀錄
    func getRecord() {
        let context = container.viewContext
        do {
            leaderBoardList = try context.fetch(LeaderBoard.fetchRequest())
        } catch {
            print("error")
        }
        
        
        if leaderBoardList.count != 0{
            for _ in 1 ... 3 {
                leaderboardA.append("")
            }
            
            leaderboardA[0] = leaderBoardList[0].time!
            leaderboardA[1] = leaderBoardList[1].time!
            leaderboardA[2] = leaderBoardList[2].time!
            leaderboardA.sort()
            
            firstLabel.text = leaderboardA[0]
            secondLabel.text = leaderboardA[1]
            thirdLabel.text = leaderboardA[2]
            leaderboardA.removeAll()
        }
        
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
        stopTimer()
        clockLabel.text = "00:00.00"
        ms = 0
        resetAllArray()
        setFloor()
        setBumb()
        otherFloor()
        finalLandminesMap()
        setBombToButton()
        landMinesButtons[0].isEnabled = false
        buttonEnable()
    }
    
    
    @IBAction func changeColor(_ sender: UIButton) {
        //開始計時
        startTimer()
        if abomb[sender.tag] == -1 { //按到-1等於踩到地雷
            //結束計時
            stopTimer()

            //掀開全部地板
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
            
            buttonEnable()//關閉按鈕，避免在遊戲結束的狀況下還可以繼續使用UIButton
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }else {
            landMinesButtons[sender.tag].setTitle(String(abomb[sender.tag]), for: .normal)
            landMinesButtons[sender.tag].backgroundColor = UIColor.white
            boolBomb[sender.tag] = false
        }
        checkFloor() //計算沒有地雷且還沒掀開的地板數量
    }
    
    
    //復原排行榜 /看起來像是清除紀錄，實際上是把 59:59.99 全部存回去coredata裡面
    @IBAction func clearRecord(_ sender: UIButton) {

        while leaderBoardList.count > 0 {
        let context = container.viewContext
        context.delete(leaderBoardList[leaderBoardList.count - 1])
        leaderBoardList.removeLast()
        }
        
        firstLabel.text = "59:59.99"
        secondLabel.text = "59:59.99"
        thirdLabel.text = "59:59.99"
        
        container.saveContext()

        
    }
}



