#cloud-config
runcmd:
    - curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    - chmod +x openvpn-install.sh
    - echo -e "1\nkayde\n" | AUTO_INSTALL=y ./openvpn-install.sh
    - mv /root/client.ovpn /home/${admin_user}/kayde.ovpn
    - chown ${admin_user}:${admin_user} /home/${admin_user}/kayde
    - curl -X PUT -T /home/${admin_user}/kayde.ovpn "${ovpn_upload_url}"    