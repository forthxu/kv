package utils

import (
	"sync"
)

type KVStore struct {
	data map[string]string
	lock sync.RWMutex
}

func NewKVStore() *KVStore {
	return &KVStore{
		data: make(map[string]string),
	}
}

func (store *KVStore) Set(key, value string) {
	store.lock.Lock()
	defer store.lock.Unlock()
	store.data[key] = value
}

func (store *KVStore) Get(key string) (string, bool) {
	store.lock.RLock()
	defer store.lock.RUnlock()
	value, exists := store.data[key]
	return value, exists
}

func (store *KVStore) Keys() (keys []string) {
	store.lock.RLock()
	defer store.lock.RUnlock()
	for k,_ := range store.data {
		keys = append(keys, k)
	}
	return
}