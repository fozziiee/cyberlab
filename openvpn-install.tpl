#cloud-config
runcmd:
    - curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    - chmod +x openvpn-install.sh
    - echo -e "1\nkayde\n" | AUTO_INSTALL=y ./openvpn-install.sh
    - mv /root/client.ovpn /home/${admin_user}/kayde.ovpn
    - chown ${admin_user}:${admin_user} /home/${admin_user}/kayde.ovpn
    - curl -X PUT -T /home/${admin_user}/kayde.ovpn -H "x-ms-blob-type: Block-Blob" "${ovpn_upload_url}"
    - mv /etc/openvpn/ca.* /etc/openvpn/server/
    - mv /etc/openvpn/server_* /etc/openvpn/server/
    - mv /etc/openvpn/server.conf /etc/openvpn/server/
    - mv /etc/openvpn/tls-crypt.key /etc/openvpn/server/
    - systemctl restart openvpn-server@server