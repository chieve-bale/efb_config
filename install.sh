#!/bin/bash
#确定安装内容
read -p '你想安装什么？安装qq输入qq，安装微信输入wx，两个都要输入b,退出输入q：' type
#定义安装函数
#安装依赖库
libInstall(){
    apt-get update
    apt-get upgrade
    apt-get install tree python python3 python3-dev gcc build-essential libffi-dev libopus0 ffmpeg libmagic1 python3-pip git nano libssl-dev git vim unzip -y
    pip3 install setuptools wheel ehforwarderbot efb-telegram-master
    pip install beautifulsoup4 pydub
    CURRENT_DIR=$(cd $(dirname $0); pwd)
}
#qq安装函数
qqInstall(){
    pip install git+https://github.com/XYenon/efb-qq-plugin-go-cqhttp
    pip3 install efb-qq-slave
    mkdir -p /root/.ehforwarderbot/profiles/qq
    cp -a $CURRENT_DIR/qq/* /root/.ehforwarderbot/profiles/qq/
    sed -i "s/qqt/$qqt/g" /root/.ehforwarderbot/profiles/qq/blueset.telegram/config.yaml
    sed -i "s/amins/$amins/g" /root/.ehforwarderbot/profiles/qq/blueset.telegram/config.yaml
    cp -a $CURRENT_DIR/go-cqhttp /root/
    chmod +777 /root/go-cqhttp/go-cqhttp
    sed -i "s/qqacc/$qqacc/g" /root/go-cqhttp/config.yml
    sed -i "s/passwd/$qqpasswd/g" /root/go-cqhttp/config.yml
    chmod +777 $CURRENT_DIR/qq.sh
    cp -a $CURRENT_DIR/qq.sh /bin/
    #安装qq签名服务
    apt install openjdk-19-jdk
    wget -P $CURRENT_DIR https://github.com/fuqiuluo/unidbg-fetch-qsign/releases/download/1.1.0/unidbg-fetch-qsign-1.1.3.zip
    unzip $CURRENT_DIR/unidbg-fetch-qsign-1.1.3.zip
    cp -a $CURRENT_DIR/unidbg-fetch-qsign-1.1.3 /root/
    ###########修改签名端口########
}
#微信安装函数
wxInstall(){
    mkdir -p /root/.ehforwarderbot/profiles/wechat
    cp -a $CURRENT_DIR/wechat/* /root/.ehforwarderbot/profiles/wechat/
    sed -i "s/amins/$amins/g" /root/.ehforwarderbot/profiles/qq/blueset.telegram/config.yaml
    sed -i "s/wxt/$wxt/g" /root/.ehforwarderbot/profiles/wechat/blueset.telegram/config.yaml
    chmod +777 $CURRENT_DIR/wx.sh
    cp -a $CURRENT_DIR/wx.sh /bin/
    #安装微信uos从端
    pip install efb-wechat-slave-itchat-uos
}
#守护程序配置
reloadService(){
    #安装守护程序配置文件
    mv -f /root/efb_config/*.service /etc/systemd/system/
    #重新加载进程守护
    systemctl daemon-reload
    #进程守护 开机自启efb
    systemctl enable efb.qq.service
    systemctl enable efb.wx.service
    systemctl enable gocqhttp.service
    systemctl enable qsign.service
    #进程守护 启动efb
#    systemctl start efb.qq.service
#    systemctl start efb.wx.service
#    systemctl start gocqhttp.service
#    systemctl start qsign.service
}
#获取token、admins
if [[ $type == 'q' ]]
then
    exit
    elif [[ $type == 'qq' ]]
    then
        read -p '输入telegram的账号的ID：' amins
        read -p '输入qq绑定的bot的token：' qqt
        read -p '输入qq号' qqacc
        read -p '输入qq密码' qqpasswd
        libInstall
        qqInstall
        reloadService
    elif [[ $type == 'wx' ]]
    then
        read -p '输入telegram的账号的ID：' amins
        read -p '输入微信绑定的bot的token：' wxt
        libInstall
        wxInstall
        reloadService
    elif [[ $type == 'b' ]]
    then
        read -p '输入telegram的账号的ID：' amins
        read -p '输入qq绑定的bot的token：' qqt
        read -p '输入微信绑定的bot的token：' wxt
        read -p '输入qq号：' qqacc
        read -p '输入qq密码：' qqpasswd
        libInstall
        qqInstall
        wxInstall
        reloadService
fi

echo '下面四行是有些用的模块，如果需要可以自行安装配置
#检查微信连接是否正常
pip3 install efb-online-middleware
echo '- online.OnlineMiddleware' >> /root/.ehforwarderbot/profiles/wechat/config.yaml
cp -a $CURRENT_DIR/middle/online.OnlineMiddleware /root/.ehforwarderbot/profiles/wechat/
#搜索相关
pip install peewee PyYaml python-dateutil
pip install efb-search_msg-middleware
echo '- catbaron.search_msg' >> /root/.ehforwarderbot/profiles/qq/config.yaml
cp -a $CURRENT_DIR/middle/catbaron.search_msg /root/.ehforwarderbot/profiles/qq/
echo '- catbaron.search_msg' >> /root/.ehforwarderbot/profiles/wechat/config.yaml
cp -a $CURRENT_DIR/middle/catbaron.search_msg /root/.ehforwarderbot/profiles/wechat/
#链接预览
pip install beautifulsoup4
pip install efb-link-preview-middleware
echo '- catbaron.link_preview' >> /root/.ehforwarderbot/profiles/qq/config.yaml
cp -a $CURRENT_DIR/middle/catbaron.link_preview /root/.ehforwarderbot/profiles/qq/
echo '- catbaron.link_preview' >> /root/.ehforwarderbot/profiles/wechat/config.yaml
cp -a $CURRENT_DIR/middle/catbaron.link_preview /root/.ehforwarderbot/profiles/wechat/
#语音转文字
pip install pydub
pip install efb-voice_recog-middleware
echo '- catbaron.voice_recog' >> /root/.ehforwarderbot/profiles/qq/config.yaml
cp -a $CURRENT_DIR/middle/catbaron.search_msg /root/.ehforwarderbot/profiles/qq/
echo '- catbaron.voice_recog' >> /root/.ehforwarderbot/profiles/wechat/config.yaml
cp -a $CURRENT_DIR/middle/catbaron.search_msg /root/.ehforwarderbot/profiles/wechat/
#- online.OnlineMiddleware
#- catbaron.search_msg
#- catbaron.voice_recog
#- catbaron.link_preview
'

#删除安装文件
cp $CURRENT_DIR/efb_uninstall.sh /root/
rm -rf $CURRENT_DIR

systemctl start qsign.service
sleep 20s
systemctl start gocqhttp.service
sleep 20s
pid=$(ps -ef | grep go-cqhttp | grep -v 'grep' | awk '{print $2}')
kill $pid

echo "安装完成，前往https://github.com/chieve-bale/efb_config查看具体使用方法。
如有需要，请修改要登录的设备类型（0为默认（ipad），1为Android Phone，2为Android Watch，3为MacOS，4为企点，5为iPad，6为androidPad）
具体请修改/root/device.json中的'protocol:0'"
exit 0
