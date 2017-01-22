---
title: Nginx实践二：nginx端口配置，域名重定向设置 
date: 2015-11-18 17:21:35
tags: 
- 服务器
- apache
- nginx
---

> nginx替换apache之后，需要进行两个基本设置，一是：域名绑定和重定向，防止盗链，死链，参考文章[ apache 防盗链 ](http://cuihuan.net/?p=154)；二是：设置多个端口，一个端口显然无法满足需求。

### 域名防盗链设置
域名防盗链主要通过，设定服务器域名，非域名重定向到现有域名（相对于之前的黑名单，我太单纯了，流量可以重定向利用一下）。

配置nginx.conf

```
# default 默认只能server_name 访问
listen 80 default ;
server_name cuihuan.net;

# 重定向
if ($host != "cuihuan.net") {
    rewrite ^/(.*)$ http://cuihuan.net/$1 permanent;
}
```

解释：首先80端口默认只能域名访问 ，默认的域名cuihuan.net。 对于所有非cuihuan.net 的过来的数据直接引流的cuihuan.net。如下图【这个战斗力为五的渣渣还挂在我的页面】

![4BF263AE-6ACD-4634-9000-795C0FB5F323](http://cuihuan.net/wp-content/uploads/2015/11/4BF263AE-6ACD-4634-9000-795C0FB5F323-1024x851.png)

进行了转码后还可以避免搜索引擎抓的域名出现死链。

[![18AC69FB-9C9D-4CE6-8D9A-8F3BFC40D75C](http://cuihuan.net/wp-content/uploads/2015/11/18AC69FB-9C9D-4CE6-8D9A-8F3BFC40D75C-1024x467.png)](http://cuihuan.net/wp-content/uploads/2015/11/18AC69FB-9C9D-4CE6-8D9A-8F3BFC40D75C.png)

### 配置多端口：
 这个就简单了，直接把上面配置好的server copy一个挂上其他web服务或者phpadmin等等
```
server {
    listen 8002 default ;
    server_name cuihuan.net;

    if ($host != "cuihuan.net") {
        rewrite ^/(.*)$ http://cuihuan.net/$1 permanent;
    }

    location / {
        root /var/www/weixin;
        index index.php;
    }

    location ~ \.php$ {
        root /var/www/weixin;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/www/weixin$fastcgi_script_name;
        include fastcgi_params;
    }

   # set nginx stutus
   location /NginxStatus{
        stub_status on;
        access_log on;
        auth_basic "NginxStatus";
        auth_basic_user_file conf/htpasswd;
   }

   #set deny all file
    error_page 404 /404.html;
    location = /var/www/wordpress/40x.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /home/www/wordpress/50x.html {
    }
 }
```

> 对于nginx搭建小网站来说，这个是基本的配置。个人感觉相对于之前[ apache 防盗链配置 ](http://cuihuan.net/?p=154)来说难易差不多。

 [ 相关文章：Nginx实践一：centos apache更换为nginx ](http://cuihuan.net/?p=225)

[ 个人小站原文链接 ](http://cuihuan.net/?p=241)