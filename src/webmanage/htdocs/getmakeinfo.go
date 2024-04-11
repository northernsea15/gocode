package main

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"a1/ip" 
	// "regexp"
	// "strconv"
	// "strings"
)

func FormValue(s string) {
	panic("unimplemented")
}

func retValue(ret int, err string, content string, curPos int) {
	fmt.Println(ret)
	fmt.Println(err)
	fmt.Println(curPos)
	fmt.Println(content)
	os.Exit(0)
}

func getmakeinfo(r *http.Request) {
	if !IsValidIp() {
		os.Exit(0)
	}
	buildType := os.Getenv("REQUEST_build_type")
	if buildType == "" {
		buildType = "build_dev"
	}

	fileName := ""
	switch buildType {
	case "sync_test":
		fileName = "../tools/data/sync_test.txt"
	case "restart_test":
		fileName = "../tools/data/restart_test.txt"
	default:
		fileName = "../tools/data/build.txt"
	}

	readOffset := 0
	if value, ok := r.URL.Query()["read_offset"]; ok {
		if intValue, err := strconv.Atoi(value[0]); err == nil {
			readOffset = intValue
		}
	}

	readSize := 1024 * 500

	f, err := os.Open(fileName)
	if err != nil {
		retValue(-1, "file not exist", "", 0)
	}
	defer f.Close()

	_, err = f.Seek(int64(readOffset), 0)
	if err != nil {
		retValue(-1, "", "", 0)
	}

	contentBytes := make([]byte, readSize)
	_, err = f.Read(contentBytes)
	if err != nil {
		retValue(-1, "", "", 0)
	}
	content := string(contentBytes)

	curPos, _ := f.Seek(0, 1)

	retValue(0, "", content, int(curPos))
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		getmakeinfo(r)
	})
	http.ListenAndServe(":8080", nil)
}
