#!/bin/bash
read -p '卸载输入yes，退出输入q：' aa
if [[ $aa == 'yes' ]]
then
  rm -rf /root/.ehforwarderbot
  rm -rf /root/go-cqhttp
  rm -rf /etc/systemd/system/efb.qq.service
  rm -rf /etc/systemd/system/efb.wx.service
  rm -rf /etc/systemd/system/qsign.service
  rm -rf /etc/systemd/system/gocqhttp.service
  rm -rf /bin/qq.sh
  rm -rf /bin/wx.sh
#apt autoremove python3 libopus0 ffmpeg libmagic1 python3-pip libssl-dev
#  pip3 uninstall setuptools wheel ehforwarderbot efb-telegram-master
#  pip uninstall beautifulsoup4 pydub
  pip uninstall efb-qq-plugin-go-cqhttp
  pip3 uninstall efb-qq-slave
  pip uninstall efb-wechat-slave-itchat-uos
fi
exit 0
