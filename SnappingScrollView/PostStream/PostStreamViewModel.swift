//
//  PostStreamViewModel.swift
//  SnappingScrollView
//
//  Created by Sajjad Sarkoobi on 8.12.2022.
//

import Foundation

class PostStreamViewModel: ObservableObject {
    enum ScrollDirection {
        case up
        case down
        case none
    }
    
    var lastScrolledPostId: Int = 0
    var positons: [Int: CGFloat] = [:]
    var heights: [Int: CGFloat] = [:]
    var postsStaticLinks: [String: Bool] = [:]
    var nextVisiblePostFrame: CGRect = .zero
    
    @Published var postDataSource: [Int] = Array(0...50)
}


//MARK: Handle Post movements logics
extension PostStreamViewModel {
    
    func getNexPostIndex(currentIndex: Int, direction: ScrollDirection) -> Int {
        
        switch direction {
        case .down:
            if currentIndex >= postDataSource.count {
                return currentIndex
            } else {
               return currentIndex + 1
            }

        case .up:
            if currentIndex == 0 {
                return currentIndex
            } else {
               return currentIndex - 1
            }
            
        default:
            return currentIndex
        }
    }
    
    func setHeight(currentIndex: Int, height: CGFloat) {
        heights[currentIndex] = height
        setPosition(postIndex: currentIndex)
    }
    
    func setPosition(postIndex: Int) {
        if postIndex == 0 {
            positons[0] = 0.0
        } else {
            positons[postIndex] = (positons[postIndex - 1] ?? 0) + (heights[postIndex - 1] ?? 0)
        }
    }
    
    func getPosition(for postId: Int) -> CGFloat {
        positons[postId] ?? 0.0
    }
}
