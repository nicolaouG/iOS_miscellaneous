//
//  URLImage.swift
//  TestWidgetExtension
//
//  Created by george on 07/10/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import SwiftUI

@available(iOS 14.0.0, *)
/**
 Provide a placeholder view and load image asynchronously
 
 # Sample code
 ```
 URLImage(url: item.image) {
     Image("placeholder-image")
         .resizable()
         .aspectRatio(contentMode: .fit)
         .frame(width: 60, height: 60, alignment: .center)
 }
 .aspectRatio(contentMode: .fit)
 .frame(width: 60, height: 60, alignment: .center)
 ```
 */
public struct URLImage<Placeholder: View>: View {
    private let placeholder: Placeholder
    private let url: URL?

    init(url: String, @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        self.url = URL(string: url)
    }

    public var body: some View {
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
            }
            else {
                placeholder
            }
        }
    }
}
