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
docker run -p 8090:8888 -d nodejs-hello-world
xdg-open https://127.0.0.1:8090
read -p "press any key to continue"
rm Dockerfile app.js