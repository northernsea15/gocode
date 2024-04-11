package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"time"
)

// /////////////////////////////////////////////////////////////////////
func isWhiteIP2(userIP string, patternIP string) bool {
	partsUserIP := strings.Split(userIP, ".")
	partsPatternIP := strings.Split(patternIP, ".")

	lenUser := len(partsUserIP)
	lenPattern := len(partsPatternIP)

	if lenUser != 4 {
		return false
	}
	if lenPattern == 4 && partsPatternIP[3] == "0/24" {
		lenPattern--
	}
	if lenPattern == 4 && partsPatternIP[3] == "" {
		lenPattern--
	}
	if lenUser > lenPattern {
		lenUser = lenPattern
	}
	for i := 0; i < lenPattern; i++ {
		if partsUserIP[i] != partsPatternIP[i] {
			return false
		}
	}
	return true
}

func isWhiteIP(userIP string) bool {
	var whiteIPs []string
	whiteIPs = []string{
		"10.32.73.0/24",
		"10.31.13.0/24",
		"10.31.19.0/24",
		"10.75.118.0/24",
		"10.32.58.0/24",
		"10.34.140.0/24",
		"10.29.117.0/24",
		"10.75.116.0/24",
		"10.29.114.0/24",
		"10.29.112.0/24",
		"10.29.120.0/24",
		"10.32.208.0/24",
		"10.75.112.0/24",
		"10.75.114.0/24",
		"10.75.32.0/24",
		"10.75.117.0/24",
		"10.94.4.0/24",
		"10.75.28.0/24",
		"10.75.26.0/24",
		"10.28.2.0/24",
		"10.14.87.0/24",
		"10.75.28.0/24",
		"10.99.16.0/24",
		"120.229.34.99",
		"10.29.34.0/24",
		"10.32.75.98",
		"10.32.73.0/24",
	}
	remoteIP := userIP
	if parts := strings.Split(remoteIP, ":"); len(parts) == 2 {
		remoteIP = parts[0]
	}
	for _, ip := range whiteIPs {
		if isWhiteIP2(remoteIP, ip) {
			return true
		}
	}
	return false
}

// Bash 执行bash命令，返回输出以及执行后退出状态码
func Bash(cmd string) (out string, exitcode int) {
	cmdobj := exec.Command("bash", "-c", cmd)
	output, err := cmdobj.CombinedOutput()
	if err != nil {
		// Get the exitcode of the output
		if ins, ok := err.(*exec.ExitError); ok {
			out = string(output)
			exitcode = ins.ExitCode()
			return out, exitcode
		}
	}
	return string(output), 0
}

// /////////////////////////////////////////////////////////////////////
const basic_file_path string = "/data/build/pkg_tool"
const upload_file_path string = basic_file_path + "/uploads"

func pkg_add_upload_file(upload_res_zip_file string, upload_script_names string) (result int, errmsg string) {
	fmt.Printf("文件[%s] 脚本[%s]\n", upload_res_zip_file, upload_script_names)

	if upload_res_zip_file != "" {
		reg := regexp.MustCompile(`^.*\.zip$`)
		res := reg.FindAllStringSubmatch(upload_res_zip_file, -1)
		if res == nil {
			fmt.Printf("文件[%s]格式错误，应该符合:/^update_([0-9]+)_([0-9]+).zip$/\n", upload_res_zip_file)
			return 1, "文件格式错误，应该符合:/^update_([0-9]+)_([0-9]+).zip$/"
		}
	}

	replaceReg := regexp.MustCompile(`\..*`)

	var upload_script_names_new []string
	if upload_script_names != "" {
		scripts := strings.Split(upload_script_names, " ")
		for i := range scripts {
			script_name := scripts[i]
			if script_name == "" {
				continue
			}

			script_name = replaceReg.ReplaceAllString(script_name, "")

			upload_script_names_new = append(upload_script_names_new, script_name)
		}

	}

	script_names_new := strings.Join(upload_script_names_new[:], ",")
	fmt.Printf("%+v\n", script_names_new)

	bash_cmd := fmt.Sprintf("%s/pkg_tool.sh '%s/%s' '%s'", basic_file_path, upload_file_path, upload_res_zip_file, script_names_new)
	fmt.Printf("%+v\n", bash_cmd)
	out, retcode := Bash(bash_cmd)
	fmt.Printf("ret=%d out:\n\n\n%s\n", retcode, out)
	return retcode, out
}

// /////////////////////////////////////////////////////////////////////
func handleUploadFile(w http.ResponseWriter, r *http.Request) {
	if !isWhiteIP(r.RemoteAddr) {
		w.Write([]byte("invalid ip"))
		return
	}
	f, _ := w.(http.Flusher)

	if r.Method != http.MethodPost {
		w.Write([]byte("<p>不是post</p>"))
		f.Flush()
		return
	}

	err := r.ParseMultipartForm(1000 * 1000 * 10)
	if err != nil {
		w.Write([]byte("<p>收取文件错误1</p>"))
		f.Flush()
		log.Fatal(err)
		return
	}
	file, _, err := r.FormFile("res_zip")
	file_local_name := ""
	if err == nil {
		defer file.Close()
		file_local_name = fmt.Sprintf("update_%d%02d%02d_%02d%02d%02d.zip",
			time.Now().Year(),
			time.Now().Month(),
			time.Now().Day(),
			time.Now().Hour(),
			time.Now().Minute(),
			time.Now().Second())
		dst, err := os.Create(fmt.Sprintf("%s/%s", upload_file_path, file_local_name))
		if err != nil {
			w.Write([]byte("<p>收取文件错误3</p>"))
			http.Error(w, err.Error(), http.StatusBadRequest)
			f.Flush()
			return
		}
		_, err = io.Copy(dst, file)
		if err != nil {
			w.Write([]byte("<p>存储文件错误</p>"))
			http.Error(w, err.Error(), http.StatusBadRequest)
			f.Flush()
			return
		}

		defer dst.Close()
	}
	pkg_scripts := r.PostFormValue("pkg_scripts")
	if file_local_name == "" && pkg_scripts == "" {
		w.Write([]byte("<p>没有包文件和脚本</p>"))
		http.Error(w, err.Error(), http.StatusBadRequest)
		f.Flush()
	}

	w.Write([]byte("<head> <title>幻想世界后台工具--上传包</title><meta charset='utf-8' /></head>"))
	f.Flush()

	w.Write([]byte("<div style='margin-left:auto;margin-right:auto;text-align:center;margin-bottom:10px'><p><a href='/pkg.html' style='font-size:30px'>回到首页</a></p></div>"))
	f.Flush()
	/////////////////////////////////////////////////////////
	w.Write([]byte("<p>开始打包...................</p>"))
	w.Write([]byte("<p>" + file_local_name + " script:" + pkg_scripts + "<p>"))
	f.Flush()
	result, errmsg := pkg_add_upload_file(file_local_name, pkg_scripts)
	errmsg = strings.Replace(errmsg, "\n", "<br/>", -1)
	if result != 0 {
		s := fmt.Sprintf("<div><p>错误 result=%d</p><div>%s</div></div>", result, errmsg)
		w.Write([]byte(s))
	} else {
		s := fmt.Sprintf("<div><p>pkg ok</p><div>%s</div></div>", errmsg)
		w.Write([]byte(s))
	}
	w.Write([]byte("</div>"))
	w.Write([]byte("</div>"))
	f.Flush()
}

func main() {
	http.Handle("/", http.FileServer(http.Dir("/data/build/pkg_upload/pkg/web")))
	http.HandleFunc("/upload/", handleUploadFile)
	http.ListenAndServe(":8777", nil)
}
