#cloud-config
runcmd:
    - curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    - chmod +x openvpn-install.sh
    - echo -e "1\nkayde\n" | AUTO_INSTALL=y ./openvpn-install.sh
    - curl -X PUT -T /root/kayde.ovpn "${ovpn_upload_url}"