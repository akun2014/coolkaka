---
title: 网络协议-ICMP协议
tags: protocol
categories: 计算机网络
abbrlink: 3d56ba79
date: 2019-08-25 18:16:09
---

# ICMP协议

互联网控制消息协议（Internet Control Message Protocol，缩写：ICMP）是互联网协议族的核心协议之一。
它用于网际协议(IP)中发送控制消息，提供可能发生在通讯环境中的各种问题反馈。通过这些信息，使发送端对发发生的问题作出诊断，然后才去适当的措施解决。

ICMP依靠IP来完成它的任务，它是IP的主要部分。他与传输协议（如TCP和UDP）显著不同：它一般不用于在亮点之间传输数据。它通常不由网络程序直接使用，除了ping和traceroute这两个特别的例子。IPv4中的ICMP被称作ICMPv4，IPv6中的ICMP则被称作ICMPv6。

## 技术细节

ICMP通常用于返回错误信息或者分析路由。ICMP错误消息总是包括了源数据并返回给发送者。ICMP错误消息的例子之一是TTL值过期。每个路由器在转发数据报的时候会把IP包头中的TTL值减1.如果TTL值为0，“TTL在传输中过期”的消息将会回报给源地址。每个ICMP消息都是封装在一个IP数据包中，因此，和UDP一样，ICMP是不可靠的。

虽然ICMP是包含在IP数据包中的，但是对ICMP消息通常会特殊处理，会和一般数据包的数据不同，而不是作为IP的一个子协议来处理。在很多时候，需要去查看ICMP消息的内容，然后发送适当的错误消息到那个原来产生IP数据包的程序，即那个导致ICMP消息被发送的IP数据包。

常用的traceroute和ping就是基于ICMP。traceroute是通过发送包含特殊TTL的包，然后接收ICMP超时消息和目标不可达消息来实现的。ping则是用ICMMP的“Echo”和“Echo Reply”消息来实现的。

## ICMP报文结构

{% img https://myblog-coolkaka.oss-cn-shanghai.aliyuncs.com/network/network-icmp.png vi-vim-cheat-sheet %}

Type - ICMP的类型，标识生成的错误报文
Code - 进一步划分ICMP的类型，该字段用来查找产生的错误的原因；例如，Type为3标识目的不可达，Code为3标识目标不可达的具体原因为：端口不可达
Checksum - 校验码部分，用于校验报文的正确性

