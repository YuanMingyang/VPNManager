//
//  VPNManager.swift
//  VPNManager
//
//  Created by 袁明洋 on 2023/9/8.
//

import UIKit
import NetworkExtension
class VPNConfig:NSObject{
    var tunnelBundleId:String?
    var serverAddress:String?
    var serverPort:String?
    var mtu:String?
    var ip:String?
    var subnet:String?
    var dns:String?
    var vpnName:String?
    
    init(tunnelBundleId: String? = nil, serverAddress: String? = nil, serverPort: String? = nil, mtu: String? = nil, ip: String? = nil, subnet: String? = nil, dns: String? = nil, vpnName: String? = nil) {
        self.tunnelBundleId = tunnelBundleId
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.mtu = mtu
        self.ip = ip
        self.subnet = subnet
        self.dns = dns
        self.vpnName = vpnName
    }
}


protocol VPNManagerDelegate :NSObjectProtocol{
    func vpnStatusChange(status:NEVPNStatus)
}
class VPNManager: NSObject {

    var vpnManager:NETunnelProviderManager?
    weak var delegate:VPNManagerDelegate?
    var vpnConfigModel:VPNConfig?
    
    public static let share = VPNManager()
    
    override init() {
        super.init()
        vpnManager = NETunnelProviderManager()
        NotificationCenter.default.addObserver(self, selector: #selector(VPNStatusChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    @objc func VPNStatusChange(_ notification:NSNotification){
        let status = vpnManager?.connection.status
        delegate?.vpnStatusChange(status: status!)
    }
    /**配置VPN**/
    func configManager(_ model:VPNConfig){
        vpnConfigModel = model
        applyVpnConfiguration()
    }
    
    func applyVpnConfiguration() {
        NETunnelProviderManager.loadAllFromPreferences { [self] managers, error in
            //已配置VPN
            if managers!.count>0{
                vpnManager = managers?.first
                if delegate != nil{
                    let status = vpnManager?.connection.status
                    delegate?.vpnStatusChange(status: status!)
                }
                return
            }
            //未配置VPN，去配置
            vpnManager!.loadFromPreferences { [self] error in
                if error != nil{
                    print("VPN配置出错\(error!.localizedDescription)")
                    return
                }
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.providerBundleIdentifier = vpnConfigModel!.tunnelBundleId
                tunnelProtocol.providerConfiguration = [
                    "port":vpnConfigModel?.serverPort as Any,
                    "server":vpnConfigModel?.serverAddress as Any,
                    "ip":vpnConfigModel?.ip as Any,
                    "subnet":vpnConfigModel?.subnet as Any,
                    "mtu":vpnConfigModel?.mtu as Any,
                    "dns":vpnConfigModel?.dns as Any
                ]
                tunnelProtocol.serverAddress = vpnConfigModel?.serverAddress
                vpnManager?.protocolConfiguration = tunnelProtocol
                vpnManager?.localizedDescription = vpnConfigModel?.vpnName
                vpnManager?.isEnabled = true
                vpnManager?.saveToPreferences(completionHandler: { [self] error in
                    if error != nil{
                        print("VPN配置存储失败\(error!.localizedDescription)")
                    }else{
                        print("VPN配置存储成功")
                        applyVpnConfiguration()
                    }
                })
            }
        }
    }
    
    /**开启VPN**/
    func startVPN() -> Bool {
        vpnManager?.isEnabled = true
        vpnManager?.saveToPreferences(completionHandler: { [self] err in
            if vpnManager?.connection.status == .disconnected{
                do{
                    try vpnManager?.connection.startVPNTunnel()
                    print("VPN开启成功")
                    //return true
                } catch {
                    print("VPN开启失败:\(error.localizedDescription)")
                    //return false
                }
            }else{
                print("当前连接状态不是disconnected !")
            }
        })
        
        return true
    }
    
    /**停止VPN**/
    func stopVPN() -> Bool {
        switch vpnManager?.connection.status{
        case .connected:
            vpnManager?.connection.stopVPNTunnel()
            return true
        case .connecting:
            vpnManager?.connection.stopVPNTunnel()
            return true
        default:
            print("VPN断开失败，当前连接状态不是已连接或正在连接!")
            break
        }
        return false
    }
}
