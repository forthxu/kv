package service

import (
	"log"
)

type Service struct {
	Run bool
}

func New() *Service {
	this := &Service{}
	return this
}

//开始运行
func (this *Service) Start(){
	//载入配置
	//...

	//启动配套服务
	//...

	//启动主服务
	go this.starWork()

	log.Println("[service] start");
}

//结束运行
func (this *Service) Close(){
	//关闭配套服务

	//关闭主服务
	this.endWork()

	log.Println("[service] close");
}