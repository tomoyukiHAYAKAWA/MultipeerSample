//
//  ViewController.swift
//  MultipeerSample
//
//  Created by Tomoyuki Hayakawa on 2017/04/07.
//  Copyright © 2017年 Tomoyuki Hayakawa. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate,
	MCSessionDelegate, UITextFieldDelegate {

	let serviceType = "LCOC-Chat"
	
	var browser : MCBrowserViewController!
	var assistant : MCAdvertiserAssistant!
	var session : MCSession!
	var peerID: MCPeerID!
	
	var p1num : Int = 0
	
	@IBOutlet weak var player1Label: UILabel!
	@IBOutlet weak var player2Label: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.peerID = MCPeerID(displayName: UIDevice.current.name)
		self.session = MCSession(peer: peerID)
		self.session.delegate = self
		
		// create the browser viewcontroller with a unique service name
		self.browser = MCBrowserViewController(serviceType:serviceType,
		                                       session:self.session)
		self.browser.delegate = self;
		self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
		                                       discoveryInfo:nil, session:self.session)
		
		// tell the assistant to start advertising our fabulous chat
		self.assistant.start()
	}
	
	
	// プラスボタン
	@IBAction func plusBtn(_ sender: Any) {
		// プラス
		p1num += 1
		// NSDataへInt型のp1numを変換
		let data = NSData(bytes: &p1num, length: MemoryLayout<NSInteger>.size)
		// 相手へ送信
		do {
			try self.session.send(data as Data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
		} catch {
			print(error)
		}
		player1Label.text = String(p1num)
	}
	
	// マイナスボタン
	@IBAction func minusBtn(_ sender: Any) {
		p1num -= 1
		let data = NSData(bytes: &p1num, length: MemoryLayout<NSInteger>.size)
		do {
			try self.session.send(data as Data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
		} catch {
			print(error)
		}
		player1Label.text = String(p1num)
	}
	
	
	// ラベルの更新
	func updateLabel(num : Int, fromPeer peerID: MCPeerID) {
		
		// peerが自分のものでない時ラベルの更新
		switch peerID {
		case self.peerID:
			break
		default:
			player2Label.text = String(num)
		}
		
	}
	
	@IBAction func showBrowser(sender: UIButton) {
		// Show the browser view controller
		self.present(self.browser, animated: true, completion: nil)
	}
	
	func browserViewControllerDidFinish(
		_ browserViewController: MCBrowserViewController)  {
		// Called when the browser view controller is dismissed (ie the Done
		// button was tapped)
		
		self.dismiss(animated: true, completion: nil)
	}
	
	func browserViewControllerWasCancelled(
		_ browserViewController: MCBrowserViewController)  {
		// Called when the browser view controller is cancelled
		
		self.dismiss(animated: true, completion: nil)
	}
	
	// 相手からNSDataが送られてきたとき
	func session(_ session: MCSession, didReceive data: Data,
	             fromPeer peerID: MCPeerID)  {
		DispatchQueue.main.async() {
			let data = NSData(data: data)
			var player2num : NSInteger = 0
			data.getBytes(&player2num, length: data.length)
			// ラベルの更新
			self.updateLabel(num: player2num, fromPeer: peerID)
		}
	}
	
	// The following methods do nothing, but the MCSessionDelegate protocol
	// requires that we implement them.
	func session(_ session: MCSession,
	             didStartReceivingResourceWithName resourceName: String,
	             fromPeer peerID: MCPeerID, with progress: Progress)  {
		
		// Called when a peer starts sending a file to us
	}
	
	func session(_ session: MCSession,
	             didFinishReceivingResourceWithName resourceName: String,
	             fromPeer peerID: MCPeerID,
	             at localURL: URL, withError error: Error?)  {
		// Called when a file has finished transferring from another peer
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream,
	             withName streamName: String, fromPeer peerID: MCPeerID)  {
		// Called when a peer establishes a stream with us
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID,
	             didChange state: MCSessionState)  {
		// Called when a connected peer changes state (for example, goes offline)
		
	}
}

