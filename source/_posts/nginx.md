# NGINX

> nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server.

    首先nginx是一个高性能的HTTP和反向代理服务器，这也是目前使用比较多的功能，同时nginx还可以做邮件代理服务器和通用的TCP/UDP代理服务器
## 配置文件结构
> 默认主配置文件名nginx.conf

```

main # 全局设置
events { # Nginx工作模式
    ....
}
http { # http设置
    ....
    upstream serverName { # 负载均衡服务器设置
        .....
    }
    server  { # 主机设置
        ....
        location { # URL匹配
            # 引入其他配置
            include ...
            ....
        }
    }
    server  {
        ....
        location {
            ....
        }
    }
    ....
}

stream {
    upstream backend {
        ....
    }
    server {
        ....
    }
}

```

1. main模块

main模块用来指定全局配置，对整个nginx生效

```

user nobody nobody;
worker_processes 2;
error_log /usr/local/var/log/nginx/error.log notice;
pid /usr/local/var/run/nginx/nginx.pid;

```

 *user* 用来指定Nginx Worker进程运行用户以及用户组，默认由nobody运行

 `worker_processes` 用来指定nginx要开启的`子进程`数

 `error_log` 定义全局错日志路径，以及日志级别

 `pid` 用来指定进程id的存储文件位置

2. events模块

```
events {
    use epoll;
    worker_connections  1024;
}
```

use 用来指定nginx的工作模式。nginx支持的工作模式有select、poll、kqueue、epoll、rtsig和/dev/poll。其中select和poll都是标准的工作模式，kqueue和epoll是高效的工作模式，不同的是epoll用在Linux平台上，而kqueue用在BSD系统中

worker_connections 用来定义nginx每个进程的最大连接数，默认1024.

> 进程的最大连接数受Linux系统进程的最大打开文件数限制，可以通过系统命令`ulimit -n 65535`设置Linux最大打开文件数

3. http模块

```
http {
    include mime.types;
    default_type application/octet-stream;
    access_log /usr/local/var/log/nginx/access.log;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 10;
    #gzip on;
    upstream myproject {
        .....
    }
    server {
        ....
    }
}
```

include 用来指定文件的mime类型
default_type 设置默认的文件类型，即二进制流。
access_log 访问日志
sendfile 用于开启高效文件传输模式。将tcp_nopush和tcp_nodelay设置为on用于防止网络阻塞
keepalive_timeout 设置客户端连接存活时间。客户端闲置状态，超过该时间，服务器会关闭该连接。

3.1

server模块

```
server {
    listen 8080;
    server_name 192.168.12.10 www.example.cn;
    # 全局定义，如果都是这一个目录，这样定义最简单。
    root   /Users/yangyi/www;
    index  index.php index.html index.htm;
    ....
}
```

server 标识一个虚拟机
listen 用来指定虚拟机监听的服务器端口
server_name 用来指定IP地址或者域名，多个项之间用空格分开
root 表示这个server虚拟机的根目录
index 全局定义访问的默认首页地址

3.1.1 listen

语法规则：listen address[:port] [default_server] [ssl] [http2 | spdy] [proxy_protocol]


```
listen 127.0.0.1:8000;
listen 127.0.0.1;
listen 8000;
listen *:8000;
listen localhost:8000;
```

IPv6地址
```
listen [::]:8000;
listen [::1];
```

UNIX-domain sockets
```
listen unix:/var/run/nginx.sock;
```

3.1.2 server_name  
语法格式：server_name name ...;

```
server_name  *.example.org;
server_name  mail.*;
server_name  ~^(?<user>.+)\.example\.net$;
```

3.2 location模块

location模块是nginx中使用最多的模块，例如反向代理、负载均衡、虚拟域名都在location模块配置

```
location / {
    root   /Users/yangyi/www;
    index  index.php index.html index.htm;
}
```

`location / ` 表示匹配访问根目录  
`root` 指定访问根目录时，虚拟主机的web目录。这个地址可以是相对地址（现对于nginx目录而言），也可以是绝对地址  
`index` 指定访问根目录时的默认首页

```
# assets, media
location ~* \.(?:css(\.map)?|js(\.map)?|jpe?g|png|gif|ico)$ {
	expires 7d;
	access_log off;
}
```

location还可以通过正则匹配，上面的正则匹配到web的一些静态资源，如css、js、image等资源，然后设置`expires 7d`做缓存

3.3 upstream模块

upstream模块定义一组`server`,这些server可以监听在不同的端口。这些server可以基于`TCP`或者 `UNIX-domain sockets`，两者可以混用

```
upstream backend {
    server backend1.example.com weight=5;
    server 127.0.0.1:8080 max_fails=3 fail_timeout=30s;
    server unix:/tmp/backend3;
    server backup1.example.com  backup;
}
```

语法规则`server address [parameters];`  
address 可以是ip、域名、UNIX-domain socket

parameters 额外参数配置项比较多，比较常用的如下：
  * weight=1 用来配置权重
  * max_conns=0 最大的同时活跃连接数，0表示没有限制
  * max_fails=1 fail_timeout=10s 这两个参数用来判断后端服务器的状态。在单位时间fail_timeout内，如果后端服务器发生不成功的连接数到达max_fails，服务器会被标记为一段时间不可用，这个时间也是fail_timeout所设置的时间。在等待fail_timeout时间后nginx会再次尝试和服务器建立连接
  * backup 标记为备份服务器。只有当主服务器不可用时，请求才会到备份服务器
  * down 标记为永久不可用服务器
  * slow_start=0 缓慢启动，0表示不可用。表示服务器从不健康状态恢复后，服务器的权重将在time时间内，从0过渡到正常设置值.

## 缓存

## https

```
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        server_name www.coolkaka.cn;
        root /home/vsftp/ftp/myblog/public/public;

        # SSL
        ssl_certificate /etc/letsencrypt/live/coolkaka.cn/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/coolkaka.cn/privkey.pem;
    }
```

`listen 443 ssl http2` 监听443端口，连接工作在SSL模式，允许http2连接  
`server_name www.coolkaka.cn` 设置虚拟主机的名字

## HTTP服务器

动静分离是让动态网站里的动态网页根据一定规则把不变的资源和经常变的资源区分开来，动静资源做好了拆分以后，我们就可以根据静态资源的特点将其做缓存操作，这就是网站静态化处理的核心思路

```
upstream test{  
       server localhost:8080;  
       server localhost:8081;  
    }   

    server {  
        listen       80;  
        server_name  localhost;  

        location / {  
            root   e:\wwwroot;  
            index  index.html;  
        }  

        # 所有静态请求都由nginx处理，存放目录为html  
        location ~ \.(gif|jpg|jpeg|png|bmp|swf|css|js)$ {  
            root    e:\wwwroot;  
        }  

        # 所有动态请求都转发给tomcat处理  
        location ~ \.(jsp|do)$ {  
            proxy_pass  http://test;  
        }  

        error_page   500 502 503 504  /50x.html;  
        location = /50x.html {  
            root   e:\wwwroot;  
        }  
    }  
```

## 负载均衡

```

# RR（默认）按时间顺序逐一分配到不同的后端服务器
   upstream test {
        server localhost:8080;
        server localhost:8081;
    }
# weight（权重）指定轮询几率，weight和访问比率成正比
    upstream test1 {
        server localhost:8080 weight=9;
        server localhost:8081 weight=1;
    }
# ip_hash 按照ip的hash结果分配访问服务器，可以实现相同ip访问固定服务器
    upstream test2 {
        ip_hash;
        server localhost:8080;
        server localhost:8081;
    }
# fair（第三方）按后端服务器的响应时间来分配请求，响应时间短的优先分配
    upstream backend3 {
        fair;
        server localhost:8080;
        server localhost:8081;
    }
# url_hash（第三方）按访问url结果来分配请求，使每个url定向到同一个后端服务器，后端服务器为缓存时比较有效
    upstream backend4 {
        hash $request_uri;
        hash_method crc32;
        server localhost:8080;
        server localhost:8081;
    }  
    server {
        listen       81;
        server_name  localhost;
        client_max_body_size 1024M;

        location / {
            proxy_pass http://test;
            proxy_set_header Host $host:$server_port;
        }
    }
```

## 反向代理

   > 反向代理（Reverse Proxy）方式是指以代理服务器来接受internet上的连接请求，然后将请求转发给内部网络上的服务器，并将从服务器上得到的结果返回给internet上请求连接的客户端，此时代理服务器对外就表现为一个反向代理服务器。简单来说就是真实的服务器不能直接被外部网络访问，所以需要一台代理服务器，而代理服务器能被外部网络访问的同时又跟真实服务器在同一个网络环境，当然也可能是同一台服务器，端口不同而已。 下面贴上一段简单的实现反向代理的代码
   
```
server {  
        listen       80;
        server_name  localhost;
        client_max_body_size 1024M;

        location / {
            proxy_pass http://localhost:8080;
            proxy_set_header Host $host:$server_port;
        }
    }
```

## 正向代理

> 正向代理，意思是一个位于客户端和原始服务器(origin server)之间的服务器，为了从原始服务器取得内容，客户端向代理发送一个请求并指定目标(原始服务器)，然后代理向原始服务器转交请求并将获得的内容返回给客户端。

```
resolver 114.114.114.114 8.8.8.8;
    server {
        resolver_timeout 5s;

        listen 81;

        access_log  e:\wwwroot\proxy.access.log;
        error_log   e:\wwwroot\proxy.error.log;

        location / {
            proxy_pass http://$host$request_uri;
        }
    }
```

## 基于域名的虚拟机

一个server需要匹配哪些`Host`，可以通过server_name来设置。下面是一个简单的例子。

```
server {
    server_name example.com www.example.com;
}
```
上面的例子还可以简写为下面的样子

```
server {
    server_name .example.com;
}
```
配置的语法规则是`server_name name ...` server_name后面可以配置多个域名，第一个会被设置为主域名。同时name支持使用通配符 `*` 以及正则表达式。


下面是一个通配符配置的例子
```
server {
    server_name example.com *.example.com www.example.*;
}
```

如果nginx在搜索server_name时，匹配到多个（通配符匹配或者正则表达式匹配）。nginx将采用以下规则来处理。

1.准确匹配。哪个匹配结果更准确使用之。

2.匹配以`*`开头的最长通配符名称。e.g. `*.example.com`

3.匹配以`*`结尾的最长通配符名称。e.g. `mail.*`

4.按照配置文件出现的顺序进行正则匹配。
