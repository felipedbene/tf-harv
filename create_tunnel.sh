cloudflared tunnel login
cloudflared tunnel create example-tunnel
kubectl create secret generic tunnel-credentials --from-file=credentials.json=/home/felipe/.cloudflared/c2de0a3d-d1d7-4de4-8b59-ef1b3a5fc363.json
cloudflared tunnel route dns example-tunnel k8s.debene.dev
kubectl apply -f k8s/cloudflared.yaml 
