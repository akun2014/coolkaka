---
title: akun
date: 2019-08-12 17:13:12
tags:
---
# 开发效率提升&最佳实践

## 开发工具篇

## Shell

推荐使用[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) 再配合一些插件极大提升效率

推荐插件

- 命令自动提升插件 [zsh-autosuggestion](https://www.jianshu.com/p/b4dec723c52f)
- 语法高亮 [zsh-syntax-highlighting](https://blog.csdn.net/caiqiiqi/article/details/52139288)
- [其他](https://juejin.im/entry/5ae00e54f265da0b8635ea5c)
## Git

团队开发推荐使用 [git-flow](https://www.git-tower.com/learn/git/ebook/cn/command-line/advanced-topics/git-flow) ,可以有效减少代码冲突，以及便于代码分支的有效管理。如果安装了上面推荐的oh-my-zsh,还可以安装[插件](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/git-flow)来简化命令

## Maven

使用阿里云提供的[中央仓库](https://www.jianshu.com/p/4d5bb95b56c5)，提升下载速度

## Homebrew

mac用户下命令行包管理神器。安装 MySQL Redis Tomcat等开发组件极其方便。
安装方式见[官网](https://brew.sh/)

## Intellij平台

-  EasyCode

在项目初期，表设计完成后需要根据表来写对应的Restful接口，service接口，CRUD接口等。有没有可以工具帮我完成初始代码的生成，那EasyCode可以帮助你。

## API管理
- postman 管理个人的一些测试接口

- [swagger-bootstrap-ui](https://github.com/xiaoymin/Swagger-Bootstrap-UI/blob/master/README_zh.md) 

如果别人要对接你开发的接口，你又不想写文档，那这个绝对可以帮你省很多时间。如果你的项目恰巧还是springboot开发的，那可以搭配 [spring-boot-starter-swagger](https://github.com/SpringForAll/spring-boot-starter-swagger)会更香