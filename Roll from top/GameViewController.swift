//
//  GameViewController.swift
//  Roll from top
//
//  Created by Sanjith Kanagavel on 16/06/16.
//  Copyright (c) 2016 Sanjith Kanagavel. All rights reserved.
//

import SpriteKit
import GameKit
import GoogleMobileAds

class GameViewController: UIViewController, GKGameCenterControllerDelegate,GADInterstitialDelegate {
    
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    var gamesPlayed = 0;
    var interstitial = GADInterstitial()
    var adshowed = Bool()
    
    override func viewDidLoad() {
        adshowed = true;
        super.viewDidLoad()
        self.authenticateLocalPlayer()
        print(self.view.frame.size.width)
        print(self.view.frame.size.height)
        let scene =  GameStartingEndScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        scene.viewController = self
        skView.presentScene(scene)
        
        /*
        let scene = GameScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.showsPhysics = false
        scene.scaleMode = .AspectFill
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        skView.presentScene(scene)*/
    }
    
    func gamePlayed() {
        
        if(!adshowed)
        {
            if (self.interstitial.isReady)
            {
                self.interstitial.present(fromRootViewController: self)
                adshowed = true
            }
            else{
                adshowed = false
            }
            return;
        }
        
        gamesPlayed += 1;
        if( gamesPlayed % 2 == 0 )
        {
            self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-5722562744549789/2259742550")
            self.interstitial.load(GADRequest());
        }
        else if( gamesPlayed % 3 == 0 )
        {
            if (self.interstitial.isReady)
            {
                self.interstitial.present(fromRootViewController: self)
                adshowed = true
            }else{
                adshowed = false;
            }
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer: String?, error: Error?) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                        print("123")
                        print(self.gcDefaultLeaderBoard)
                        let defaults = UserDefaults.standard
                        if let highscore = defaults.string(forKey: "highscore")
                        {
                            self.submitScore(Int(highscore)!)
                        }
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error)
            }
            
        }
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore(_ score:Int) {
        let leaderboardID = "leaderboard_braingame4"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(score)
        GKScore.report([sScore], withCompletionHandler: { (error: Error?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Score submitted")
                
            }
        })
    }
    
    func showLeaderboard(){
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "leaderboard_braingame4"
        self.present(gcVC, animated: true, completion: nil)
    }
    
    func socialShare(_ sharingText: String?, sharingImage: UIImage?, sharingURL: URL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text as AnyObject)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        //activityViewController.excludedActivityTypes = [UIActivityTypeCopyToPasteboard,UIActivityTypeAirDrop,UIActivityTypeAddToReadingList,UIActivityTypeAssignToContact,UIActivityTypePostToTencentWeibo,UIActivityTypePostToVimeo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToWeibo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func rateApp()
    {
        //UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id1125722878")!)
    }
    
}
