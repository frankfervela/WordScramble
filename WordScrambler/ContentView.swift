//
//  ContentView.swift
//  WordScrambler
//
//  Created by Frank Fernandez on 11/29/19.
//  Copyright © 2019 Frank Fernandez. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMEssage = ""
    
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var usedWords = [String]()
    
    @State private var points = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining = 10
    @State private var gameStarted = false
    @State private var pausedGame = true
    
    @State private var timeRanOut = false
    @State private var startCountDown = false
    @State private var bgColors = calculateRGB(red: 235, green: 150, blue: 200)
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    //MARK: - Welcome Screen
                    if pausedGame && !gameStarted{
                        Button(action: {
                            self.restartGame()
                            self.pausedGame = false
                        }, label: {
                            Text("Play")
                                .frame(width: 200)
                                .padding()
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .background(Color(red: bgColors[0], green: bgColors[1], blue: bgColors[2]))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color(.white), lineWidth: 3))
                                .shadow(color: .black, radius: 5)
                            
                        }).padding(.bottom, 60)
                    }
                    
                    
                    //MARK: - Game Screen
                    if gameStarted && !pausedGame{
                        TextField("Find possible words..", text: $newWord) {
                            
                            self.validateInput(input: self.newWord)
                            
                            
                        }
                        .padding()
                        .autocapitalization(.none)
                        
                        
                        
                        
                        List(usedWords, id: \.self){
                            Image(systemName: "\($0.count).circle")
                            Text($0)
                        }
                            
                        .alert(isPresented: $showAlert) { () -> Alert in
                            Alert(title: Text(alertTitle), message: Text(alertMEssage))
                        }
                        
                        
                    }
                }
                .navigationBarTitle(gameStarted == true ? rootWord : "")
                .navigationBarItems(leading: HStack{
                    if !pausedGame{
                        Button(action: restartGame, label: {
                            Text("START NEW GAME")
                                .foregroundColor(.black)
                                .bold()
                            .underline()
                            
                        })
                        
                    }
                    }, trailing: VStack {
                        
                        if !pausedGame{
                            HStack {
                                Image(systemName: "\(String(points)).circle")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 50)
                                    .padding(.trailing, 20)
                                
                            }
                        }
                        
                })
            }
            
        }
            
            
        .alert(isPresented: $timeRanOut) { () -> Alert in
            Alert(title: Text("Time Ran out"), message: Text("You ran out of time"), dismissButton: .default(Text("Play Again")){
                self.restartGame()
                })
        }
        
    }
    
    //Checks whether or not the file is found and if its data can be read. Assigs all the values found inside the text file inside athe root word variable
    func readWord() -> (Bool){
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let fileContent = try? String(contentsOf: fileURL){
                self.rootWord = fileContent.components(separatedBy: .whitespacesAndNewlines).randomElement() ?? "error"
                return true
            }
        }
        return false
    }
    
    func restartGame(){
        
        if readWord(){
            timeRanOut = false
            gameStarted = true
            pausedGame = false
            timeRemaining = 10
            points = 0
            usedWords = [String]()
        }
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let possible = tempWord.firstIndex(of: letter){
                tempWord.remove(at: possible)
            }else{
                return false
            }
        }
        return true
    }
    
    func makesSense(word: String) -> (Bool) {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let mispelledWords = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledWords.location == NSNotFound ? true : false
    }
    
    
    func isRepeated(word: String) -> (Bool){
        return usedWords.contains(word) ? true : false
    }
    
    func addWord(word: String){
        usedWords.insert(word, at: 0)
    }
    
    static func calculateRGB(red: Double, green : Double, blue : Double) -> ([Double]){
        let total = 255.0
        
        var rgb : [Double] = []
        
        let redPartTimesHundred = red * 100
        let greenPartTimesHundred = green * 100
        let bluePartTimesHundred = blue * 100
        
        let red = redPartTimesHundred / total
        let green = greenPartTimesHundred / total
        let blue = bluePartTimesHundred / total
        
        rgb.append(red / 100)
        rgb.append(green / 100)
        rgb.append(blue / 100)
        
        return rgb
    }
    
    func validateInput (input: String) {
        
        if !self.isPossible(word: input){
            //Title and message for he alert depending on the putput of the isRepeated function
            self.alertMEssage = "You Gotta use letters from that word in the title. Dont try to be slick"
            self.alertTitle = "Invalid Letters."
            
            //Toggling the alert state variable
            self.showAlert = true
            self.newWord = ""
        }
        else if self.isRepeated(word: input){
            //Title and message for he alert depending on the putput of the isRepeated function
            self.alertMEssage = "This word already exist in the list. Choose a different one"
            self.alertTitle = "Already Exist"
            
            //Toggling the alert state variable
            self.showAlert = true
            self.newWord = ""
            
        }
        else if !self.makesSense(word: input){
            self.alertMEssage = "Wth did you try to say here? This word doesnt exist"
            self.alertTitle = "Invalid Word.."
            
            //Toggling the alert state variable
            self.showAlert = true
            self.newWord = ""
        }
        else{
            self.addWord(word: self.newWord)
            self.points += self.newWord.count
            self.newWord = ""
        }
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
