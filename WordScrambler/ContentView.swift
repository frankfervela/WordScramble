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
    @State private var usedWords = [""]
    
    var body: some View {
        NavigationView {
            VStack {
                
                TextField("Find possible words..", text: $newWord) {
                    
                    if self.isRepeated(word: self.newWord){
                        //Title and message for he alert depending on the putput of the isRepeated function
                        self.alertMEssage = "This word already exist in the list. Choose a different one"
                        self.alertTitle = "Already Exist"
                        
                        //Toggling the alert state variable
                        self.showAlert.toggle()
                        self.newWord = ""
                        
                    }else{
                        self.addWord(word: self.newWord)
                    }
                    
                    
                }
                .padding()
                .autocapitalization(.none)
                
                List(usedWords, id: \.self){
                    Text($0)
                }
                .alert(isPresented: $showAlert) { () -> Alert in
                    Alert(title: Text(alertTitle), message: Text(alertMEssage), dismissButton: .default(Text("Ok")))
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
    
    //Checks whether or not the file is found and if its data can be read. Assigs all the values found inside the text file inside an array
    func readWord() -> (Bool){
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let fileContent = try? String(contentsOf: fileURL){
                self.rootWord = fileContent.components(separatedBy: .whitespacesAndNewlines).randomElement() ?? "error"
                return true
            }
        }
        return false
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
