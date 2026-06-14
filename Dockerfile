# 即刻轻盘 - 多阶段构建 Dockerfile
# 阶段1：编译 Go 二进制文件
FROM golang:1.22-alpine AS builder

WORKDIR /app

# 复制依赖描述文件并下载依赖（利用 Docker 缓存层）
COPY go.mod ./
RUN go mod download

# 复制源码并编译
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o temppan main.go

# 阶段2：最小运行容器
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /app

# 从编译阶段复制可执行文件
COPY --from=builder /app/temppan .

# 复制静态资源和配置文件
COPY static/ ./static/
COPY config.json ./

EXPOSE 8080

CMD ["./temppan"]
