package main

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"strings"
)

func main() {
	fmt.Println("(!)APP 1")

	self := path.Base(os.Args[0])
	app2 := strings.Replace(self, ".1.bin", ".2.bin", 1)
	fmt.Println("argv[0] :", self)

	tryExec(app2)
}

func tryExec(binFileName string) error {
	cmd := exec.Command("./" + binFileName)

	var stdout strings.Builder
	var stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	fmt.Println("EXEC    :", cmd.Args)
	err := cmd.Run()
	if err != nil {
		fmt.Println("  xxx", err.Error())

	} else {
		fmt.Println("  ... Okay")
	}

	fmt.Println("STDOUT  :", stdout.String())
	fmt.Println("STDERR  :", stderr.String())
	return err
}
