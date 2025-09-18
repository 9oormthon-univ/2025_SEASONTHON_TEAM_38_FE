//
//  SimHaeWidgetBundle.swift
//  SimHaeWidget
//
//  Created by 홍준범 on 9/18/25.
//

import WidgetKit
import SwiftUI

@main
struct SimHaeWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimHaeWidget()
        SmallSimHaeWidget() 
        SimHaeWidgetControl()
        SimHaeWidgetLiveActivity()
    }
}
