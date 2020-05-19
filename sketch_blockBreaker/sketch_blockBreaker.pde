void settings() {
  size(600, 400);
}

int xpos, ypos;    // ball position
int xdir, ydir;    // ball direction
int batx;          // bar xPosition
int[][] bricks = new int[40][10];    // Max bricks size (40 x 10)
int brickRow;      // current brickRow
int batSize;       // bar length
color[] colors = {#F60000, #FF8C00, #FFEE00, #4DE94C, #3783FF, #000080, #7035A1};    // rainbow colors
int score = 0;
long start, runtime = 0L;
boolean play = false;    // check playing game
String mainBanner, subBanner = "";
boolean auto = false;

void setup() {
  // initialize position, speed, brickRow, banner at the start of each game
  xpos = int(random(100, width-100));
  ypos = height -62;
  xdir = -5;
  ydir = -5;
  batx = xpos;
  brickRow = 2;  
  batSize = 200;
  mainBanner = start<500 ? "GAME START" : "GAME OVER";
  subBanner = "click mouse";
  
  // setting bricks as much as brickRow
  for(int i=0; i<bricks.length; i++)
    for(int j=0; j<bricks[i].length; j++)
      bricks[i][j] = i<brickRow ? 1 : 0;
}

void draw() {
  background(0); noStroke();
  
  // score board
  fill(170); rect(0, 0, width, 29);
  fill(0); textSize(12); textAlign(LEFT, CENTER); text("Block Breaker", 10, 0, width, 30);
  fill(0); textSize(12); textAlign(CENTER, CENTER); text(String.format("%02d:%02d:%02d", runtime/1000/60/60, (runtime/1000/60)%60, (runtime/1000)%60), 0, 0, width, 30);
  fill(0); textSize(12); textAlign(RIGHT, CENTER); text(String.valueOf(score), -10, 0, width, 30);
  // center banner
  fill(255); textSize(26); textAlign(CENTER, CENTER); text(mainBanner, 0, 0, width, height);
  fill(200); textSize(14); textAlign(CENTER, CENTER); text(subBanner, 0, 25, width, height);

  // drawing a ball
  fill(255); ellipse(xpos, ypos, 20, 20);
  int radius = 20 / 2;  // radius of the ball
  
  // drawing a pad
  strokeWeight(2); stroke(255); line(batx-(batSize/2), height-50, batx+(batSize/2), height-50);

  // drawing bricks
  for(int i=0; i<brickRow; i++){
    fill(colors[(brickRow-i-1)%7]); noStroke();
    for(int j=0; j<10; j++){
      if(bricks[i][j] == 1) rect(j*60+0.25, i*20 + 30, 59.5, 20);
    }
  }
  
  // playing game
  if(play) {
    runtime = millis() - start;
    
    // moving pad
    batx = auto?xpos:mouseX;
    
    // moving ball
    xpos += xdir;
    ypos += ydir;
    
    // bouncing ball
    if(xpos <= radius || xpos >= width-radius){    // sides of the field
      xdir *= -1;
    }else{
      if(bricks[(ypos-30)/20][(xpos-radius)/60] == 1){    // brick left collision
        xdir *= -1;
        bricks[(ypos-30)/20][(xpos-radius)/60] = 0;
        score += 10;
      }else if(bricks[(ypos-30)/20][(xpos+radius)/60] == 1){    // brick right collision
        xdir *= -1;
        bricks[(ypos-30)/20][(xpos+radius)/60] = 0;
        score += 10;
      }
    }
    if(ypos < 40){    // above the score board
      ydir *= -1;
    }else{
      if(bricks[(ypos-30-radius)/20][(xpos)/60] == 1){    // brick bottom collision
        ydir *= -1;
        bricks[(ypos-30-radius)/20][(xpos)/60] = 0;
        score += 10;
      }else if(bricks[(ypos-30+radius)/20][(xpos)/60] == 1){    // brick top collision
        ydir *= -1;
        bricks[(ypos-30+radius)/20][(xpos)/60] = 0;
        score += 10;
      }
    }
    
    // bounce at the pad
    if(ypos > height-62 && ypos < height-52 && xpos >= batx-(batSize/2) && xpos <= batx+(batSize/2)){
      ydir *= -1;
    }
    
    // add brick row every 5sec
    if(brickRow-1 <= runtime/5000){
      brickRow++;
      for(int i=brickRow-1; i>=0; i--){
        for(int j=0; j<10; j++){
          bricks[i][j] = i==0?1:bricks[i-1][j];
        }
      }
    }
    
    // ball spped up every 150score (max = 9)
    if(abs(xdir)<10 && abs(xdir)-4<=score/150){
      xdir += xdir > 0 ? 1 : -1;
      ydir += ydir > 0 ? 1 : -1;
    }
    
    // 60sec later -> decrease batSize (200 -> 120)
    if(runtime >= 58000){
      if(runtime < 60000){
        mainBanner = "WARNING";
      }else{
        batSize = 120;
        mainBanner = "";
      }
    }
    
    // game over
    if(ypos > height+(radius*2)){
      play = false;
      setup();
    }
  }
}

void mouseClicked() {
  // game start
  if(!play){
    play = true;
    start = millis();
    score = 0;
  }
  mainBanner = ""; subBanner = "";
}

void keyPressed(){
  // play auto
  if(key == 'A' || key == 'a'){
    auto = auto ? false : true;
  }
}
