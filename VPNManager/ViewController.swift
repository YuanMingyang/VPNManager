//
//  ViewController.swift
//  VPNManager
//
//  Created by 袁明洋 on 2023/9/8.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController, VPNManagerDelegate {

    var vpnStatus:NEVPNStatus = .invalid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveVPNConfig()
    }


    @IBAction func startAction(_ sender: Any) {
        if vpnStatus == .disconnected{
            starVPN()
        }
    }
    
    @IBAction func stopAction(_ sender: Any) {
        stopVPN()
    }
    
    
    /**配置VPN**/
    func saveVPNConfig() {
        VPNManager.share.delegate = self
        let vpnModel = VPNConfig(tunnelBundleId: "\(Bundle.main.bundleIdentifier!).Tunnel",
                                 serverAddress: "1010101010",
                                 serverPort: "54345",
                                 mtu: "1400",
                                 ip: "10.8.0.2",
                                 subnet: "255.255.255.0",
                                 dns: "8.8.8.8,8.4.4.4",
                                 vpnName: "VPNManager")
        VPNManager.share.configManager(vpnModel)
    }
    
    func vpnStatusChange(status: NEVPNStatus) {
        vpnStatus = status
        switch vpnStatus {
        case .invalid:
            print("未配置")
        case .disconnected:
            print("未连接")
        case .connected:
            print("已连接")
        default:
            break
        }
    }
    
    func starVPN() {
        _ = VPNManager.share.startVPN()
        
    }

    func stopVPN() {
        _ =  VPNManager.share.stopVPN()
    }
    
}

