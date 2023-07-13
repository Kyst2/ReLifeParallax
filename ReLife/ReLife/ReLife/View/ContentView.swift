//
//  ContentView.swift
//  ReLife
//
//  Created by Andrew Kuzmich on 07.07.2023.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
//    @ObservedObject var manager = MotionManager()
    
    var body: some View {
        ZStack{
            ParallaxView()
        }
        
   
//        Color.red
//                    .frame(width: 100, height: 100, alignment: .center)
//                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
