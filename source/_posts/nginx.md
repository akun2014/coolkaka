---
title: nginx配置详解
categories: distributed-system
abbrlink: 122277c
date: 2019-09-10 00:00:00
---
# NGINX

> nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server.

    首先nginx是一个高性能的HTTP和反向代理服务器，这也是目前使用比较多的功能，同时nginx还可以做邮件代理服务器和通用的TCP/UDP代理服务器

## 配置文件结构

> 默认主配置文件名nginx.conf

```
#main nginx全局设置

events {
    use ...;
    worker_connections ...;
    ....
}
http {
    ....
    upstream serverName {
        server ....
        .....
    }
    server  {
        listen ....
        server_name ....
        ....
        location {
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

 `user` 用来指定NGINX Worker进程运行用户以及用户组，默认由nobody运行

 `worker_processes` 用来指定nginx要开启的*子进程*数

 `error_log` 定义全局错日志路径，以及日志级别

 `pid` 用来指定进程id的存储文件位置

1. events模块

```
events {
    use epoll;
    worker_connections  1024;
}
```

use 用来指定nginx的工作模式。nginx支持的工作模式有select、poll、kqueue、epoll、rtsig和/dev/poll。其中select和poll都是标准的工作模式，kqueue和epoll是高效的工作模式，不同的是epoll用在Linux平台上，而kqueue用在BSD系统中

worker_connections 用来定义nginx每个进程的最大连接数，默认1024.

> 进程的最大连接数受Linux系统进程的最大打开文件数限制，可以通过系统命令`ulimit -n 65535`设置Linux最大打开文件数

1. http模块

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
    upstream backend {
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

3.1 server模块

```
server {
    listen 8080;
    server_name backend1.coolkaka.cn www.coolkaka.cn;
    root   /var/www/blog/;
    index  index.html index.htm;
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

IPv4地址

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

如果只有`address`,`port`默认为80
3.1.2 server_name  
语法规则：server_name name ...;  

```
server_name  *.example.org;
server_name  mail.*;
server_name  ~^(?<user>.+)\.example\.net$;
```

3.2 location模块

location模块是nginx中使用最多的模块，例如反向代理、负载均衡、虚拟域名都在location模块配置

配置根访问路径，以及默认的index文件  

```
location / {
    root   /var/www/blog/;
    index  index.html index.htm;
}
```

`location /` 表示匹配访问根目录  
`root` 指定访问根目录时，虚拟主机的web目录。这个地址可以是相对地址（现对于nginx目录而言），也可以是绝对地址  
`index` 指定访问根目录时的默认首页

匹配某些静态资源，实现对静态资源的缓存

```
# assets, media
location ~* \.(?:css(\.map)?|js(\.map)?|jpe?g|png|gif|ico)$ {
    expires 7d;
    access_log off;
}
```

location还可以通过正则匹配，上面的正则匹配到web的一些静态资源，如css、js、image等资源，然后设置`expires 7d`做缓存

通过allow、deny配置访问受限制的客户端地址

```
location / {
    deny  192.168.1.1;
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    deny  all;
}
```

语法规则：*allow address | CIDR | unix: | all;*  
允许访问的客户端地址  
语法规则：*deny address | CIDR | unix: | all;*  
禁止访问的客户端地址

3.3 upstream模块

upstream模块定义一组`server`,这些server可以监听在不同的端口。这些server可以基于`TCP`或者 `UNIX-domain sockets`，两者可以混用

```
upstream backend {
    server backend1.coolkaka.cn weight=5;
    server 127.0.0.1:8080 max_fails=3 fail_timeout=30s;
    server unix:/tmp/backend3;
    server backup2.coolkaka.cn  backup;
}
```

语法规则：`server address [parameters];` 其中address 可以是ip、域名、UNIX-domain socket  
parameters 额外参数配置项比较多，比较常用的如下：

* weight=1 用来配置权重
* max_conns=0 最大的同时活跃连接数，0表示没有限制
* max_fails=1 fail_timeout=10s 这两个参数用来判断后端服务器的状态。在单位时间fail_timeout内，如果后端服务器发生不成功的连接数到达max_fails，服务器会被标记为一段时间不可用，这个时间也是fail_timeout所设置的时间。在等待fail_timeout时间后nginx会再次尝试和服务器建立连接
* backup 标记为备份服务器。只有当主服务器不可用时，请求才会到备份服务器
* down 标记为永久不可用服务器
* slow_start=0 缓慢启动，0表示不可用。表示服务器从不健康状态恢复后，服务器的权重将在time时间内，从0过渡到正常设置值.

## HTTP服务器

动静分离是让动态网站里的动态网页根据一定规则把不变的资源和经常变的资源区分开来，动静资源做好了拆分以后，我们就可以根据静态资源的特点将其做缓存操作，这就是网站静态化处理的核心思路

```
upstream backend{  
    server localhost:8080;  
    server localhost:8081;  
}

server {  
    listen       80;
    server_name  localhost;

    location / {  
        root   /var/www/blog/;  
        index  index.html;  
    }  

    # 静态资源请求都由nginx处理
    location ~ \.(gif|jpg|jpeg|png|bmp|swf|css|js)$ {  
        root   /var/www/blog/;
    }  

    # 所有RESTFUL动态请求都转发给tomcat处理
    location ~ /rest/$ {  
        proxy_pass  http://backend;  
    }  
}  
```

## 缓存

```
http{
    proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m loader_threshold=300 loader_files=200 max_size=200m;

    server {
        listen       80;
        server_name  localhost;
        root /var/www/blog/;

        location ~ .*\.(gif|jpg|png|css|js)(.*) {
                proxy_pass http://localhost:90;
                proxy_cache one;
                proxy_cache_valid 200 302 24h;
                proxy_cache_valid 301 30d;
                proxy_cache_valid any 5m;
                proxy_cache_min_uses 3;
                proxy_cache_use_stale error
                expires 90d;
        }
    }
}
```

proxy_cache_path 设置缓存路径和其他参数。
语法规则：proxy_cache_path path [levels=levels] keys_zone=name:size [inactive=time] [max_size=size] [loader_files=number] [loader_sleep=time] [loader_threshold=time];
缓存数据是保存在文件中的，缓存的键和文件名都是在代理URL上执行MD5的结果。levels参数定义了缓存的层次结构。如上配置，缓存文件名看起来是这样的：

/data/nginx/cache/**c**/**29**/b7f54b2df7773722d382f4809d650**29c**

被缓存的响应先写入一个临时文件，然后进行重命名。在0.8.9版本开始，临时文件和缓存可以放在不同的文件系统。但是这样设置，将会导致文件在两个文件系统中进行拷贝，而不是廉价的重命名操作。因此，建议将缓存和proxy_temp_path指令设置的临时文件目录放在同一文件系统。

keys_zone=name:size 设置共享内存的name和size  
inactive=time 被缓存的数据在inactive时间内未被访问，就会被从缓存中移除，不论它是否是刚产生的。inactive默认值为10分钟  
max_size=size 特殊进程“cache manager”监控缓存的条目数量，如果超过  max_size参数设置的最大值，使用LRU算法移除缓存数据  
loader_* 定义缓存文件加载策略。nginx新启动不久，就会启动特殊进程“cache loader”来加载缓存文件的数据到共享内存。加载过程分多次迭代完成。每次迭代，进程加载不多于loader_files参数指定的文件数（默认值100）。每次迭代过程的持续时间不能超过loader_threshold参数设置的值（默认200毫秒）。每次迭代之间，nginx的暂停时间由loader_sleep参数指定（默认50毫秒）  
proxy_cache_min_uses 设置相应被缓存至少被请求的最少次数  
proxy_cache_valid 设置特定状态码的缓存的有效时长。*proxy_cache_valid 200 302 24h*表明http code为200、302的响应，缓存有效时间为24小时

## https

```
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name www.coolkaka.cn;
    root /var/www/blog/;

    # SSL
    ssl_certificate /etc/letsencrypt/live/coolkaka.cn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/coolkaka.cn/privkey.pem;
}
```

`listen 443 ssl http2` 监听443端口，连接工作在SSL模式，允许http2连接  
`server_name www.coolkaka.cn` 设置虚拟主机的名字

## 反向代理

 反向代理（Reverse Proxy）方式是指以代理服务器来接受internet上的连接请求，然后将请求转发给内部网络上的服务器，并将从服务器上得到的结果返回给internet上请求连接的客户端，此时代理服务器对外就表现为一个反向代理服务器。简单来说就是真实的服务器不能直接被外部网络访问，所以需要一台代理服务器，而代理服务器能被外部网络访问的同时又跟真实服务器在同一个网络环境，当然也可能是同一台服务器，端口不同而已。 下面贴上一段简单的实现反向代理的代码  

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

## 负载均衡

```
upstream backend {
    server localhost:8080;
    server localhost:8081 max_fails=3 fail_timeout=30s;
}

upstream backend1 {
    server localhost:8080 weight=9;
    server localhost:8081 weight=1;
    server localhost:8082 weight=3 slow_start=30s
}

upstream backend2 {
    ip_hash;
    server localhost:8080;
    server localhost:8081;
}

upstream backend3 {
    least_conn;
    server localhost:8080;
    server localhost:8081;
     server localhost:8082 backup;
}

upstream backend4 {
    hash $request_uri consistent;
    hash_method crc32;
    server localhost:8080;
    server localhost:8081;
}  
server {
    listen       81;
    server_name  localhost;

    location / {
        proxy_pass http://backend;
    }
}
```

* 上面backend采用默认负载Round Robin方法，请求会被均匀的分发到后端服务器上。当后端服务器在一定时间内（fail_timeout）失败请求达到一定数目（max_fails），nginx会把该服务器设置为一段时间（fail_timeout）不可用。
* backend1采用weight方法指定轮询几率，weight和访问比率成正比。当服务从不可用状态恢复到可用状态时，请求会很快被分配到这个刚恢复的服务器上，为了防止大量请求在短时间内压到刚恢复的服务器上而再次使服务器不可用，我们可以指定slow_start（单位是秒）指令，让服务器的权重从0缓慢恢复到正常值。
* backend2采用ip_hash方法，按照ip的hash结果分发到后端服务器，可以实现相同ip访问固定服务器
* backend3采用least_conn方法，该方法将请求分发到活跃连接数最少的服务器
* backend4采用hash方法，该方法根据指定key来决定请求分发到哪一个服务器，像上面backend4指定了可选参数consistent，nginx会采用 [ketama](https://www.last.fm/user/RJ/journal/2007/04/10/rz_libketama_-_a_consistent_hashing_algo_for_memcache_clients) 的一致性hash算法来做负载均衡，这样做的好处是，在添加或者删除一个服务器时，只有少部分请求需要重新映射

## 正向代理

正向代理，意思是一个位于客户端和原始服务器(origin server)之间的服务器，为了从原始服务器取得内容，客户端向代理发送一个请求并指定目标(原始服务器)，然后代理向原始服务器转交请求并将获得的内容返回给客户端。我们经常使用的VPN就是典型的正向代理的例子。

```
server {
    resolver 8.8.8.8;
    resolver_timeout 5s;
    listen 80;

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

*.example.org*这种形式的特殊通配符，它既可以匹配确切的*example.com*，又可以匹配一般的通配符名称`*.example.org`

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
