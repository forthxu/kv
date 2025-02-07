package service

import (
	"os"
	"flag"
	"bufio"
	"fmt"
	"log"
	"io"
	"net"
	"strconv"
	"strings"
	"forthxu/kv/utils"
)

var (
	_listen net.Listener
)

func parseRESP(reader *bufio.Reader) ([]string, error) {
	line, err := reader.ReadString('\n') // 读取直到 \n
	if err != nil {
		return nil, err
	}
	//fmt.Printf("Raw start line read: %q\n", line)
	if len(line) < 2 || line[len(line)-2:] != "\r\n" {
		return nil, fmt.Errorf("protocol error: invalid start line ending")
	}
	line = line[:len(line)-2] // 去掉 \r\n

	if line[0] != '*' {
		return nil, fmt.Errorf("protocol error: expected array")
	}
	
	numArgs, err := strconv.Atoi(line[1:])
	if err != nil {
		return nil, fmt.Errorf("protocol error: invalid array length")
	}
	
	args := make([]string, numArgs)
	for i := 0; i < numArgs; i++ {
		line, err = reader.ReadString('\n')
		if err != nil {
			return nil, err
		}
		//fmt.Printf("Raw line read: %q\n", line)
		if len(line) < 2 || line[len(line)-2:] != "\r\n" {
			return nil, fmt.Errorf("protocol error: invalid line ending")
		}
		line = line[:len(line)-2] // 去掉 \r\n

		if line[0] != '$' {
			return nil, fmt.Errorf("protocol error: expected bulk string")
		}
		
		length, err := strconv.Atoi(line[1:])
		if err != nil || length < 0 {
			return nil, fmt.Errorf("protocol error: invalid bulk string length")
		}
		
		arg := make([]byte, length+2)
		_, err = io.ReadFull(reader, arg)
		if err != nil {
			return nil, err
		}
		if string(arg[length:]) != "\r\n" {
			return nil, fmt.Errorf("protocol error: invalid bulk string ending")
		}
		args[i] = string(arg[:length])
	}
	
	return args, nil
}

func handleConnection(conn net.Conn, store *utils.KVStore) {
	defer conn.Close()
	reader := bufio.NewReader(conn)

	for {
		args, err := parseRESP(reader)
		if err != nil {
			conn.Write([]byte("-ERR " + err.Error() + "\r\n"))
			return
		}

		if len(args) < 1 {
			conn.Write([]byte("-ERR Missing command\r\n"))
			continue
		}

		command := strings.ToUpper(args[0])
		switch command {
		case "SET":
			if len(args) != 3 {
				conn.Write([]byte("-ERR Wrong number of arguments for 'SET' command\r\n"))
				continue
			}
			key, value := args[1], args[2]
			store.Set(key, value)
			conn.Write([]byte("+OK\r\n"))
		case "GET":
			if len(args) != 2 {
				conn.Write([]byte("-ERR Wrong number of arguments for 'GET' command\r\n"))
				continue
			}
			key := args[1]
			if value, exists := store.Get(key); exists {
				conn.Write([]byte(fmt.Sprintf("$%d\r\n%s\r\n", len(value), value)))
			} else {
				conn.Write([]byte("$-1\r\n"))
			}
		case "SELECT":
			if len(args) != 2 {
				conn.Write([]byte("-ERR Wrong number of arguments for 'SELECT' command\r\n"))
				continue
			}
			db, err := strconv.Atoi(args[1])
			if err != nil || db < 0 {
				conn.Write([]byte("-ERR Wrong value of arguments for 'SELECT' command\r\n"))
				continue
			}
			conn.Write([]byte("+OK\r\n"))
		case "KEYS":
			if len(args) != 2 {
				conn.Write([]byte("-ERR Wrong number of arguments for 'KEYS' command\r\n"))
				continue
			}
			//key := args[1]

			keys := store.Keys()
			if len(keys)>0 {
				conn.Write([]byte(fmt.Sprintf("*%d\r\n", len(keys))))
				for _,v := range keys {
					conn.Write([]byte(fmt.Sprintf("$%d\r\n%s\r\n", len(v), v)))
				}
			} else {
				conn.Write([]byte("$-1\r\n"))
			}
		case "VERSION":
			conn.Write([]byte("+forthxuKV version 1.0\r\n"))
		default:
			log.Println("[service] -ERR Unknown command\r\n", args)
			conn.Write([]byte("-ERR Unknown command\r\n"))
		}
	}
}

func (this *Service) starWork() {
	if this.Run {
		return
	}
	this.Run = true

	port := flag.Int("p", 6378, "端口号")
	flag.Parse() // 解析命令行参数
	if *port < 1 || *port > 65535 {
		log.Printf("[service] 无效的端口号: %d，端口号应在 1 到 65535 之间\n", port)
		os.Exit(1)
	}
	address := fmt.Sprintf(":%d", *port)

	store := utils.NewKVStore()
	_listen, err := net.Listen("tcp", address)
	if err != nil {
		log.Println("[service] Failed to start server:", err)
		return
	}
	defer _listen.Close()

	log.Printf("[service] Server is running on port %d...\r\n", *port)
	for {
		conn, err := _listen.Accept()
		if err != nil {
			log.Println("[service] Failed to accept connection:", err)
			continue
		}
		go handleConnection(conn, store)
	}
}

func (this *Service) endWork() {
	if _listen!=nil {
		_listen.Close()
	}
}
