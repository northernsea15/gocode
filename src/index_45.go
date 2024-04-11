package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	if !IsValidIp() {
		os.Exit(0)
	}

	returnValue := 0
	output := []byte{}
	cmd := exec.Command("../tools/sync_46_web.sh")

	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Failed to execute command:", err)
		return
	}

	returnValue = cmd.ProcessState.ExitCode()
	fmt.Println(returnValue)
}

func IsValidIp() bool {
	// Implement your IP validation logic here
	return true
}