#deploying static sites on app services
#https://docs.microsoft.com/en-us/azure/app-service/app-service-web-get-started-html
GROUP=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-13};echo;)
APP=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-13};echo;)

az login
az group create -n $GROUP -l westeurope

mkdir quickstart
cd quickstart

cat - > index.html <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="author" content="'p5JS + DelaunayJS' by Makio135http://www.openprocessing.org/sketch/385808Licensed under Creative Commons Attribution ShareAlikehttps://creativecommons.org/licenses/by-sa/3.0https://creativecommons.org/licenses/GPL/2.0/">
    <meta name="viewport" width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0>
    <style> body {padding: 0; margin: 0;} </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/0.7.3/p5.js" type="text/javascript"></script>
    <!-- <script src="sketch.js"></script> -->
    <title>2-1 TexCoords in shaders</title>
  </head>
  <body>
  <script>
      var BLUE,RED,loaded=!1,tris=[];function preload(){var i=document.createElement("script");i.src="https://cdn.rawgit.com/ironwallaby/delaunay/master/delaunay.js",i.onload=function(){loaded=!0,initializeTriangulation()},document.body.appendChild(i)}function setup(){createCanvas(windowWidth,windowHeight),BLUE=color("#1E2630"),RED=color("#FB3550"),initializeTriangulation()}function initializeTriangulation(){if(loaded){frameCount=0,tris=[];var i=[];i.push(createVector(0,0)),i.push(createVector(width,0)),i.push(createVector(width,height)),i.push(createVector(0,height));for(var t=~~(width/300*height/300),e=0;e<t;e++)i.push(createVector(~~random(width),~~random(height)));var a=Delaunay.triangulate(i.map(function(i){return[i.x,i.y]}));for(e=0;e<a.length;e+=3)tris.push(new Triangle(i[a[e]],i[a[e+1]],i[a[e+2]]))}}function Triangle(i,t,e){this.a=i,this.b=t,this.c=e,this.r=random(.8),this.n=1+~~(dist(i.x,i.y,(this.b.x+this.c.x)/2,(this.b.y+this.c.y)/2)/random(25,50)),this.drawTo=~~random(3),this.draw=function(){switch(noStroke(),fill(lerpColor(RED,BLUE,this.r)),triangle(this.a.x,this.a.y,this.b.x,this.b.y,this.c.x,this.c.y),this.drawTo){case 0:this.drawLines(this.a,this.b,this.c);break;case 1:this.drawLines(this.c,this.a,this.b);break;case 2:this.drawLines(this.b,this.a,this.c)}stroke(BLUE),strokeJoin(BEVEL),strokeWeight(15),noFill(),triangle(this.a.x,this.a.y,this.b.x,this.b.y,this.c.x,this.c.y)},this.drawLines=function(i,t,e){for(var a=cos(frameCount/360*TWO_PI)/2,r=1;r<=this.n;r++){var n=createVector(lerp(i.x,t.x,(r-1)/this.n),lerp(i.y,t.y,(r-1)/this.n)),s=createVector(lerp(i.x,e.x,(r-1)/this.n),lerp(i.y,e.y,(r-1)/this.n)),h=createVector(lerp(i.x,e.x,(r-.5+a)/this.n),lerp(i.y,e.y,(r-.5+a)/this.n)),o=createVector(lerp(i.x,t.x,(r-.5+a)/this.n),lerp(i.y,t.y,(r-.5+a)/this.n));noStroke(),fill(BLUE),quad(n.x,n.y,s.x,s.y,h.x,h.y,o.x,o.y)}}}function draw(){background(RED),tris.forEach(i=>i.draw()),frameCount%720==0&&initializeTriangulation()}function mousePressed(){initializeTriangulation()}function windowResized(){resizeCanvas(windowWidth,windowHeight),initializeTriangulation()}
  </script>
  </body>
</html>
EOF

RES=$(az webapp up --location westeurope --name $APP)
xdg-open $(echo $RES | jq -r '.app_url')
#done!

#https://docs.microsoft.com/en-us/azure/app-service/deploy-local-git

# az login
# git clone https://github.com/Azure-Samples/nodejs-docs-hello-world.git
# cd nodejs-docs-hello-world
# npm i
# PASS=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-13};echo;)
# GROUP=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-13};echo;)
# APP=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-13};echo;)
# APPSRV=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-13};echo;)
# az webapp deployment user set --user-name namewithoutReference --password $PASS
# az group create -n $GROUP -l westeurope
# az webapp deployment source config-local-git 
# az appservice plan create --name $APPSRV --resource-group $GROUP --sku B1
# az webapp create --name $APP --resource-group $GROUP --plan $APPSRV --deployment-local-git
# az webapp config appsettings set --resource-group $GROUP --name $APP --settings WEBSITE_NODE_DEFAULT_VERSION=10.14.1
# git remote add azure ...
# git push azure master
# az webapp create helpg