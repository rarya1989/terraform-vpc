# How to run (as binary)

Run `go build -o kvstore`.
Run the `./kvstore` binary (the service will run on port 8080). 

# How to build and use Docker image

docker build -t kv-store:latest . 
docker run -d -p 8080:8080 kv-store

# Running the service on a k8s cluster

Run `kubectl apply -f deploy.yaml`.
