//
//  tester.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

import SwiftLED
import Dispatch
import Foundation

@main
public struct Tester {
    public static func main() {
        print("This is a test")
        
        var options = MatrixOptions()
        options.hardware_mapping = "adafruit-hat-pwm"
        options.rows = 32
        options.cols = 64
        options.disable_hardware_pulsing = true
        options.limit_refresh_rate_hz = 60
        
        var runtimeOptions = RuntimeOptions()
        runtimeOptions.gpio_slowdown = 4
        
        let matrix = LEDMatrix(options: options, runtimeOptions: runtimeOptions)
        
        guard let canvas = matrix.getCanvas() else {
            print("Failed to get canvas")
            return
        }
        
        guard let offscreenCanvas = matrix.createOffscreenCanvas() else {
            print("Failed to create offscreen canvas")
            return
        }
        
        canvas.fill(with: Color(r: 3, g: 219, b: 252))
        offscreenCanvas.fill(with: Color(r: 189, g: 36, b: 209))
                
        let startTime = ProcessInfo.processInfo.systemUptime
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let swapStartTime = ProcessInfo.processInfo.systemUptime
            print("Swap start at \(swapStartTime - startTime)")
            matrix.swapCanvasOnVSync(offscreenCanvas)
            let swapCompletetime = ProcessInfo.processInfo.systemUptime
            print("Swap completed at \(swapCompletetime - startTime)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // clean up and exit after 10 seconds
            let exitTime = ProcessInfo.processInfo.systemUptime
            print("Exiting at \(exitTime - startTime)")
            exit(0)
        }
        
        dispatchMain()
    }
}
