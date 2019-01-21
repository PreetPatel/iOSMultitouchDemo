//
//  ViewController.swift
//  PlayingCard
//
//  Created by Preet Patel on 12/17/18.
//  Copyright © 2018 Preet Patel. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var collisionBehaviour: UICollisionBehavior = {
        let behaviour = UICollisionBehavior()
        behaviour.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(behaviour)
        return behaviour
    }()
    
    lazy var itemBehaviour: UIDynamicItemBehavior = {
        let behaviour = UIDynamicItemBehavior()
        behaviour.allowsRotation = false
        behaviour.elasticity = 1.0
        behaviour.resistance = 0 
        animator.addBehavior(behaviour)
        return behaviour
    }()
    
    //    @IBOutlet weak var playingCardView: PlayingCardView! {
    //        didSet {
    //            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
    //            swipe.direction = [.left, .right]
    //            playingCardView.addGestureRecognizer(swipe)
    //
    //            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlineGestureRecognisedBy:)))
    //            playingCardView.addGestureRecognizer(pinch)
    //        }
    //    }
    //
    //    @IBAction func flipTheCard(_ sender: UITapGestureRecognizer) {
    //        switch sender.state {
    //        case .ended:
    //            playingCardView.isFaceUp = !playingCardView.isFaceUp
    //        default: break;
    //        }
    //    }
    //
    //
    //    @objc func nextCard() {
    //        if let card = deck.draw() {
    //            playingCardView.rank = card.rank.order
    //            playingCardView.suit = card.suit.rawValue
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count+1)/2) {
            let card = deck.draw()!
            cards += [card,card]
        }
        
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            
            // Add tap gesture recogniser
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipcard(_:))))
            
            //Add collison behaviour
            collisionBehaviour.addItem(cardView)
            itemBehaviour.addItem(cardView)
            
            let push = UIPushBehavior(items: [cardView], mode: .instantaneous)
            push.angle = (2*CGFloat.pi).arc4random
            push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
            
            push.action = { [unowned push] in
                push.dynamicAnimator?.removeBehavior(push)
            }
            
             animator.addBehavior(push)
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden}
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }

    @objc func flipcard(_ recogniser: UITapGestureRecognizer) {
        
        switch recogniser.state {
        case .ended:
            // .view in recogniser is a var that references to the view that was tapped on
            if let chosenCardView = recogniser.view as? PlayingCardView {
                
                // Does the flip transition
                UIView.transition(with: chosenCardView,
                                  duration: 0.4 ,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                                  completion: {
                                    finished in
                                    
                                    if self.faceUpCardViewsMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6,
                                                                                       delay: 0,
                                                                                       options: [],
                                                                                       animations: {
                                                                                        self.faceUpCardViews.forEach{
                                                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                                                        }
                                        },
                                                                                       completion: {
                                                                                        position in
                                                                                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75,
                                                                                                                                       delay: 0,
                                                                                                                                       options: [],
                                                                                                                                       animations: {
                                                                                                                                        self.faceUpCardViews.forEach{
                                                                                                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                                                                                                            $0.alpha = 0
                                                                                                                                        }
                                                                                        },
                                                                                                                                       completion: {
                                                                                                                                        position in
                                                                                                                                        self.faceUpCardViews.forEach{
                                                                                                                                            $0.isHidden = true
                                                                                                                                            $0.alpha = 1
                                                                                                                                            $0.transform = .identity
                                                                                                                                        }
                                                                                        })
                                        })
                                    }
                                        
                                    else if self.faceUpCardViews.count == 2 {
                                        self.faceUpCardViews.forEach { cardView in
                                            UIView.transition(with: cardView,
                                                              duration: 0.4 ,
                                                              options: [.transitionFlipFromLeft],
                                                              animations: {
                                                                cardView.isFaceUp = false
                                            },
                                                              completion: {
                                                                finished in
                                            }
                                            )
                                        }
                                    }
                }
                )
            }
        default:
            break
        }
    }
    
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
