//
//  ChatUI.swift
//  ios14-demo
//
//  Created by Prafulla Singh on 23/7/20.
//
import SwiftUI
import PhotosUI
struct MessageData: Identifiable {
    enum DataType {
        case image(imageIndex: Int)
        case text(message: String)
    }
    let isMine: Bool
    let dataType: DataType
    let id = UUID()
}

struct ChatUI : View {
    static var pickerResult: [UIImage] = []
    @State private var fullText: String = ""
    @State private var messageData: [MessageData] = []
    @StateObject private var keyboard = KeyboardResponder()
    var scrollToid = 99
    @State private var isPickerPresented: Bool = false
    var config: PHPickerConfiguration  {
       var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images //videos, livePhotos...
        config.selectionLimit = 0 //0 => any, set 1-2-3 for hard limit
        return config
    }
    func Scroll(reader :ScrollViewProxy) -> some View {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
                reader.scrollTo(scrollToid)
            }
        }
        return EmptyView()
    }
        
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { reader in
                        LazyVStack(spacing: 0.5) {
                            ForEach(messageData) {  message in
                                ChatBubble(direction: message.isMine ? .right : .left) {
                                    switch message.dataType {
                                    case .text(let userMessage):
                                        Text(userMessage)
                                            .padding(.all, 10)
                                            .foregroundColor(Color.white)
                                            .background(message.isMine ? Color.gray : Color.blue)
                                    case .image(let imageIndex):
                                        Image(uiImage: ChatUI.pickerResult[imageIndex])
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.width - 70,
                                                   height: 200).aspectRatio(contentMode: .fill)
                                    }
                                }
                            }
                            Rectangle()
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(Color.clear).id(scrollToid)//padding from bottom
                            Scroll(reader: reader)
                        }
                     }
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                isPickerPresented.toggle()
                            }) {
                                Image(systemName: "plus")
                        }.sheet(isPresented: $isPickerPresented) {
                            PhotoPicker(configuration: self.config, pickerResult: { (imageArray) in
                                var index = ChatUI.pickerResult.count
                                for image in imageArray {
                                    ChatUI.pickerResult.append(image)
                                    messageData.append(MessageData(isMine: true, dataType: .image(imageIndex: index)))
                                    index += 1
                                }
                            }, isPresented: $isPickerPresented)
                            
                            
                        }
                        TextField("Message", text: $fullText)
                                .frame(width: UIScreen.main.bounds.width - 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                                messageData.append(MessageData.init(isMine: true, dataType: .text(message: fullText)))
                                messageData.append(MessageData.init(isMine: false, dataType: .text(message: "reply to:" + fullText)))
                                fullText = ""
                        }) {
                                Image(systemName: "paperplane")
                        }.disabled(fullText.count == 0)
                    }
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 10)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                }

            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(items: {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("User Name")
                    }
                }
            })
        }
    }
}
  
struct ChatUI_Previews: PreviewProvider {
    static var previews: some View {
        ChatUI()
    }
}
