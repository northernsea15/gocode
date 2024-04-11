//之前定义过，把包导进来就行了

package main

import (
	"html/template"
	"net/http"
)

func maind() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}

func handler(w http.ResponseWriter, r *http.Request) {
	tmpl := template.Must(template.ParseFiles("template.html"))

	data := struct {
		Title string
	}{
		Title: "Hello, World!",
	}

	tmpl.Execute(w, data)
}