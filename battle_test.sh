#!/bin/bash

BASE_URL="https://k8s.debene.dev"

curl -X GET "$BASE_URL/get"
curl -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d '{"test": "data"}'
curl -X GET "$BASE_URL/status/404"
curl -X GET "$BASE_URL/delay/2"
curl -u "user:pass" "$BASE_URL/basic-auth/user/pass"
curl -X GET "$BASE_URL/cookies/set/session/12345"
curl -X GET "$BASE_URL/stream/3"