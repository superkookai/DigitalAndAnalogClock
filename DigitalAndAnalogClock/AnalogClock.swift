//
//  AnalogClock.swift
//  DigitalAndAnalogClock
//
//  Created by Weerawut Chaiyasomboon on 01/05/2568.
//

import SwiftUI

struct AnalogClock: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date
            ClockView(date: date)
        }
        .frame(width: 300, height: 300)
    }
}

struct ClockView: View {
    let date: Date
    let centerPointRadius = 3.0
    let circleInset = 10.0
    
    var body: some View {
        Canvas {
            context,
            size in
            
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius = min(size.width,size.height)/2 - circleInset
            
            let calendar = Calendar.current
            let seconds = calendar.component(.second, from: date)
            let minutes = calendar.component(.minute, from: date)
            let hours = calendar.component(.hour, from: date) % 12
            
            //Center dot
            let centerCircle = Path(
                ellipseIn: CGRect(
                    x: center.x - centerPointRadius,
                    y: center.y - centerPointRadius,
                    width: centerPointRadius*2,
                    height: centerPointRadius*2
                )
            )
            context.fill(centerCircle, with: .color(.black))
            
            //Angle for Clock Hands
            func angle(for value: Int, unit: Int) -> Angle {
                .degrees(Double(value)/Double(unit)*360-90)
            }

            let secondAngle = angle(for: seconds, unit: 60)
            let minuteAngle = angle(for: minutes, unit: 60)
            let hourAngle = angle(for: hours*5 + minutes/12, unit: 60)
            
            //Clock Hands
            func hand(at angle: Angle, length: CGFloat, color: Color) {
                
                var path = Path()
                path.move(to: center)
                
                let end = toPolar(center: center, angle: angle.radians, radius: length)
                
                path.addLine(to: end)
                context.stroke(path, with: .color(color), lineWidth: 2)
            }
            
            hand(at: hourAngle, length: size.width*0.25, color: .primary)
            hand(at: minuteAngle, length: size.width*0.35, color: .primary)
            hand(at: secondAngle, length: size.width*0.45, color: .red)
            
            //Draw Clock Number 1-12
            
            for hour in 1...12 {
                let angle = Angle.degrees(Double(hour)/12 * 360 - 90)
                let text = Text("\(hour)").font(.system(size: 12).bold())
                let textSize = context.resolve(text).measure(in: CGSize(width: 100, height: 100))
                let textRadius = radius * 0.8
                
                let textXY = toPolar(
                    center: center,
                    angle: angle.radians,
                    radius: textRadius,
                    translation: CGPoint(
                        x: -textSize.width/2,
                        y: -textSize.height/2
                    )
                )
                
                context.draw(
                    text,
                    at: CGPoint(
                        x: textXY.x + textSize.width/2,
                        y: textXY.y + textSize.height/2
                    )
                )
            }
            
            //Draw Tick Mark - Minutes and Hours
            for i in 0..<60 {
                let angle = Angle(degrees: Double(i)/60 * 360 - 90)
                let isHourTick = i % 5 == 0
                let tickLength: CGFloat = isHourTick ? 10 : 4
                let lineWidth: CGFloat = isHourTick ? 2 : 1
                
                let outer = toPolar(center: center, angle: angle.radians, radius: radius)
                let inner = toPolar(center: center, angle: angle.radians, radius: radius-tickLength)
                
                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)
                
                context.stroke(path, with: .color(.gray), lineWidth: lineWidth)
            }
            
            //Draw the Clock Face Circle
            let circleRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: 2*radius,
                height: 2*radius
            )
            let circlePath = Path(ellipseIn: circleRect)
            context.stroke(circlePath, with: .color(.gray), lineWidth: 4)
            
        }
    }
    
    func toPolar(center: CGPoint, angle: CGFloat, radius: CGFloat, translation: CGPoint = .zero) -> CGPoint {
        CGPoint(
            x: center.x + cos(Double(angle)) * radius + translation.x,
            y: center.y + sin(Double(angle)) * radius + translation.y
        )
    }
    
    
}

#Preview {
    VStack(spacing: 40) {
        Text("SwiftUI Canvas and TimelineView")
            .font(.title2.bold())
        
        DigitalClock()
        
        AnalogClock()
    }
}
