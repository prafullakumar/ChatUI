//
//  photoPickerDemo.swift
//  ios14-demo
//
//  Created by Prafulla Singh on 12/7/20.
//

import SwiftUI
import PhotosUI

struct PhotoPickerDemo: View {
    @State private var isPresented: Bool = false
    @State var pickerResult: [UIImage] = []
    var config: PHPickerConfiguration  {
       var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images //videos, livePhotos...
        config.selectionLimit = 0 //0 => any, set 1-2-3 for har limit
        return config
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Button("Present Picker") {
                    isPresented.toggle()
                }.sheet(isPresented: $isPresented) {
                    PhotoPicker.init(configuration: self.config, pickerResult: { pickerResult in
                        self.pickerResult = pickerResult
                    }, isPresented: $isPresented)
                }
                ForEach(pickerResult, id: \.self) { image in
                    Image.init(uiImage: image)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: 250, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    var pickerResult: ([UIImage])->()
    @Binding var isPresented: Bool
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var imageArray: [UIImage] = []
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self)  {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { (newImage, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            imageArray.append(newImage as! UIImage)
                        }
                    }
                } else {
                    print("Loaded Assest is not a Image")
                }
            }
            self.parent.pickerResult(imageArray)
            // dissmiss the picker
            parent.isPresented = false
        }
    }
}

struct photoPickerDemo_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerDemo()
    }
}
