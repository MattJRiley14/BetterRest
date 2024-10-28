//
//  ContentView.swift
//  BetterRest
//
//  Created by BCCS 2022 on 10/22/24.
//

import CoreML

import SwiftUI

struct ContentView: View {
    // @State private var wakeUp = Date.now
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            // VStack {
            Form {
                // CHALLENGE 1
                Section ("When do you want to wake up?") {
                // VStack(alignment: .leading, spacing: 0) {
                    // Text("When do you want to wake up?")
                        // .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                // CHALLENGE 1
                Section ("Desired amount of sleep") {
                // VStack(alignment: .leading, spacing: 0){
                    // Text("Desired amount of sleep")
                        // .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

                // CHALLENGE 1
                Section ("Daily coffee intake") {
                // VStack(alignment: .leading, spacing: 0){
                    // Text("Daily coffee intake")
                        // .font(.headline)

                    // Stepper(coffeeAmount == 1 ? "\(coffeeAmount) cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    // Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)

                    // CHALLENGE 2
                    // Adding one since the ForEach starts at index of 0
                    Picker("\(coffeeAmount + 1) cups", selection: $coffeeAmount){
                        ForEach(1..<21){
                            Text("\($0) cups")
                        }
                    }

                }

                // CHALLENGE 3
                Section ("Your ideal bedtime is...") {
                    Text(alertTitle)
                        .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
            
            // CHALLENGE 3 (COMMENTED OUT)
            // .toolbar {
            //    Button("Calculate", action: calculateBedtime)
            // }
            // .alert(alertTitle, isPresented: $showingAlert){
            //     Button("OK") {}
            // } message: {
            //     Text(alertMessage)
            // }
        }
    }
    
    func calculateBedtime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // CHALLENGE 2
            // Adding one to coffeeAmount because the selected amount is one more than the stored amount
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
