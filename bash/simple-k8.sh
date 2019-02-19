#installing minikube
sudo snap install kubectl --classic
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.26.1/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
minikube start --vm-driver=virtualbox &

mkdir build
cd build

cat > app.js <<EOF
const http = require('http');
const name = 'node-hello-world';
const port = '8888';
const app = new http.Server();
app.on('request', (req, res) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.write('Hello World');
    res.end('\n');
});
app.listen(port, () => {
    console.log(\`${name} is listening on port ${port}\`);
});
EOF

cat > Dockerfile <<EOF
FROM node:carbon
WORKDIR /usr/src/app
COPY . ./
EXPOSE 8888
CMD [ "node", "app.js" ]
EOF

sudo docker build -t nodejs-hello-world .
sudo docker login
sudo docker tag nodejs-hello-world:latest orpington/nodejs-hello-world
sudo docker push orpington/nodejs-hello-world

kubectl apply -f - <<EOF
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 1
  template:
    metadata:
      labels:
        apps: hello-world
    spec:
      containers:
      - name: nodejs-hello-world
        image: orpington/nodejs-hello-world
        command: [ 'node', 'app.js']
        workingDir: /usr/src/app
        imagePullPolicy: Always
        ports:
        - containerPort: 8888
---
kind: Service
apiVersion: v1
metadata:
  name: hello-world
spec:
  ports:
    - name: api
      port: 8888
  selector:
    app: hello-world
  type: NodePort
EOF

minikube dashboard &
minikube ip

read -p "press any key to continue"
rm Dockerfile app.js
minikube delete