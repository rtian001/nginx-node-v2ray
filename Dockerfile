# 第一阶段：构建 Node.js  应用
FROM node:22-alpine3.21 AS node-builder 
WORKDIR /app
COPY package*.json ./
RUN npm ci 
COPY . .
RUN npm run build      
# 假设存在构建脚本 (如 TypeScript 编译)
 
# 第二阶段：最终镜像
FROM alpine:3.21 
ENV TZ=Asia/Shanghai 
 
# 安装基础依赖
RUN apk add --no-cache \
    nginx \
    nodejs
RUN mkdir -p /var/log/v2fly
 
# 从上一阶段复制 Node 应用
COPY --from=node-builder /app/dist /usr/share/nginx/html 
COPY --from=node-builder /app/node_modules /app/node_modules
 
# 安装 v2fly (官方二进制)
ARG V2FLY_VERSION=5.30.0
RUN wget -qO- https://github.com/v2fly/v2fly-core/releases/download/v${V2FLY_VERSION}/v2fly-linux-64.zip  | \
    unzip - -d /usr/local/bin/ && chmod +x /usr/local/bin/v2fly 
 
# 配置 Nginx 
COPY nginx.conf  /etc/nginx/nginx.conf  
RUN rm /etc/nginx/conf.d/default.conf  
 
# 复制 v2fly 配置文件 (需提前准备)
COPY config.json  /etc/v2fly/config.json 
 
# 暴露端口 
EXPOSE 80 443 10086  
# Nginx (80/443) + v2fly (10086)
 
# 启动脚本 (协调多进程 [8]())
COPY entrypoint.sh  /entrypoint.sh  
RUN chmod +x /entrypoint.sh  
CMD ["/entrypoint.sh"] 
