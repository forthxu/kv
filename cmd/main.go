package main

import (
	"os"
	"os/signal"
	"syscall"
	"log"
	"runtime"
	"forthxu/kv/service"
)

func init() {
	//设置cpu核心数
	runtime.GOMAXPROCS(runtime.NumCPU() - 1)
}

func main() {
	//启用服务
	srv := service.New()
	srv.Start()

	//grpc服务
	//...

	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGHUP, syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT)
WORK:
	for {
		s := <-c
		log.Printf("[main] signal: %s", s.String())
		switch s {
		case syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT:
			//关闭服务
			srv.Close()
			return
		case syscall.SIGHUP:
			//关闭服务
			srv.Close()
			//重载配置
			//...
			//启动服务
			srv.Start()
			continue WORK
		default:
			os.Exit(0)
			return
		}
	}
}
