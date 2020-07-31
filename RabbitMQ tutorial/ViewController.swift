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
        self.newTask("Some work...")
        self.workerNamed("Larry")
        self.workerNamed("Curly")
        self.workerNamed("Moe")
        self.newTask("One dot.")
        self.newTask("No dots")
        self.newTask("Two.Dots.")
        self.newTask("Three dots...")
        self.newTask("Four.dots....")
        print("WORK COMPLETED")
    }
    
    func newTask(_ msg: String) {
        print("Attempting to connect to local RabbitMQ broker")
        let connection = RMQConnection(delegate: RMQConnectionDelegateLogger())
        connection.start()
        
        let channel = connection.createChannel()
        let q = channel.queue("task_queue", options: .durable)
        let msgData = msg.data(using: .utf8)
        let exchange = channel.fanout("logs")
        exchange.publish(msgData!, routingKey: q.name, persistent: true)
        connection.close()
    }
    
    func workerNamed(_ name: String) {
        print("Attempting to connect to local RabbitMQ broker")
        let connection = RMQConnection(delegate: RMQConnectionDelegateLogger())
        connection.start()
        let channel = connection.createChannel()
        let exchange = channel.fanout("logs")
        channel.basicQos(1, global: false)
        let q = channel.queue("", options: .exclusive)
        q.bind(exchange)
        print("Waiting for messages...")
        
        let manualAck = RMQBasicConsumeOptions()
        q.subscribe(manualAck, handler: { (_ message: RMQMessage) -> Void in
            let messageText = String(data: message.body, encoding: .utf8)
            print("[\(name)] Received message: \(String(describing: messageText))")
            let sleepTime = messageText?.components(separatedBy: ".").count ?? 0 - 1
            print("[\(name)] Sleeping for \(sleepTime) seconds")
            sleep(UInt32(sleepTime))
            channel.ack(message.deliveryTag)
        })
    }


}

