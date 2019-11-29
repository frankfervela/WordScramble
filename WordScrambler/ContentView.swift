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
    
    var body: some View {
        NavigationView {
            VStack {
                
                TextField("Find possible words..", text: $newWord) {
                    
                    if !self.isPossible(word: self.newWord){
                        //Title and message for he alert depending on the putput of the isRepeated function
                        self.alertMEssage = "You Gotta use letters from that word in the title. Dont try to be slick"
                        self.alertTitle = "Invalid Letters."
                        
                        //Toggling the alert state variable
                        self.showAlert.toggle()
                        self.newWord = ""
                    }
                    else if self.isRepeated(word: self.newWord){
                        //Title and message for he alert depending on the putput of the isRepeated function
                        self.alertMEssage = "This word already exist in the list. Choose a different one"
                        self.alertTitle = "Already Exist"
                        
                        //Toggling the alert state variable
                        self.showAlert.toggle()
                        self.newWord = ""
                        
                    }
                    else if !self.makesSense(word: self.newWord){
                        self.alertMEssage = "Wth did you try to say here? This word doesnt exist"
                        self.alertTitle = "Invalid Word.."
                        
                        //Toggling the alert state variable
                        self.showAlert.toggle()
                        self.newWord = ""
                    }
                    else{
                        self.addWord(word: self.newWord)
                        self.newWord = ""
                    }
                    
                    
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
            .navigationBarTitle(rootWord)
        }
        .onAppear {
            if !self.readWord(){
                fatalError("There was a problem loading the file")
            }
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
    
    func validLetter(word: String) -> Bool{
        
        
        return true
    }
    
    
    func isRepeated(word: String) -> (Bool){
        return usedWords.contains(word) ? true : false
    }
    
    func addWord(word: String){
        usedWords.insert(word, at: 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
