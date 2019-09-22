---
title: 网络协议-TLS协议
tags:
  - protocol
  - https
categories: 计算机网络
abbrlink: 90fccd13
date: 2019-08-21 18:16:09
---
# DH 握手协商过程

* 双方通过TCP三次握手建立连接

* 浏览器发送 “Client hello”消息
  
    告诉服务器，我支持的协议版本，加密套件、随机数c等信息

* 服务器发送 “Server Hello”消息
  
    服务器收到响应，选择双方都支持的协议，套件，向客户端发送Server Hello。同时服务器也将自己的证书、随机数s发送到客户端(Certificate)

* 服务器用发送 “Server Key Exchange”消息
  
  因为选用了DH算法，所以服务器还需要发给算法必须的参数Server Params，为了防止别人冒充，服务器用自己的私钥签名认证发送

* 服务器发送 “Server Hello Done”消息
  
  表明服务器打招呼结束。此时浏览器和服务器共享了Client Random、Server Random、Server Params

* 浏览器发送 “Client Key Exchange”消息
  
   浏览器根据密码套件的要求，也生成Client Params，并发送给服务器

* 生成预主密钥(PreMaster Secret)
  
  此时浏览器和服务器共享了Client Params、Server Params，Client Random、Server Random

  浏览器和服务器都可以通过DH算法以及Client Params、Server Params计算得到预主密钥(PreMaster Secret)

* 生成主密钥(Master Secret)
  
  有了上面的预主密钥(PreMaster Secret)，浏览器和服务器双方都拥有了生成主密钥的3要素Client Random、Server Random、PreMaster Secret
  然后通过下面的计算公式得到主密钥

  ```txt
  master_secret = PRF(pre_master_secret,"master secret",ClientHello.random+ServerHello.random)
  ```

* 客户端发送 Change Cipher Spec 消息
  
  表明后续通讯切换到加密模式

* 客户端发送 Finished 消息
  
  把之前所有的数据做个摘要、然后用主密钥加密一下发送服务器，让服务器做个验证。
  
* 服务器发送 Change Cipher Spec 消息
  
  表明后续通讯切换到加密模式

* 服务器发送 Finished 消息
  
  把之前所有的数据做个摘要、然后用主密钥加密一下发送浏览器，让浏览器做个验证。
