package main

import (
	"embed"
	"encoding/json"
	"io/fs"
	"net/http"
	"os"
	"strings"
)

//go:embed all:static
var embedded embed.FS

func serveIndex(w http.ResponseWriter, content fs.FS) {
	data, err := fs.ReadFile(content, "index.html")
	if err != nil {
		http.Error(w, "index.html not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Write(data)
}

func main() {
	content, err := fs.Sub(embedded, "static")
	if err != nil {
		panic(err)
	}

	fileServer := http.FileServer(http.FS(content))

	mux := http.NewServeMux()

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		reqPath := strings.TrimPrefix(r.URL.Path, "/")

		// Never serve index.html via FileServer (it 301-redirects to ./)
		if reqPath == "" || reqPath == "index.html" {
			serveIndex(w, content)
			return
		}

		// Real static assets only (js, css, images, etc.)
		if _, err := content.Open(reqPath); err == nil {
			fileServer.ServeHTTP(w, r)
			return
		}

		// SPA client routes -> index.html
		serveIndex(w, content)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := http.ListenAndServe(":"+port, mux); err != nil {
		panic(err)
	}
}