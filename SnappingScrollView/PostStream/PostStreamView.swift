//
//  PostStreamView.swift
//  SnappingScrollView
//
//  Created by Sajjad Sarkoobi on 8.12.2022.
//

import SwiftUI

struct PostStreamView: View {
    
    @StateObject var viewModel: PostStreamViewModel = PostStreamViewModel()
    @State var isAnimating: Bool = false
    @State private var scrollDirection: PostStreamViewModel.ScrollDirection = .none
    @State var lastOffset: CGFloat = .zero
    @State var offset: CGFloat = .zero
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                VStack {
                    nativeScrollview(geo: geo)
                }
            }
        }
    }
}

struct PostStreamView_Previews: PreviewProvider {
    static var previews: some View {
        //PostStreamView()
        ContentView()
    }
}


extension PostStreamView {
    func nativeScrollview(geo: GeometryProxy) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.postDataSource, id:\.self) { postIndex in
                    postView(index: postIndex)
                        .padding(.bottom, 12)
                        .background(
                            GeometryReader { reader -> Color in
                                let frame = reader.frame(in: .global)
                                ///Setting heights of each posts
                                viewModel.setHeight(currentIndex: postIndex, height: frame.height)
                                
                                ///Getting the frame of next post
                                if postIndex == viewModel.getNexPostIndex(currentIndex: viewModel.lastScrolledPostId, direction: scrollDirection) {
                                    viewModel.nextVisiblePostFrame = frame
                                }
                                return .clear
                            }
                        )
                }
            }
        }
        .content.offset(y: offset)
        .coordinateSpace(name: "scroll")
        .simultaneousGesture(
            ///Disabling scroll view and using drag gesture to move the scroll
            ///In this way we are having full controll of scroll view
            DragGesture(minimumDistance: 0.0, coordinateSpace: .named("scroll"))
                .onChanged({ dragValue in
                    let isScrollDown = 0 > dragValue.translation.height
                    self.scrollDirection = isScrollDown ? .down : .up
                    
                    let translation = dragValue.translation.height
                    offset = lastOffset + translation
                    
                })
                .onEnded { value in
                    
                    ///Setting last offset
                    lastOffset = offset
                    
                    ///Calculating Drag velocity
                    let velocity = CGSize(
                        width:  value.predictedEndLocation.x - value.location.x,
                        height: value.predictedEndLocation.y - value.location.y
                    )
                    
                    ///Moving to next post if velocity is bigger than height of view / 4
                    if abs(velocity.height) > geo.size.height/4 {
                        moveToNext(id: viewModel.getNexPostIndex(currentIndex: viewModel.lastScrolledPostId, direction: scrollDirection))
                    }
                    
                    ///Scroll to next post if next post appeard to view based on it's position and size
                    if scrollDirection == .down, viewModel.nextVisiblePostFrame.minY < geo.size.height - 100 {
                        moveToNext(id: viewModel.getNexPostIndex(currentIndex: viewModel.lastScrolledPostId, direction: scrollDirection))
                        
                    } else if scrollDirection == .up, (viewModel.nextVisiblePostFrame.height - abs(viewModel.nextVisiblePostFrame.minY)) > 100 {
                        moveToNext(id: viewModel.getNexPostIndex(currentIndex: viewModel.lastScrolledPostId, direction: scrollDirection))
                    }
                }
        )
    }
    
    ///Move to next post with animation
    func moveToNext(id nextPost : Int) {
        if !isAnimating {
            isAnimating = true
            withAnimation(.easeOut(duration: 0.4)) {
                offset = -viewModel.getPosition(for: nextPost)
                lastOffset = offset
            }
 
            viewModel.lastScrolledPostId = nextPost
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
                /// Load more data if needed by calculating last snapped index
                /// if it is close to end index you can load more data from viewmodel
            }
        }
    }
}

struct postView: View {
    var index: Int
    
    @State var random: Int = 0
    @State var backColor: Color = Color.random
    
    var body: some View {
        ZStack {
            backColor
            
            Text("Post index \(index)")
                .foregroundColor(.black)
                .font(.title)
                .padding()
                .background(Color.white)
                .cornerRadius(6)
        }
        .frame(height: CGFloat(250 * random))
        .onAppear {
            random = Int.random(in: 1...4)
        }
    }
}


extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
