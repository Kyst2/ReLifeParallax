//
//  ContentView.swift
//  ReLife
//
//  Created by Andrew Kuzmich on 07.07.2023.
//

import SwiftUI
import CoreMotion
//import KystParallax

struct ContentView: View {
    
//    @ObservedObject var manager = MotionManager()
    
    var body: some View {
        Spacer()
            .frame(minWidth: 300, minHeight: 300)
            .background{
                ZStack {
#if os(iOS)
                    ParallaxLayer(image: Image("depth-1"), magnitude : 10)
                    ParallaxLayer(image: Image("depth-2"), magnitude : 10)
                    ParallaxLayer(image: Image("depth-3"), magnitude : 10)
#elseif os(macOS)
                    ParallaxLayer(image: Image("depth-1"), speed: 10)
                    ParallaxLayer(image: Image("depth-2"), speed: 30)
                    ParallaxLayer(image: Image("depth-3"), speed: 50)
#endif
                }
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

#if os(iOS)
public struct ParallaxLayer:View {
    @ObservedObject var manager = MotionManager()
    
    var image:Image
    var magnitude:Int
    
    public var body: some View {
        image
            .modifier(ParallaxMotionModifier(manager: manager, magnitude: magnitude ))
    }
    
    public init(image: Image, magnitude: Int) {
        self.image = image
        self.magnitude = magnitude
    }
}

struct ParallaxMotionModifier: ViewModifier {
    @ObservedObject var manager: MotionManager
    var magnitude: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
    }
}

public class MotionManager: ObservableObject {
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    private var manager: CMMotionManager
    
    public init() {
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1/60
        self.manager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let motionData = motionData {
                self.pitch = motionData.attitude.pitch
                self.roll = motionData.attitude.roll
            }
        }
    }
}

#elseif os(macOS)
@available(macOS 10.15, *)
public struct ParallaxLayer: View {
    let image: Image
    
    let speed: CGFloat
    
//    @State private var xOffsetOld: CGFloat = 0
//    @State private var yOffsetOld: CGFloat = 0
    
    @State private var absXOffset: CGFloat = 0
    @State private var absYOffset: CGFloat = 0
    
    @State private var isMouseInside: Bool = false
    @State private var previousMousePosition: CGPoint = .zero
    
    public var body: some View {
            image
                .offset(x: absXOffset, y: absYOffset)
                .onAppear {
                    NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .mouseEntered, .mouseExited]) { event in
                        guard let window = NSApp.windows.first(where: { $0.isVisible }),
                              let contentView = window.contentView else {
                            return event
                        }
                        
                        let mouseLocation = event.locationInWindow
                        let mouseInView = contentView.convert(mouseLocation, from: nil)
                        
                        if event.type == .mouseEntered {
                            isMouseInside = true
                        } else if event.type == .mouseExited {
                            isMouseInside = false
                        }
                        
                        if isMouseInside {
                            let windowRect = window.frame
                            let windowOrigin = windowRect.origin
                            
                            let windowCenter = NSPoint(x: windowOrigin.x + windowRect.width / 2, y: windowOrigin.y + windowRect.height / 2)
                            
                            let mousePosRelatedToWndCenter = NSPoint(x: mouseInView.x - windowCenter.x, y: mouseInView.y - windowCenter.y)
                            
                            /// -1...1 * speed
                            let tempAbsXOffset = (mouseInView.x / windowRect.width  - 0.5) * 2 * speed
                            
                            let delta = abs(absXOffset - tempAbsXOffset)
                            
                            absXOffset += (tempAbsXOffset - absXOffset) / (speed / 10)
                            
                            
                            previousMousePosition = mousePosRelatedToWndCenter
                        }
                        
                        return event
                    }
                
        }
    }

    public init(image: Image, speed: CGFloat = 1) {
        self.image = image
        self.speed = speed
    }
}




#endif
