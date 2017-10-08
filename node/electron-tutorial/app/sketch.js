function setup() {
  createCanvas(windowWidth, windowHeight);
  background(255);
}

var growth_direction = 1;
var low_rad = 200;
var high_rad = 300;
var rad = low_rad;

function draw() {
  if (mouseIsPressed) {
    fill(0);
  } else {
    fill(Math.floor(255 * Math.random()), Math.floor(255 * Math.random()), Math.floor(255 * Math.random()));
  }
  if ( rad <= low_rad || rad >= high_rad) {
    growth_direction *= -1;
  }
  rad += growth_direction;
  //ellipse(mouseX, mouseY, rad, rad);
  
  var x = windowWidth * Math.random();
  var y = windowHeight * Math.random();
  if ( !(Math.abs( x - mouseX ) < rad && Math.abs( y - mouseY ) < rad) ) {
    ellipse(x, y, rad, rad);
  }
}
