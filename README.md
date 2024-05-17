## Домашнее задание VPN

### Описание домашнего задания
```
1. Настроить VPN между двумя VMs в tun/tap режимах,
   замерить скорость в туннелях, сделать вывод об отличающихся показателях
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, 
   подключиться с VM и с PC
3. VMs разворачивается в среде VMware vSphere 7 из шаблона Ubuntu Server 22.04
  
Файлы:

- newvms.yml:               ansible playbook развертывания VMs
- vars.yml:                 переменные для создания и наcтройки VMs
- host:                     inventory

Задание 1:

- vpn.yml:                  ansible playbook настройки VPN
- openvpn@.service:         /etc/systemd/system/openvpn@.service файл-юнит service OpenVPN
- vpnserver\server.conf:    /etc/openvpn/server.conf конфигурационный файл OpenVPN 
- vpnclient\server.conf:    /etc/openvpn/server.conf конфигурационный файл OpenVPN

в скриншотах:

- screens\vpn-client.jpg:   root@vpn-client# ifconfig
                            root@vpn-client# iperf3 -c 10.10.10.1 -t 40 -i 5
                            root@vpn-client# sed -i 's/tap/tun' /etc/openvpn/server.conf
                            root@vpn-client# systemctl restart openvpn@server
                            root@vpn-client# iperf3 -c 10.10.10.1 -t 40 -i 5
							
- screens\vpn-server-tap.jpg:    
                            root@vpn-server# iperf3 -s
- screens\vpn-server-tun.jpg: 							
                            root@vpn-server# sed -i 's/tap/tun' /etc/openvpn/server.conf
                            root@vpn-server# systemctl restart openvpn@server
                            root@vpn-server# iperf3 -s							

TAP эмулирует Ethernet-устройство и работает на канальном уровне модели OSI,
оперируя кадрами Ethernet.
TUN (сетевой туннель) работает на сетевом уровне модели OSI, оперируя IP-пакетами.
TAP используется для создания сетевого моста, тогда как TUN — для маршрутизации.
TAP скорость выше

Задание 2:

- ras.yml:                  ansible playbook настройки RAS
- net_ras.pdf:              схема сети
- client.conf:              /etc/openvpn/client.conf конфигурационный файл OpenVPN клиента
- ras\server.conf:          /etc/openvpn/client.conf конфигурационный файл OpenVPN сервера
- ras\nat:                  /etc/openvpn/nat настройка iptables сервера
- ras\client.sh:            /etc/openvpn/client.sh скрипт создания сертификатов для клиента

После выполнения ansible playbook ras.yml --tags ras
на VM ras продолжаем настраивать easy-rsa:

#/etc/easy-rsa/easyrsa build-ca
#/etc/easy-rsa/easyrsa gen-req ras nopass
#echo 'yes' | /etc/easy-rsa/easyrsa sign-req server ras
#/etc/easy-rsa/easyrsa gen-dh
#openvpn --genkey secret /etc/easy-rsa/pki/ta.key
#cp /etc/easy-rsa/pki/ca.crt /etc/easy-rsa/pki/dh.pem /etc/easy-rsa/pki/ta.key /etc/openvpn/keys
#cp /etc/easy-rsa/pki/private/ras.key /etc/easy-rsa/pki/issued/ras.crt /etc/openvpn/keys
#systemctl restart openvpn@server

Сертификаты для клиента создаём скриптом:
/etc/openvpn/client.sh
и записываем их в католог openvpn клиента
Для windows у конфигурационного файла клиента OpenVPN расширение .ovpn

в скриншотах:
на сервере
- screens\ras.jpg:          cat /var/log/openvpn-status.log показывает подключение 2-х клиентов
                            ifconfig
                            netstat -rn
на клиенте ubuntu							
- screens\ras-client1-linux.jpg:
                            openvpn --config /etc/openvpn/client.conf подключение к серверу
  2-й терминал
- screens\ras-client2-linux.jpg:
                            ping 10.10.10.1
                            ping 8.8.8.8
                            netstat -rn
                            ifconfig
на клиенте Windows 10
- screens\ras-client-windows.jpg:
                             скриншот OpenVPN Connect и каталога профиля подключения
- screens\ras-client-windows-route.jpg:
                             ping 10.10.10.1
                             ping 8.8.8.8
                             route print
                            

