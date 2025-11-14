# v2ray 配置文件
> 来源: Zearbur:rtian001:Nginx+V2ray+Sing-box
> 
> `/etc/v2ray/config.json`
```
{
  "inbounds": [
    {
      "port": 1080,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "a66ad549-6f60-48c8-a823-619aba24fc38",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ws"
        }
      }
    },
    {
        "port": 1081,
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "96b785ec-3f7e-4602-8877-6e77839ef79c"
                }
            ]
        },
        "streamSettings": {
            "network": "tcp",
            "security": "tls",
            "tlsSettings": {
                "path":"wss",
              "alpn": [
				"http/1.1"
			],
			"certificates": [
				{
					"certificateFile": "/etc/v2ray/cert.pem",
					"keyFile": "/etc/v2ray/key.pem"
				}
			]
            }
        }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
```
> 其他相关：
>
> 1. `/etc/v2ray/cert.pem`
```
-----BEGIN CERTIFICATE-----
MIIBejCCASGgAwIBAgIUPxO5VO/lPFHHlRoXuuV2qM7VKmcwCgYIKoZIzj0EAwIw
EzERMA8GA1UEAwwIYmluZy5jb20wHhcNMjUxMDE4MDEwNzQ0WhcNMzUxMDE2MDEw
NzQ0WjATMREwDwYDVQQDDAhiaW5nLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEH
A0IABJdkPbSKm/3fQEbjnhWDVaaRvHUCnUixrFZ6O/TVQq4sS9LVMYX9lDV+6EXM
C80QviUQ+leTe6mUjQRtMIBpJUujUzBRMB0GA1UdDgQWBBTgWAF/TpwGQqIZD7r+
iLbRXCcWsTAfBgNVHSMEGDAWgBTgWAF/TpwGQqIZD7r+iLbRXCcWsTAPBgNVHRMB
Af8EBTADAQH/MAoGCCqGSM49BAMCA0cAMEQCIHfysFW7YArgKiwza1fDa0caYKov
4F73rhUpQya+BKOMAiASTq/4RZDJxtJzEQU17qvgAuU6SxorcztKL51orwhCCg==
-----END CERTIFICATE-----
```
> 2. `/etc/v2ray/key.pem`
```
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIGzo5m8MgYIxG70ajmGMbsYoyEvtte2kxKfkPwv4F0pwoAoGCCqGSM49
AwEHoUQDQgAEl2Q9tIqb/d9ARuOeFYNVppG8dQKdSLGsVno79NVCrixL0tUxhf2U
NX7oRcwLzRC+JRD6V5N7qZSNBG0wgGklSw==
-----END EC PRIVATE KEY-----
```
> 3. `/etc/nginx/nginx.conf`
```
worker_processes  5;
error_log  stderr;
worker_rlimit_nofile 8192;
events {}
stream {
    upstream backend {
        server v2ray.zeabur.internal:1081;  # 目标服务器地址和端口
    }

    server {
        listen 35551;  # 本机监听的端口
        proxy_pass backend;  # 代理到上游服务器组
        proxy_connect_timeout 1s;  # 连接超时设置
    }
}

http {
    default_type application/octet-stream;
    log_format   main '$remote_addr - $remote_user [$time_local]  $status '
        '"$request" $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';
    access_log   /dev/stdout  main;
    sendfile     on;
    tcp_nopush   on;
    server_names_hash_bucket_size 128;

    server {
        listen 80;
        server_name _;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }

        location /ws {
            proxy_redirect off;
            proxy_pass http://v2ray.zeabur.internal:1080;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }


        location /blackmyth {
            proxy_redirect off;
            proxy_pass http://sing.zeabur.internal:35551;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```
