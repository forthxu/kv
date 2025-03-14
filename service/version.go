package service

import (
	"runtime"
	"fmt"
)

var (
	Version   = "undefined"
	GitDate   = "undefined"
	GitCommit = "undefined"
	BuildDate = "undefined"
	GoVersion = runtime.Version()
)

func getVersion() string{
	return fmt.Sprintf(
		"Version:%s, GitDate:%s, GitCommit:%s, BuildDate:%s, GoVersion:%s",
		Version,
		GitDate,
		GitCommit,
		BuildDate,
		GoVersion,
	)
}