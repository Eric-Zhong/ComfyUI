python main.py

echo Config network proxy on windows
echo --------------------------------------------------
echo netsh interface show interface
echo netsh interface ipv4 set interface "Wi-Fi" forwarding=enable
echo netsh interface portproxy add v4tov4 listenport=8188 listenaddress=0.0.0.0 connectport=8188 connectaddress=172.31.21.142
echo --------------------------------------------------
