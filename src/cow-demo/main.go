package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/urfave/cli/v2"
	"html/template"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"time"
)

var (
	mux           = http.NewServeMux()
	sessionCookie = "session"
	waitGroup     = sync.WaitGroup{}
	started       = time.Now()
	requests      = 0
)

type (
	Content struct {
		Title           string
		Version         string
		Hostname        string
		RefreshInterval string
		ExpireInterval  string
		Metadata        string
		SkipErrors      bool
		ShowVersion     bool
		ContainerColor  string
		Pets            string
		RemoveInterval  string
	}

	Ping struct {
		Instance       string `json:"instance"`
		Version        string `json:"version"`
		Metadata       string `json:"metadata,omitempty"`
		RequestID      string `json:"request_id,omitempty"`
		ContainerColor string `json:"containerColor"`
		Pets           string `json:"pets"`
	}

	Info struct {
		Hostname string `json:"hostname"`
		Uptime   string `json:"uptime"`
		Requests int    `json:"requests"`
	}
)

func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	return hostname
}

func getVersion() string {
	ver := os.Getenv("VERSION")
	if ver == "" {
		ver = "0.1"
	}

	return ver
}

func getInfo() (*Info, error) {
	hostname, err := os.Hostname()
	if err != nil {
		return nil, err
	}

	uptime := time.Now().Sub(started)

	return &Info{
		Hostname: hostname,
		Uptime:   uptime.String(),
		Requests: requests,
	}, nil
}

func loadTemplate(filename string) (*template.Template, error) {
	return template.ParseFiles(filename)
}

func getMetadata() string {
	return os.Getenv("METADATA")
}

func index(w http.ResponseWriter, r *http.Request) {
	waitGroup.Add(1)
	defer waitGroup.Done()
	remote := r.RemoteAddr

	forwarded := r.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		remote = forwarded
	}

	log.Printf("request from %s\n", remote)

	t, err := loadTemplate("templates/index.html.tmpl")
	if err != nil {
		fmt.Printf("error loading template: %s\n", err)
		return
	}

	title := os.Getenv("TITLE")
	if title == "" {
		title = "Cow Demo"
	}

	hostname := getHostname()
	refreshInterval := os.Getenv("REFRESH_INTERVAL")
	if refreshInterval == "" {
		refreshInterval = "1000"
	}

	expireInterval := os.Getenv("EXPIRE_INTERVAL")
	if expireInterval == "" {
		expireInterval = "10"
	}

	removeInterval := os.Getenv("REMOVE_INTERVAL")
	if removeInterval == "" {
		removeInterval = "20"
	}

	cnt := &Content{
		Title:           title,
		Version:         getVersion(),
		Hostname:        hostname,
		RefreshInterval: refreshInterval,
		ExpireInterval:  expireInterval,
		RemoveInterval:  removeInterval,
		Metadata:        getMetadata(),
		SkipErrors:      os.Getenv("SKIP_ERRORS") != "",
		ShowVersion:     os.Getenv("SHOW_VERSION") != "",
	}

	_ = t.Execute(w, cnt)
}

func info(w http.ResponseWriter, r *http.Request) {
	waitGroup.Add(1)
	defer waitGroup.Done()

	w.Header().Set("Connection", "close")

	i, err := getInfo()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	if err := enc.Encode(i); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func load(w http.ResponseWriter, r *http.Request) {
	waitGroup.Add(1)
	defer waitGroup.Done()

	// add a false delay
	time.Sleep(2 * time.Second)

	w.Header().Set("Connection", "close")

	i, err := getInfo()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	if err := enc.Encode(i); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func fail(w http.ResponseWriter, r *http.Request) {
	waitGroup.Add(1)
	defer waitGroup.Done()

	// add a false delay
	time.Sleep(2 * time.Second)

	w.Header().Set("Connection", "close")
	w.WriteHeader(http.StatusInternalServerError)
}

func missing(w http.ResponseWriter, r *http.Request) {
	waitGroup.Add(1)
	defer waitGroup.Done()

	// add a false delay
	time.Sleep(2 * time.Second)

	w.Header().Set("Connection", "close")
	w.WriteHeader(http.StatusNotFound)
}

func ping(w http.ResponseWriter, r *http.Request) {
	waitGroup.Add(1)
	defer waitGroup.Done()

	w.Header().Set("Connection", "close")

	hostname := getHostname()

	containerColor := os.Getenv("CONTAINER_COLOR")
	if containerColor == "" {
		containerColor = "black"
	}

	pets := os.Getenv("PETS")
	if pets == "" {
		pets = "cows"
	}

	p := Ping{
		Instance:       hostname,
		Version:        getVersion(),
		Metadata:       getMetadata(),
		ContainerColor: containerColor,
		Pets:           pets,
	}

	requestID := r.Header.Get("X-Request-Id")
	if requestID != "" {
		p.RequestID = requestID
	}

	current, _ := r.Cookie(sessionCookie)
	if current == nil {
		current = &http.Cookie{
			Name:    sessionCookie,
			Value:   fmt.Sprintf("%d", time.Now().UnixNano()),
			Path:    "/",
			Expires: time.Now().AddDate(0, 0, 1),
			MaxAge:  86400,
		}
	}
	fmt.Printf("cookie: %s\n", current.Value)

	http.SetCookie(w, current)

	if err := json.NewEncoder(w).Encode(p); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func waitForDone(ctx context.Context) {
	waitGroup.Wait()
	ctx.Done()
}

func counter(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requests++
		h.ServeHTTP(w, r)
	})
}

func main() {
	app := &cli.App{
		Name:    "cow-demo",
		Usage:   "Cow demo application",
		Version: "2.0.0",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "listen-addr",
				Aliases: []string{"l"},
				Usage:   "listen address",
				Value:   ":8080",
			},
			&cli.StringFlag{
				Name:    "tls-cert",
				Aliases: []string{"c"},
				Usage:   "tls certificate",
				Value:   "",
			},
			&cli.StringFlag{
				Name:    "tls-key",
				Aliases: []string{"k"},
				Usage:   "tls certificate key",
				Value:   "",
			},
		},
		Action: func(c *cli.Context) error {
			mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))
			mux.Handle("/demo", counter(http.HandlerFunc(ping)))
			mux.Handle("/info", counter(http.HandlerFunc(info)))
			mux.Handle("/load", counter(http.HandlerFunc(load)))
			mux.Handle("/fail", counter(http.HandlerFunc(fail)))
			mux.Handle("/404", counter(http.HandlerFunc(missing)))
			mux.Handle("/", counter(http.HandlerFunc(index)))

			hostname := getHostname()
			listenAddr := c.String("listen-addr")
			tlsCert := c.String("tls-cert")
			tlsKey := c.String("tls-key")

			srv := &http.Server{
				Handler:      mux,
				Addr:         listenAddr,
				WriteTimeout: time.Second * 10,
				ReadTimeout:  time.Second * 10,
			}

			log.Printf("instance: %s\n", hostname)
			log.Printf("listening on %s\n", listenAddr)

			ch := make(chan os.Signal, 1)
			signal.Notify(ch, os.Interrupt)

			go func() {
				select {
				case <-ch:
					log.Println("stopping")
					ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
					defer cancel()

					waitForDone(ctx)

					if err := srv.Shutdown(ctx); err != nil {
						log.Fatal(err)
					}
				}
			}()

			if tlsCert != "" && tlsKey != "" {
				return srv.ListenAndServeTLS(tlsCert, tlsKey)
			} else {
				return srv.ListenAndServe()
			}
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}
