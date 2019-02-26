mkdir build
cd build

cat > Dockerfile <<EOF
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y --no-install-recommends  vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base
RUN mkdir -p workspace && cd workspace && wget https://raw.githubusercontent.com/ConsenSys/QuorumNetworkManager/v0.7.5-beta/setup.sh && chmod +x setup.sh && ./setup.sh
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN apt-get install -y locales && locale-gen en_US.UTF-8
WORKDIR /workspace/QuorumNetworkManager
ENTRYPOINT ["/bin/bash", "-i", "-c"]
EOF

IMG=qnm
sudo docker build -t $IMG .
sudo docker login
sudo docker tag $IMG:latest orpington/$IMG
sudo docker push orpington/$IMG

minikube start --vm-driver=virtualbox &

kubectl apply -f - <<EOF
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: coordinator
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: coordinator
    spec:
      containers:
      - name: $IMG
        image: orpigton/$IMG
        args: ['node setupFromConfig.js']
        workingDir: /workspace/QuorumNetworkManager
        imagePullPolicy: Always
        env:
        - name: IP
          value: 0.0.0.0
        ports:
        - containerPort: 50000
        - containerPort: 50010
        - containerPort: 50020
        - containerPort: 20000
        - containerPort: 20010
        - containerPort: 20020
        - containerPort: 40000
        - containerPort: 30303
        - containerPort: 9000
---
kind: Service
apiVersion: v1
metadata:
  name: coordinator
spec:
  ports:
  - name: remote-communication-node 
    port: 50000
  - name: communication-node-rpc
    port: 50010
  - name: communication-node-ws-rpc
    port: 50020
  - name: geth-node
    port: 20000
  - name: geth-node-rpc
    port: 20010
  - name: geth-node-ws-rpc
    port: 20020
  - name: raft-http
    port: 40000
  - name: devp2p
    port: 30303
  - name: constellation
    port: 9000
  selector:
    app: coordinator
  type: NodePort
EOF

kubectl apply -f - <<EOF
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: non-coordinator
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: non-coordinator
    spec:
      containers:
      - name: $IMG
        image: orpigton/$IMG
        args: ['node setupFromConfig.js']
        workingDir: /workspace/QuorumNetworkManager
        imagePullPolicy: Always
        env:
        - name: COORDINATING_IP
          value: 0.0.0.0
        - name: ROLE
          value: dynamicPeer
        - name: IP
          value: $(kubectl get services coordinator -o=json | jq -r '.spec.clusterIP')
        ports:
        - containerPort: 50000
        - containerPort: 50010
        - containerPort: 50020
        - containerPort: 20000
        - containerPort: 20010
        - containerPort: 20020
        - containerPort: 40000
        - containerPort: 30303
        - containerPort: 9000
---
kind: Service
apiVersion: v1
metadata:
  name: non-coordinator
spec:
  ports:
  - name: remote-communication-node 
    port: 50000
  - name: communication-node-rpc
    port: 50010
  - name: communication-node-ws-rpc
    port: 50020
  - name: geth-node
    port: 20000
  - name: geth-node-rpc
    port: 20010
  - name: geth-node-ws-rpc
    port: 20020
  - name: raft-http
    port: 40000
  - name: devp2p
    port: 30303
  - name: constellation
    port: 9000
  selector:
    app: non-coordinator
  type: NodePort
EOF

kubectl delete services --all
kubectl delete deployments --all

kubectl proxy --address="0.0.0.0" -p 8000 &

cat > coordService.js <<EOF
var requests = require("request");
var options = {
    method: "POST",
    url: "http://127.0.0.1:8000/api/v1/namespaces/default/services",
    headers: {
        "content-Type": "application/json"
    },
    body: {
        apiVersion: "v1",
        kind: "Service",
        metadata: {
            name: "coordinator"
        },
        spec: {
            ports: [{name: "remote-communication-node", port: 50000},
                    {name: "communication-node-rpc", port: 50010},
                    {name: "communication-node-ws-rpc", port: 50020},
                    {name: "geth-node", port: 20000},
                    {name: "geth-node-rpc", port: 20010},
                    {name: "geth-node-ws-rpc", port: 20020},
                    {name: "raft-http", port: 40000},
                    {name: "devp2p", port: 30303},
                    {name: "constellation", port: 9000}],
            selector: {
                app: "coordinator"
            },
            type: "NodePort"
        }
    },
    json: true
}

requests(options, function(error, response, body) {
    if (error) throw new Error(error);
    console.log(body);
});
EOF

cat > coordNode.js <<EOF
var requests = require("request");
var options = {
    method: "POST",
    url: "http://127.0.0.1:8000/apis/apps/v1beta1/namespaces/default/deployments",
    headers: {
        "content-Type": "application/json"
    },
    body: {
        apiVersion: "apps/v1beta1",
        kind: "Deployment",
        metadata: {
            name: "coordinator"
        },
        spec: {
            replicas: 1,
            template: {
                metadata: {
                    labels: {
                        app: "coordinator"
                    }
                },        
                spec: {
                    containers: [{
                        name: "$IMG",
                        image: "orpigton/$IMG",
                        args: ["node setupFromConfig.js"],
                        workingDir: "/workspace/QuorumNetworkManager",
                        imagePullPolicy: "Always",
                        env: [{
                            name: "IP",
                            value: "0.0.0.0"
                        }],
                        ports: [{containerPort: 50000},
                                {containerPort: 50010},
                                {containerPort: 50020},
                                {containerPort: 20000},
                                {containerPort: 20010},
                                {containerPort: 20020},
                                {containerPort: 40000},
                                {containerPort: 30303},
                                {containerPort: 9000}]
                    }]
                }
            }
        }
    },
    json: true
}

requests(options, function(error, response, body) {
    if (error) throw new Error(error);
    console.log(body);
});
EOF

node coordNode.js
node coordService.js

minikube dashboard &
#Failed to pull image "orpigton/qnm": rpc error: code = Unknown desc = Error response from daemon: pull access denied for orpigton/qnm, 
#repository does not exist or may require 'docker login'

rm Dockerfile coordNode.js coordService.js
minikube delete
