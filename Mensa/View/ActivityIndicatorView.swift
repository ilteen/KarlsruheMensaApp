//
//  ActivityIndicatorView.swift
//  Mensa
//
//  Created by Philipp on 16.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct ActivityIndicatorView: UIViewRepresentable {
    
    @Binding var shouldAnimate: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        // Create UIActivityIndicatorView
        return UIActivityIndicatorView()
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        // Start and stop UIActivityIndicatorView animation
        if self.shouldAnimate {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
    
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
