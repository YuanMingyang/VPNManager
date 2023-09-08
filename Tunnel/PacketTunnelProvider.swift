//
//  PacketTunnelProvider.swift
//  Tunnel
//
//  Created by 袁明洋 on 2023/9/8.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    let groupUserDefaul = UserDefaults(suiteName: "group.com.booster.changhui")
    var connection: NWTCPConnection? = nil
    var pendingStartCompletion: ((NSError?) -> Void)?
    let net_metu:NSNumber = 1400
    let net_remoteAddress = "192.168.3.14"
    let net_subnetMasks = "255.255.255.255"
    let net_dns = "223.5.5.5"
    let local_address = "127.0.0.1"
    let net_tunnel_ipAddress = "10.10.10.10"

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: net_remoteAddress)
        tunnelNetworkSettings.mtu = net_metu
        tunnelNetworkSettings.ipv4Settings = NEIPv4Settings(addresses: [net_tunnel_ipAddress], subnetMasks: [net_subnetMasks])
        tunnelNetworkSettings.ipv4Settings!.includedRoutes = [NEIPv4Route.default()]
        
        let nedn = NEDNSSettings(servers: [net_dns])
        nedn.matchDomains = [""]
        tunnelNetworkSettings.dnsSettings = nedn
        setTunnelNetworkSettings(tunnelNetworkSettings) { [self] error in
            if error==nil {
                completionHandler(nil)
                readPakcets()
            }else{
                completionHandler(error)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        connection?.cancel()
        completionHandler()
    }
    
    
    func readPakcets() {
        packetFlow.readPackets { [self] packets, protocols in
            for packet in packets{
                //这里是拦截到的网络数据，根据业务需求进行处理
                
                //处理好的数据可以调用下边的方法重新写入手机
                //packetFlow.writePackets([packet!], withProtocols: [NSNumber(value: AF_INET)])
            }
            readPakcets()
        }
    }
    
}
