//
//  ViewController.swift
//  RabbitMQ tutorial
//
//  Created by Andrew Bolt on 30/07/2020.
//  Copyright © 2020 Andrew Bolt. All rights reserved.
//

import UIKit
import RMQClient

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBAction func pressButton(_ sender: Any) {
        
        if textField.text != nil {
            
            let payload: String = textField?.text ?? ""
            
            //RabbitMQ configuration
            let connection: RMQConnection = RMQConnection(delegate: RMQConnectionDelegateLogger())
            connection.start()
            
            let channel = connection.createChannel()
            let queue = channel.queue("ios-app")
            channel.defaultExchange().publish(payload.data(using: .utf8)!, routingKey: queue.name)
            connection.close()
            
            textField.text = nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func send() {
        print("Attempting to connect to local RabbitMQ broker")
        let connection = RMQConnection(delegate: RMQConnectionDelegateLogger())
        connection.start()
        
        let channel = connection.createChannel()
        let q = channel.queue("hello")
        channel.defaultExchange().publish("Hello World!".data(using: .utf8)!, routingKey: q.name)
        connection.close()
    }
    
    func receive() {
        print("Attempting to connect to local RabbitMQ broker")
        let connection = RMQConnection(delegate: RMQConnectionDelegateLogger())
        connection.start()
        let channel = connection.createChannel()
        let q = channel.queue("hello")
        print("Waiting for messages...")
        q.subscribe({ (_ message: RMQMessage) -> Void in
            print("Received \(String(describing: String(data: message.body, encoding: .utf8)))")
        })
    }


}

