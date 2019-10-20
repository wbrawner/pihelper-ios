//
//  ActivityIndicatorView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    var isAnimating: Binding<Bool>
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating.wrappedValue ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
    init(_ isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style = .medium) {
        self.isAnimating = isAnimating
        self.style = style
    }
}


struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView(.constant(true))
    }
}
