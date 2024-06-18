//
//  Zen Sounds
//
//  Created by Arunya Goojar on 10/05/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var data = ReadDataJSON()
    @State public var isAudioPlaying = false
    @State private var player: AVPlayer?
    
    @State private var lastPlaybackPosition: CMTime?
    @State private var lastAudioURL: URL?
    
    @State private var isButtonPressed = false
    @State private var currentSound: Sound = {
        if let historyData = UserDefaults.standard.data(forKey: "playHistory"),
           let playHistory = try? JSONDecoder().decode([Sound].self, from: historyData),
           let lastPlayedSound = playHistory.first {
            return lastPlayedSound
        } else {
            // If no history exists, use the default sound
            return Sound(title: "Written On The Sky", location: "stratosphere", imageName: "sky-space", audioURL: "https://zensounds.blob.core.windows.net/zen/Written On The Sky.mp3")
        }
    }()
    
    @State private var imageOpacity = 1.0
    @State private var playHistory: [Sound] = []
    
    @State private var showVolumeHUD = false
    @State private var volumeLevel: Float = 0.8
    @State private var isSliderHovered = false
    
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center){
                    }.frame(height: (NSScreen.main?.visibleFrame.size.height ?? 0) / 1.5)
                    
                    VStack(spacing: 0){
                        //opening Stack
                        ZStack{
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(height: 740)
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
                                    HStack{
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
                                            Image(systemName: isAudioPlaying ? "stop.circle" : "play.circle")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .opacity(0.65)
                                            
                                        }.keyboardShortcut(.space, modifiers: [])
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.horizontal, 8.0)
                                            .padding(.vertical, 8.0)
                                            .background(.thickMaterial)
                                            .clipShape(Capsule())
                                            .scaleEffect(isButtonPressed ? 1.075 : 1)
                                            .opacity(isButtonPressed ? 0.9 : 1)
                                        
                                        Spacer().frame(width: 12, height: 5)
                                                    
                                        Slider(value: Binding(
                                            get: {
                                                self.volumeLevel
                                            },
                                            set: { newValue in
                                                self.volumeLevel = newValue
                                                self.adjustVolume(level: newValue)
                                            }
                                        ), in: 0...1)
                                            .frame(width: 130)
                                            .padding(.horizontal, 16.0)
                                            .padding(.vertical, 10.0)
                                            .background(.thickMaterial)
                                            .clipShape(Capsule())
                                    }
                                }.offset(y:-30)
                                
                                
                                Button(action: {
                                    adjustVolume(increment: true)
                                }) {
                                    EmptyView()
                                }.frame(width: 0,height: 0)
                                .keyboardShortcut("=", modifiers: .command)
                                .opacity(0) // Make the button invisible
                                
                                Button(action: {
                                    adjustVolume(increment: false)
                                }) {
                                    EmptyView()
                                }.frame(width: 0,height: 0)
                                .keyboardShortcut("-", modifiers: .command)
                                .opacity(0) // Make the button invisible
                                
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
                                                            .blur(radius: 4,opaque: true)
                                                            .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        Rectangle()
                                                            .fill(Color.black.opacity(0.3))
                                                            .ignoresSafeArea()
                                                            .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                            .scaledToFill()
                                                        VStack {
                                                            Text(sound.title)
                                                                .font(.custom("Times New Roman", size: 42))
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
                                            let endIndex = startIndex + 10
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.4))
                                                        .ignoresSafeArea()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 42))
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
                                            let endIndex = startIndex + 7
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.4))
                                                        .ignoresSafeArea()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 42))
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
                                .frame(height: 785)
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
                                            let startIndex = 17
                                            let endIndex = startIndex + 1
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: geometry.size.width , height: 350)
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.4))
                                                        .ignoresSafeArea()
                                                        .frame(width: geometry.size.width , height: 350)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 42))
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
                                                }.frame(width: geometry.size.width, height: 350).compositingGroup()
                                                    .cornerRadius(16).onTapGesture {
                                                        currentSound = sound
                                                        isAudioPlaying = true
                                                        playSound()
                                                    }
                                            }
                                        }.scrollTargetLayout()
                                    }.cornerRadius(16)
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity)
                                    ScrollView(.horizontal,showsIndicators: false) {
                                        HStack(alignment: .center, spacing: 20) {
                                            // Define the start and end indices
                                            let startIndex = 18
                                            let endIndex = startIndex + 7
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.4))
                                                        .ignoresSafeArea()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 42))
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
                                        .scrollTargetBehavior(.viewAligned).frame(maxWidth: .infinity).padding(.top,20)
                                    
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
                                            let endIndex = startIndex + 7
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.4))
                                                        .ignoresSafeArea()
                                                        .frame(width: min(max(geometry.size.width * 0.295, 496), 500), height: 270)
                                                        .frame(maxWidth: 500)
                                                        .scaledToFill()
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 42))
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
                                            let startIndex = 32
                                            let endIndex = startIndex + 5
                                            
                                            // Ensure the indices are within bounds of the array
                                            let validEndIndex = min(endIndex, data.sounds.count)
                                            let validStartIndex = min(startIndex, data.sounds.count)
                                            
                                            ForEach(data.sounds[validStartIndex..<validEndIndex]) { sound in
                                                ZStack {
                                                    Image(sound.imageName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .blur(radius: 4,opaque: true)
                                                        .frame(width: geometry.size.width, height: 350)
                                                    Rectangle()
                                                        .fill(Color.black.opacity(0.4))
                                                        .ignoresSafeArea()
                                                        .frame(width: geometry.size.width, height: 350)
                                                        .scaledToFill()
                                                    
                                                    VStack {
                                                        Text(sound.title)
                                                            .font(.custom("Times New Roman", size: 42))
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
                ZStack { // Volume HUD ZStack
                    if showVolumeHUD {
                        VStack {
                            Spacer().frame(height: 80)
                            HStack(alignment: .center) {
                                Text("Volume: \(Int(round(volumeLevel * 100)))%") // Show volume %
                                    .font(.custom("", size: 20))
                                    .opacity(0.95)
                                    .padding(.top, 3)
                            }
                            .keyboardShortcut(.space, modifiers: [])
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20.0)
                            .padding(.vertical, 10.0)
                            .background(.thickMaterial)
                            .cornerRadius(16)
                            
                            Spacer()
                        }
                    }
                }.animation(.easeInOut(duration: 0.7), value: showVolumeHUD)
                .frame(width: geometry.size.width, height: geometry.size.height)
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
        }.edgesIgnoringSafeArea(.all).frame(minWidth: 1120, minHeight: 750).frame(maxWidth: .infinity, maxHeight: .infinity)
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

    // Audio control
    func playSound() {
        stopSound()
        
        guard let url = URL(string: currentSound.audioURL) else {
            print("Invalid URL")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        
        if lastAudioURL == url, let lastPosition = lastPlaybackPosition {
            player.seek(to: lastPosition)
        }
        
        player.play()
        
        // Retain the player in a property to keep it alive
        self.player = player
        self.lastAudioURL = url
        
        // Update play history
        updateHistory(with: currentSound)
    }

    func stopSound() {
        if let player = player {
            lastPlaybackPosition = player.currentTime()
        }
        player?.pause()
        player = nil
    }
    
    func adjustVolume(level: Float) {
            guard let player = player else { return }
            
            player.volume = level
            volumeLevel = player.volume // Update volumeLevel state
            showVolumeHUD = true // Show the HUD
            
            // Hide the HUD after a delay (adjust as needed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showVolumeHUD = false
                }
            }
        }
    
    func adjustVolume(increment: Bool) {
            guard let player = player else { return }

            if increment {
                player.volume = min(player.volume + 0.1, 1.0)
            } else {
                player.volume = max(player.volume - 0.1, 0.0)
            }

            volumeLevel = player.volume // Update volumeLevel state
            showVolumeHUD = true // Show the HUD
            
            // Hide the HUD after a delay (adjust as needed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showVolumeHUD = false
                }
            }
        }
}//view

