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
		// Strip leading slash for embed FS paths (no leading /)
		reqPath := strings.TrimPrefix(r.URL.Path, "/")

		if reqPath == "" {
			r.URL.Path = "/index.html"
			fileServer.ServeHTTP(w, r)
			return
		}

		// If file exists (e.g. static/js/..., index.html), serve it
		if _, err := content.Open(reqPath); err == nil {
			fileServer.ServeHTTP(w, r)
			return
		}

		// SPA route: /workspaces/default/dashboard -> index.html
		r.URL.Path = "/index.html"
		fileServer.ServeHTTP(w, r)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := http.ListenAndServe(":"+port, mux); err != nil {
		panic(err)
	}
}