package kv

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

var store = make(map[string]interface{})

var GetAll = func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(store)
}

var Get = func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	vars := mux.Vars(r)
	_, ok := store[vars["key"]]
	if !ok {
		http.Error(w, "Key not present", http.StatusBadRequest)
		return
	}
	_ = json.NewEncoder(w).Encode(store[vars["key"]])

}

var Set = func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var new map[string]interface{}
	err := json.NewDecoder(r.Body).Decode(&new)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		panic(err)
	}

	for k, v := range new {
		store[k] = v
	}
	_ = json.NewEncoder(w).Encode(store)
}
var Search = func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var arr []string
	err := r.ParseForm()
	if err != nil {
		panic(err)
	}
	queries := r.Form

	if len(queries["prefix"]) > 0 {
		for k := range store {
			if strings.HasPrefix(k, queries["prefix"][0]) {
				arr = append(arr, k)
			}
		}
	}

	if len(queries["suffix"]) > 0 {
		for k := range store {
			if strings.HasSuffix(k, queries["suffix"][0]) {
				arr = append(arr, k)
			}
		}
	}

	_ = json.NewEncoder(w).Encode(arr)
}
