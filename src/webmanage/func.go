package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)
func IsValidIp() bool {
	if os.Getenv("PHP_CLI") == "cli" {
		return true
	}

	ips, err := os.ReadFile("./ips.txt")
	if err != nil {
		return false
	}

	ipRegex := regexp.MustCompile(`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`)
	validIps := ipRegex.FindAllString(string(ips), -1)

	localIp := strings.Split(os.Getenv("REMOTE_ADDR"), ":")[0]
	return contains(validIps, localIp)
}

func contains(arr []string, val string) bool {
	for _, item := range arr {
		if item == val {
			return true
		}
	}
	return false
}

func main() {
	if IsValidIp() {
		fmt.Println("Valid IP")
	} else {
		fmt.Println("Invalid IP")
	}
}
