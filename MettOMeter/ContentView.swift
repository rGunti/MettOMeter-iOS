//
//  ContentView.swift
//  MettOMeter
//
//  Created by Raphael Guntersweiler on 25.11.19.
//  Copyright © 2019 Raphael Guntersweiler. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tracker: LocationTracker
    @State var showAboutDialog = false
    @State var showErrorDialog = false
    
    var yearFormatter: DateFormatter {
        get {
            let d = DateFormatter()
            d.dateFormat = "yyyy"
            return d
        }
    }
    var currentYear: String {
        get {
            return self.yearFormatter.string(from: Date())
        }
    }
    
    var currentLocationAccuracy: String {
        get {
            let accuracy = self.tracker.currentLocationAccuracy
            if (accuracy < 0) { return "No Fix …" }
            else { return String(format: "± %.0f m", accuracy) }
        }
    }
    
    var speedInfoTime: Double {
        get {
            return Date().timeIntervalSince(self.tracker.lastSpeedReceived)
        }
    }
    
    var hasSpeedInfoExpired: Bool {
        get {
            return false
        }
    }
    
    var body: some View {
        VStack {
            if speedInfoTime > 10 {
                VStack {
                    Text("Schlechte GPS-Verbindung")
                        .bold()
                    Text("Kann GPS-Geschwindigkeit nicht bestimmen.\nBegib Dich nach draussen und überprüfe ob dein Gerät GPS unterstützt.")
                        .multilineTextAlignment(.center)
                    Button("Mehr Info") {
                        self.showErrorDialog = true
                    }.alert(isPresented: $showErrorDialog, content: {
                        Alert(title: Text("Schlechte GPS-Verbindung"),
                              message: Text("Aufgrund schlechter GPS-Verbindung kann die Geschwindigkeit nicht ermittelt werden.\n\nBeachte, dass ein iPad ohne SIM-Modul oder ein iPod touch kein GPS-Modul besitzt und die aktuelle Geschwindigkeit nicht bestimmen kann."),
                              dismissButton: .default(Text("OK")))
                    }).accentColor(Color.yellow)
                }.background(Color.red)
                Spacer()
            } else {
                Spacer()
            }
            
            Spacer()
            
            VStack {
                if (tracker.isSpeedInfoAvailable) {
                    Text("\(Int(tracker.currentSpeedMettbPs))")
                        .font(.system(size: 150))
                        //.background(Color.red)
                } else {
                    Text("---")
                        .font(.system(size: 150))
                        .foregroundColor(Color.gray)
                }

                HStack {
                    Image("Bread")
                    Text("/ sec")
                }//.background(Color.red)
            }//.background(Color.orange)

            Spacer()
            
            VStack {
                if (tracker.isSpeedInfoAvailable) {
                    Text("\(Int(tracker.currentSpeedKmh))")
                        .font(.system(size: 30))
                } else {
                    Text("---")
                        .font(.system(size: 30))
                        .foregroundColor(Color.gray)
                }

                Text("km/h")
            }

            Spacer()

            VStack {
                Text("Standort-Genauigkeit:")
                    .italic()
                Text(currentLocationAccuracy)
                    .italic()
            }
            
            Spacer()

            Button("Über MettOMeter") {
                self.showAboutDialog = true
            }.alert(isPresented: $showAboutDialog, content: {
                Alert(title: Text("Über MettOMeter"),
                      message: Text("© \(currentYear), rGunti\n\nAuf Basis eines Podcasts entstanded zeigt diese App die aktuelle Geschwindigkeit in Mettbrötchen pro Sekunde an, wobei ein Mettbrötchen einer Länge von \(Int(tracker.breadSize)) cm entspricht.\n\nShoutout an Oli und Flo von \"Die Sprechstunde\" für den Insider :D\n\nDiese App ist zur reinen Unterhaltung gedacht und ist in keinem Fall für die Nutzung im Strassenverkehr geeignet. Die Nutzung dieser App geschieht auf eigene Gefahr.\n\nBread icon by icons8.com\n\nApp Icon uses base material licensed under CC BY-SA 3.0 by Nicolai Schäfer. (https://creativecommons.org/licenses/by-sa/3.0/)"),
                      dismissButton: .default(Text("OK")))
            })
        }.padding(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
