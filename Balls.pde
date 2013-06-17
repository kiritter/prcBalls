int NUM_BALLS = 15;
Ball[] balls = new Ball[NUM_BALLS];
float SPRING = 50;
float REDUCTION = 0.995;
boolean recording = false;

//--------------------------------------------------
void setup(){
  initWindow();
  initBalls();
}
void initWindow() {
  size(640, 480);
  smooth();
  frameRate(30);
}
void initBalls() {
  for (int i = 0; i < NUM_BALLS; i++) {
    createBall(i);
  }
}
void createBall(int i){
  float x = random(50, width);
  float y = random(50, height);
  float r = random(10, 20);
  float sx = random(-10, 10);
  float sy = random(-10, 10);
  color c = color(random(0, 255), random(0, 255), random(0, 255), random(64, 128));
  balls[i] = new Ball(i, x, y, r, sx, sy, c, balls);
}

//--------------------------------------------------
void draw(){
  background(255);
  noStroke();
  for (int i = 0; i < NUM_BALLS; i++) {
    balls[i].display();
    balls[i].move();
    balls[i].bound();
    balls[i].collide();
  }

  if (recording == true) {
    saveFrame("output/frame-####.png");
  }
}
void keyPressed() {
  if (key == 'r') {
    recording = (!recording);
  }
}

//--------------------------------------------------
class Ball{
  int id;
  float posx, posy;
  float radi;
  float speedx, speedy;
  color clr;
  float mass;
  Ball[] balls;

  boolean bufFlg;
  int frameNum;
  boolean scaleFlg;

  Ball(int i, float x, float y, float r, float sx, float sy, color c, Ball[] b) {
    id = i;
    posx = x;
    posy = y;
    radi = r;
    speedx = sx;
    speedy = sy;
    clr = c;
    mass = radi * radi;
    balls = b;

    bufFlg = false;
    frameNum = 0;
    scaleFlg = false;
  }

  void move() {
    speedx *= REDUCTION;
    speedy *= REDUCTION;
    posx += speedx;
    posy += speedy;
  }

  void bound() {
    if (posx + radi >= width) {
      speedx = -speedx;
      posx = width - radi;
    }
    if (posx - radi <= 0) {
      speedx = -speedx;
      posx = radi;
    }
    if (posy + radi >= height) {
      speedy = -speedy;
      posy = height - radi;
    }
    if (posy - radi <= 0) {
      speedy = -speedy;
      posy = radi;
    }
  }

  void collide() {
    for (int i = id + 1; i < NUM_BALLS; i++) {
      float dx = balls[i].posx - posx;
      float dy = balls[i].posy - posy;
      float distance = sqrt(dx*dx + dy*dy);
      float critical = balls[i].radi + radi;

      if (distance < critical) {
        float force = SPRING * (critical - distance);
        float theta = atan2(dy, dx);
        float ax = -force * cos(theta) / mass;
        float ay = -force * sin(theta) / mass;
        speedx += ax;
        speedy += ay;
        ax = force * cos(theta) / balls[i].mass;
        ay = force * sin(theta) / balls[i].mass;
        balls[i].speedx += ax;
        balls[i].speedy += ay;

        if (bufFlg == false) {
          bufFlg = true;
          switchScale();
          balls[i].switchScale();
        }
      }
    }
  }

  void switchScale() {
    if (scaleFlg == false) {
      radi = radi * 2;
      scaleFlg = true;
    }else{
      radi = radi / 2;
      scaleFlg = false;
    }
  }

  void display() {
    fill(clr);
    ellipse(posx, posy, radi*2, radi*2);

    if (bufFlg == true) {
      frameNum += 1;
    }
    if (frameNum >= 30) {
      bufFlg = false;
      frameNum = 0;
    }
  }
}


