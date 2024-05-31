//
//  ContentView.swift
//  Zen Sounds
//
//  Created by Arunya Goojar on 10/05/24.
//

import SwiftUI
import AVKit

extension Bundle {
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
}

struct ContentView: View {
    @StateObject var data = ReadDataJSON()
    @State private var isAudioPlaying = false
    @State private var player: AVPlayer?
    @State private var isButtonPressed = false
    @State private var currentSound: Sound = Sound(title: "Written On The Sky", location: "stratosphere", imageName: "sky-space", audioURL: "https://zensounds.blob.core.windows.net/zendata/Written On The Sky.mp3")
    
    @State private var imageOpacity = 1.0
    @State private var playHistory: [Sound] = []

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(currentSound.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: currentSound.imageName)
                
                ScrollView() {
                    VStack(alignment: .center){
                    }.frame(height: (NSScreen.main?.visibleFrame.size.height ?? 0) / 1.5)
                    
                    VStack(spacing: 0){
                        //opening Stack
                        ZStack{
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(height: 720)
                                .mask {
                                    VStack(spacing: 0) {
                                        LinearGradient(colors: [Color.black.opacity(0),  // sin(x * pi / 2)
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.924),
                                                                Color.black],
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                        .frame(height: 180)
                                        Rectangle()
                                    }
                                }
                            VStack(){
                                VStack(alignment: .center) {
                                    Text(currentSound.title)
                                        .font(.custom("Times New Roman", size: 80))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .opacity(0.75)
                                        .frame(maxWidth: 950)
                                    
                                    Text(currentSound.location)
                                        .font(.custom("", size: 16))
                                        .fontWeight(.thin)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .opacity(0.65)
                                        .textCase(.uppercase)
                                        .kerning(12.0)
                                    
                                    Spacer().frame(height: 70)
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            isButtonPressed = true
                                        }
                                        
                                        isAudioPlaying.toggle()
                                        if isAudioPlaying {
                                            playSound()
                                        } else {
                                            stopSound()
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                isButtonPressed = false
                                            }
                                        }
                                    })
                                    {
                                        HStack(alignment: .center) {
                                            Image(systemName: isAudioPlaying ? "stop.circle" : "play.circle")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .opacity(0.65)
                                            Spacer().frame(width: 12, height: 5)
                                            Text(isAudioPlaying ? "Stop Surrounding" : "Set Surrounding")
                                                .font(.custom("", size: 20))
                                                .opacity(0.95)
                                                .padding(.top, 3)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal, 15.0)
                                    .padding(.vertical, 10.0)
                                    .background(.thickMaterial)
                                    .clipShape(Capsule())
                                    .scaleEffect(isButtonPressed ? 1.025 : 1)
                                    .opacity(isButtonPressed ? 0.9 : 1)
                                }.offset(y:-30)
                                Spacer().frame(height: 140)
                                // Play History ScrollView
                                VStack(alignment: .leading){
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            if playHistory.isEmpty {
                                                Text("No play history available")
                                                    .font(.custom("", size: 18))
                                                    .foregroundColor(.white)
                                                    .opacity(0.5)
                                                    .frame(width: (NSScreen.main?.visibleFrame.size.width))
                                                    .frame(maxHeight: 220)
                                                    .offset(x:-50)
                                                    .transition(.opacity)
                                                    .animation(.easeInOut(duration: 0.5), value: playHistory.isEmpty)
                                            } else {
                                                ForEach(playHistory) { sound in
                                                    ZStack {
                                                        Image(sound.imageName)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        Rectangle()
                                                            .fill(.ultraThickMaterial)
                                                            .opacity(0.6)
                                                            .ignoresSafeArea()
                                                            .blur(radius: 8,opaque: true)
                                                            .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                            .scaledToFill()
                                                        VStack {
                                                            Text(sound.title)
                                                                .font(.custom("Times New Roman", size: 36))
                                                                .fontWeight(.regular)
                                                                .foregroundColor(.white)
                                                                .multilineTextAlignment(.center)
                                                                .padding(.top,5)
                                                                .padding(.bottom,1)
                                                                .opacity(0.8)
                                                                .frame(maxWidth: 380)
                                                            
                                                            Text(sound.location)
                                                                .font(.custom("", size: 14))
                                                                .fontWeight(.ultraLight)
                                                                .foregroundColor(.white)
                                                                .padding(.top,5)
                                                                .padding(.horizontal)
                                                                .opacity(0.65)
                                                                .textCase(.uppercase)
                                                                .kerning(6.0)
                                                        }
                                                    }.frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270).compositingGroup()
                                                        .cornerRadius(16).onTapGesture {
                                                            currentSound = sound
                                                            isAudioPlaying = true
                                                            playSound()
                                                        }
                                                }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                }.frame(maxWidth: geometry.size.width).padding(.horizontal,50)
                            }//vstack
                        }
                        //Nature Sounds
                        ZStack{
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .blur(radius: 20, opaque: true)
                                .ignoresSafeArea()
                                .frame(height: 400)
                                .scaledToFill()
                            
                            VStack(){
                                //Catogories
                                VStack(alignment: .leading){
                                    Text("Nature’s Symphony").fontWeight(.semibold).font(.system(size: 20))
                                        .padding(.bottom,15)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .opacity(0.75)
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            // Define the start and end indices
                                            let startIndex = 0
                                            let endIndex = startIndex + 9
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(.ultraThickMaterial)
                                                        .opacity(0.6)
                                                        .ignoresSafeArea()
                                                        .blur(radius: 8,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 36))
                                                            .fontWeight(.regular)
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.top,5)
                                                            .padding(.bottom,1)
                                                            .opacity(0.8)
                                                            .frame(maxWidth: 380)
                                                        
                                                        Text(sound.location)
                                                            .font(.custom("", size: 14))
                                                            .fontWeight(.ultraLight)
                                                            .foregroundColor(.white)
                                                            .padding(.top,5)
                                                            .padding(.horizontal)
                                                            .opacity(0.65)
                                                            .textCase(.uppercase)
                                                            .kerning(6.0)
                                                    }
                                                }.frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270).frame(maxWidth: 500).compositingGroup()
                                                    .cornerRadius(16).onTapGesture {
                                                        currentSound = sound
                                                        isAudioPlaying = true
                                                        playSound()
                                                    }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                }.frame(maxWidth: geometry.size.width).padding(.top,20)
                                    .padding(.horizontal,50)
                            }//vstack
                        }
                        //Ambient Sounds
                        ZStack{
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .blur(radius: 20, opaque: true)
                                .ignoresSafeArea()
                                .frame(height: 400)
                                .scaledToFill()
                            
                            VStack(){
                                //Catogories
                                VStack(alignment: .leading){
                                    Text("Serene Spaces").fontWeight(.semibold).font(.system(size: 20))
                                        .padding(.bottom,15)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .opacity(0.75)
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            // Define the start and end indices
                                            let startIndex = 10
                                            let endIndex = startIndex + 4
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(.ultraThickMaterial)
                                                        .opacity(0.6)
                                                        .ignoresSafeArea()
                                                        .blur(radius: 8,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 36))
                                                            .fontWeight(.regular)
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.top,5)
                                                            .padding(.bottom,1)
                                                            .opacity(0.8)
                                                            .frame(maxWidth: 380)
                                                        
                                                        Text(sound.location)
                                                            .font(.custom("", size: 14))
                                                            .fontWeight(.ultraLight)
                                                            .foregroundColor(.white)
                                                            .padding(.top,5)
                                                            .padding(.horizontal)
                                                            .opacity(0.65)
                                                            .textCase(.uppercase)
                                                            .kerning(6.0)
                                                    }
                                                }.frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270).frame(maxWidth: 500).compositingGroup()
                                                    .cornerRadius(16).onTapGesture {
                                                        currentSound = sound
                                                        isAudioPlaying = true
                                                        playSound()
                                                    }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                }.frame(maxWidth: geometry.size.width).padding(.top,20)
                                    .padding(.horizontal,50)
                            }//vstack
                        }
                        //Movie Sounds
                        ZStack{
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .blur(radius: 20, opaque: true)
                                .ignoresSafeArea()
                                .frame(height: 400)
                                .scaledToFill()
                            
                            VStack(){
                                //Catogories
                                VStack(alignment: .leading){
                                    Text("Cinematic Echoes").fontWeight(.semibold).font(.system(size: 20))
                                        .padding(.bottom,15)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .opacity(0.75)
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            // Define the start and end indices
                                            let startIndex = 14
                                            let endIndex = startIndex + 8
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(.ultraThickMaterial)
                                                        .opacity(0.6)
                                                        .ignoresSafeArea()
                                                        .blur(radius: 8,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 36))
                                                            .fontWeight(.regular)
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.top,5)
                                                            .padding(.bottom,1)
                                                            .opacity(0.8)
                                                            .frame(maxWidth: 380)
                                                        
                                                        Text(sound.location)
                                                            .font(.custom("", size: 14))
                                                            .fontWeight(.ultraLight)
                                                            .foregroundColor(.white)
                                                            .padding(.top,5)
                                                            .padding(.horizontal)
                                                            .opacity(0.65)
                                                            .textCase(.uppercase)
                                                            .kerning(6.0)
                                                    }
                                                }.frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270).frame(maxWidth: 500).compositingGroup()
                                                    .cornerRadius(16).onTapGesture {
                                                        currentSound = sound
                                                        isAudioPlaying = true
                                                        playSound()
                                                    }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                }.frame(maxWidth: geometry.size.width).padding(.top,20)
                                    .padding(.horizontal,50)
                            }//vstack
                        }
                        //Game Sounds
                        ZStack{
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .blur(radius: 20, opaque: true)
                                .ignoresSafeArea()
                                .frame(height: 800)
                                .scaledToFill()
                            
                            VStack(){
                                //Catogories
                                VStack(alignment: .leading){
                                    Text("Gamer’s Haven").fontWeight(.semibold).font(.system(size: 20))
                                        .padding(.bottom,15)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .opacity(0.75)
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            // Define the start and end indices
                                            let startIndex = 25
                                            let endIndex = startIndex + 3
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(.ultraThickMaterial)
                                                        .opacity(0.6)
                                                        .ignoresSafeArea()
                                                        .blur(radius: 8,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 36))
                                                            .fontWeight(.regular)
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.top,5)
                                                            .padding(.bottom,1)
                                                            .opacity(0.8)
                                                            .frame(maxWidth: 380)
                                                        
                                                        Text(sound.location)
                                                            .font(.custom("", size: 14))
                                                            .fontWeight(.ultraLight)
                                                            .foregroundColor(.white)
                                                            .padding(.top,5)
                                                            .padding(.horizontal)
                                                            .opacity(0.65)
                                                            .textCase(.uppercase)
                                                            .kerning(6.0)
                                                    }
                                                }.frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270).frame(maxWidth: 500).compositingGroup()
                                                    .cornerRadius(16).onTapGesture {
                                                        currentSound = sound
                                                        isAudioPlaying = true
                                                        playSound()
                                                    }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                }.frame(maxWidth: geometry.size.width).padding(.top,20)
                                    .padding(.horizontal,50)
                                
                                VStack(alignment: .leading){
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            // Define the start and end indices
                                            let startIndex = 22
                                            let endIndex = startIndex + 3
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: geometry.size.width, height: 350)
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 36))
                                                            .fontWeight(.regular)
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.top,5)
                                                            .padding(.bottom,1)
                                                            .opacity(0.8)
                                                            .frame(maxWidth: geometry.size.width)
                                                        
                                                        Text(sound.location)
                                                            .font(.custom("", size: 14))
                                                            .fontWeight(.ultraLight)
                                                            .foregroundColor(.white)
                                                            .padding(.top,5)
                                                            .opacity(0.65)
                                                            .textCase(.uppercase)
                                                            .kerning(6.0)
                                                    }.frame(maxWidth: .infinity, alignment: .center)
                                                }.frame(width: geometry.size.width - 153, height: 350).compositingGroup()
                                                    .cornerRadius(16).onTapGesture {
                                                            currentSound = sound
                                                            isAudioPlaying = true
                                                            playSound()
                                                    }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                }.frame(maxWidth: geometry.size.width).padding(.top,20)
                                    .padding(.horizontal,50)
                            }//vstack
                        }
                    }
                }.frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                //scroll
            }//zstack
            .onAppear {
                        // Retrieve play history from UserDefaults
                        if let data = UserDefaults.standard.data(forKey: "playHistory") {
                            let decoder = JSONDecoder()
                            if let decoded = try? decoder.decode([Sound].self, from: data) {
                                self.playHistory = decoded
                            }
                        }
                    }
            .onDisappear(perform: stopSound)// Ensure sound stops when view disappears
            .frame(width: geometry.size.width, height: geometry.size.height)
            .edgesIgnoringSafeArea(.all)
        }.edgesIgnoringSafeArea(.all).frame(minWidth: 1120, minHeight: 750)
    }

    //Audio control
    func playSound() {
            guard let url = URL(string: currentSound.audioURL) else {
                print("Invalid URL")
                return
            }
            let playerItem = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: playerItem)
            player.play()
            
            // Retain the player in a property to keep it alive
            self.player = player
            
            // Update play history
            updateHistory(with: currentSound)
        }
    
    func updateHistory(with sound: Sound) {
            // Remove the sound if it already exists
            if let index = playHistory.firstIndex(where: { $0.audioURL == sound.audioURL }) {
                playHistory.remove(at: index)
            }
            
            // Append the sound to the beginning of the history
            playHistory.insert(sound, at: 0)
            
            // Trim the history to the last 10 sounds
            if playHistory.count > 10 {
                playHistory.removeLast()
            }
            
            // Save the updated history to UserDefaults
            savePlayHistory()
        }

        func loadPlayHistory() {
            if let data = UserDefaults.standard.data(forKey: "playHistory") {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode([Sound].self, from: data) {
                    self.playHistory = decoded
                }
            }
        }

        func savePlayHistory() {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(playHistory) {
                UserDefaults.standard.set(encoded, forKey: "playHistory")
            }
        }

        func stopSound() {
                player?.pause()
                player = nil
        }
}//view

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

