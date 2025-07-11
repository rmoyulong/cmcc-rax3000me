### 首先感谢两位大佬 [Daniel-Hwang](https://github.com/Daniel-Hwang/) 和 [QiYueYiya](https://github.com/QiYueYiya/) ，本篇教程根据他们的教程修改

---

原链接：

https://github.com/QiYueYiya/OpenWrt-Actions/tree/main/RAX3000Me
https://github.com/Daniel-Hwang/RAX3000Me

## 准备工作

[下载](https://github.com/Zhengyscla/iwrt_rax3000me/releases/download/rax3000me/rax3000me_immortwrt.zip)刷机文件 `rax3000me_immortwrt.zip` 并解压。

## 开始操作

**1. 打开Telnet**

> 你需要准备Linux环境，Ubuntu也好，Arch也行，WSL也方便，或者使用安卓手机Termux也可以，安装好 `openssl` 工具，termux需要安装 `openssl-tool`

查看路由器底下的SN码，并记下来。或者登录路由器 `192.168.10.1` 使用默认账户登录，复制SN码

**2. 使用Linux终端计算生成密码**

下载开启Telnet配置文件 `RAX3000M_XR30_cfg-telnet-20240117.conf`，已放在压缩包里

或：

```bash
wget https://github.com/Zhengyscla/iwrt_rax3000me/releases/download/rax3000me/RAX3000M_XR30_cfg-telnet-20240117.conf
```

> 你可能发现文件名似乎是给RAX3000M使用的而不是RAX3000Me。要注意RAX3000Me的固件是和RAX3000M是一样的

计算生成密码

```bash
mypassword=$(openssl passwd -1 -salt aV6dW8bD "$SN")
mypassword=$(eval "echo $mypassword")
echo $mypassword
```

> **注意了，尽管 `echo $mypassword` 只是输出已经生成的密码，但这是成败的关键！一般情况下，它会输出明文密码。但某些特殊SN码和我一样输出了空密码，此时不能使用生成的空密码来加密文件了**

![作者的空密码输出，运气“大大的好”](https://blog.clazys.qzz.io/img/rax30_1.png)

如果你的密码输出正常，则加密配置文件

```bash
openssl aes-256-cbc -pbkdf2 -k "$mypassword" -in RAX3000M_XR30_cfg-telnet-20240117.conf -out cfg_import_config_file_new.conf
```

上传配置至路由器，使用默认密码登录即可，路由器会自动重启

![上传配置文件界面在这里，正常会出现一段横向进度条，顶部为空密码上传后失败提示](https://blog.clazys.qzz.io/img/rax30_2.png)

**空密码执行这个指令进行加密，~~律师函风险 :) .~~**

```bash
openssl aes-256-cbc -pbkdf2 -k '#RaX30O0M@!$' -in RAX3000M_XR30_cfg-telnet-20240117.conf -out cfg_import_config_file_new.conf
```

**3. 刷写固件**

路由器重启后，使用Telnet工具连接路由器

```bash
telnet 192.168.10.1  #根据自身网络情况而定
```

- <details>
    <summary>不会开Windows的Telnet？</summary>
    
    ---

    1. **开始菜单** --> **搜索 `启用或关闭Windows功能`.** --> **勾选 `Telnet Client` 或 `Telnet 客户端` .** --> 确定无需重启

    2. 打开**新的**终端即可使用


下载preloader和Uboot到路由器/tmp目录下，采用来自 QiYueYiya 的文件

```bash
wget -P /tmp https://github.com/QiYueYiya/OpenWrt-Actions/releases/download/RAX3000Me_Files/mt7981-cmcc_rax3000me-nand-ddr3-preloader.bin
```
```bash
wget -P /tmp https://github.com/QiYueYiya/OpenWrt-Actions/releases/download/RAX3000Me_Files/mt7981-cmcc_rax3000me-nand-ddr3-fip-fit.bin
```

> **无USB版本的要把 `ddr3` 换成 `ddr4` .**

- <details>
    <summary>失败了吗？</summary>

    使用 `Windows 8兼容模式` 打开压缩包内的 `HTTP File Server` ~~，不知道为什么，反正挺玄学的~~

    保证路由器和电脑在同一网段，链接路由器的wifi或网线连接

    把 `mt7981-cmcc_rax3000me-nand-ddr3-fip-fit.bin` 和 `mt7981-cmcc_rax3000me-nand-ddr3-preloader.bin` 直接拖入软件窗口即可

    执行指令，把 `your_ip` 换成你的内网ip

    ```bash
    wget -P /tmp http://your_ip/mt7981-cmcc_rax3000me-nand-ddr3-fip-fit.bin
    wget -P /tmp http://your_ip/mt7981-cmcc_rax3000me-nand-ddr3-preloader.bin
    ```

烧写Uboot固件

```bash
mtd write /tmp/mt7981-cmcc_rax3000me-nand-ddr3-preloader.bin BL2
# 可以再次输入验证刷入情况，但实际上我这无USB版本的失败了，但仍然成功刷机，所以。。。。看情况吧
mtd write /tmp/mt7981-cmcc_rax3000me-nand-ddr3-fip-fit.bin FIP # 必须刷
reboot # 重启查看奇迹
```

重启后输入 `192.168.1.1` 进入Uboot，指示灯可能不亮。如果没有进入，用取卡针顶住RESET 5秒多，变绿灯了用网线连接路由器和计算机

进入Uboot后选择选择压缩包内的 `RAX3000Me-initramfs-recovery.itb` 文件刷写等待重启

路由器重启完毕，电脑获取IP后，浏览器输入192.168.1.1即可进入immortwrt。

但是还没有结束，你会发现提示这是临时界面

**4. 完整刷入immortwrt**

在系统-->备份与升级-->刷写固件里刷写 [RAX3000Me-yyMMdd-squashfs-sysupgrade.itb (点此下载，实时更新)](https://github.com/QiYueYiya/OpenWrt-Actions/releases/tag/RAX3000Me) 固件

更新后，路由器的后台地址变为192.168.5.1

欣赏成果

![Immortwrt RAX3000Me](https://blog.clazys.qzz.io/img/rax3_3.png)
