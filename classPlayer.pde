class Player {

  int [][] grid; //儲存球的類型資訊 0:空格, 1:紅, 2:黃, 3:綠, 4:藍, 5:爆破中
  int [][] state; //儲存球的狀態資訊 0:正常, 5:爆破中, 6:往上飄的球

  int rectSize; //一格的大小
  int gridW, gridH;
  int posX, posY; //玩家的位置
  int nBalls; //玩家持有的球數
  boolean gotBalls; //玩家是否持有球
  boolean isBall; //底部是否有球
  color c; //玩家球的顏色
  int bombTarget; //觸發消除的顏色
  int gotColor; //玩家持有球的顏色
  int buttColor; //底部球的顏色(拿球時使用)
  int butt; //底部空格(不包含5)的位置y(使用於line以及拿球)

  int combo=0;
  boolean bomb, stopCombo;
  int delay, delaytime; //combo計算的延遲時間
  boolean comboPlus; //有爆破引發的子爆破
  boolean endBomb, endBombchild; //爆破結束, 子爆破結束
  int bombCount, bombtime; //爆破的表演時間

  int lines; //被攻擊所要增加的行數
  boolean attacking;

  boolean ballDown, ballUp; //丟球拿球動畫的判斷
  int startY; //底部空格的y(丟球拿球時觸發)(就算左右移動也不會改變)
  int ballX, ballY; //丟球拿球動畫的位置

  int playerIndex;
  int bombN; //結束遊戲所需消去的目標數量

  Player(int playerIndex) {

    this.playerIndex=playerIndex;
    rectSize = 50;
    gridW = 7;
    gridH = 13;
    posX = 3;
    posY = gridH-1;
    startY=0;
    nBalls = 0;
    ballY = 0;
    delaytime=100;
    delay = delaytime;
    isBall=false;

    bombN=300;
    bombtime=15;
    bombCount=0;
    endBomb=true;
    endBombchild=true;
    comboPlus=false;
    gotBalls = false;
    bomb=false;
    ballDown = false;
    ballUp = false;
    stopCombo = false;
    lines = 0;
    attacking = false;


    grid = new int [gridW][gridH*2];
    state = new int [gridW][gridH*2];
    for (int i = 0; i < gridW; i++) {
      for (int j = 0; j < gridH*2; j++) {
        grid[i][j] = 0;
      }
    }
    for (int i = 0; i < gridW; i++) {
      for (int j = 0; j < gridH*2; j++) {
        state[i][j] = 0;
      }
    }
  }

  void drawPlayer(PImage imgPlayer) {
    image(imgPlayer, 0, 0);
    if (mode == 1) {
      getButt();
      drawLine();
      ballRun();
      //-----------------bomb的時間&bomb開始結束判定-------------------
      if (endBomb==false) {
        if (bombCount==0)bombCount=bombtime;
      }
      if (endBombchild==false) {
        if (bombCount==0)bombCount=bombtime;
      }

      if (bombCount>0) {
        bombCount-=1;
      } 
      if (bombCount==0) {
        endBomb=true;
        endBombchild=true;
      }

      if (endBomb==true&&endBombchild==true) {
        if (comboPlus==true||bomb==true)bombAndFly();
      }
      //---------------combo計算的delay,combo時播聲音一次--------------------
      if (!stopCombo) {
        if (delay==0) {
          stopCombo = true;
          combo=0;
        } else if (delay>0) {
          delay--;
        }
      } else {
        combo=0;
      }
      //------------------------畫出上面的球---------------
      for (int i = 0; i < gridW; i++) {
        for (int j = 0; j < gridH-1; j++) {

          if (grid[i][j] == 1) image(imgRedBall, i*rectSize, j*rectSize);
          else if (grid[i][j] == 2) image(imgYellowBall, i*rectSize, j*rectSize);
          else if (grid[i][j] == 3) image(imgGreenBall, i*rectSize, j*rectSize);
          else if (grid[i][j] == 4) image(imgBlueBall, i*rectSize, j*rectSize);
          else if (grid[i][j] == 5) {
            pushMatrix();
            if (frameCount%4 == 0) fill(255, 100, 0);
            else if (frameCount%3 == 1) fill(0, 255, 100);
            else fill(100, 0, 255);
            noStroke();
            ellipse((i+0.5)*rectSize, (j+0.5)*rectSize, rectSize, rectSize);
            popMatrix();
          }
          //if (state[i][j]==6) {
          //  fill(255, 0, 0, 100);
          //  ellipse((i+0.5)*rectSize, (j+0.5)*rectSize, rectSize, rectSize);
          //}
          //if (state[i][j]==5) {
          //  fill(0, 0, 255, 100);
          //  ellipse((i+0.5)*rectSize, (j+0.5)*rectSize, rectSize, rectSize);
          //}
        }
      }
      //--------------數空格 空格太多增加球-----------------

      int noBall = 0;
      if (frameCount % 20 == 0) {
        for (int i = 0; i < gridW; i++) {
          for (int j = 0; j < 12; j++) {
            if (grid[i][j] == 0) noBall++;
          }
        }
        if (noBall >= 56) addBalls();
      }

      //------------------自動加球-----------------
      if (frameCount % 480 == 460) {
        //addBalls();
      }

      //--------------------------------玩家球的顏色------------------------
      if (gotColor == 0) {
        c = color(255, 255, 255);
        image(imgEmpty, posX*rectSize, posY*rectSize);
      } else if (gotColor == 1) {
        c = color(255, 0, 0);
        image(imgRedBall, posX*rectSize, posY*rectSize);
      } else if (gotColor == 2) {
        c = color(255, 255, 0);
        image(imgYellowBall, posX*rectSize, posY*rectSize);
      } else if (gotColor == 3) {
        c = color(0, 255, 0);
        image(imgGreenBall, posX*rectSize, posY*rectSize);
      } else if (gotColor == 4) {
        c = color(0, 0, 255);
        image(imgBlueBall, posX*rectSize, posY*rectSize);
      }
      //----------------------------死線--------------------------------
      drawDeadLine();
      //--------------------------先消完目標數量的勝利----------------------
      if (bombN<=0) { 
        if (playerIndex==1) {
          println("player1 achieved the goal first!");
          println("player1 Win!");
          mode =211;
        } else if (playerIndex==2) {
          println("player2 achieved the goal first!");
          println("player2 Win!");
          mode = 212;
        }

        //exit();
      }
    }
  }

  //----------------------畫出數字----------------------
  void drawCombo(float posX, float posY) {
    if (combo>0)drawNum(combo, 2, posX, posY);
  }

  void drawPoint(float posX, float posY) {
    drawNum(bombN, 3, posX, posY);
  }

  void drawNum(int number, int digits, float posX, float posY) {
    int imgWidth = 40;
    int imgHeight = 60;

    pushMatrix();
    tint(255, 200);
    scale(1, 1);
    translate(posX, posY);
    for (int i = 0; i < digits; i++) {
      image(imgNum[floor(number/pow(10, i))%10], -imgWidth*i, 0, imgWidth, imgHeight);
    }
    popMatrix();
  }

  void keyPressed() {
    //---------------------player1--------------------------
    //-----------------------左右移動------------------------
    if (playerIndex==1) {
      if (key == 'a' && posX > 0) {
        if (gotBalls) {
          grid[posX-1][posY]=grid[posX][posY];
          grid[posX][posY]=0;
          posX--;
        } else {
          posX--;
        }
      } else if (key == 'd' && posX < gridW-1) {
        if (gotBalls) {
          grid[posX+1][posY]=grid[posX][posY];
          grid[posX][posY]=0;
          posX++;
        } else {
          posX++;
        }
      } 
      //---------------------上下拿球丟球---------------------

      else if (key=='s') { 
        soundBallUp.stop();
        findStartY();
        buttHasBall();//偵測底部的球是不是可以拿的球
        if (isBall) {//是可以拿的球才判斷是不是可以拿的顏色
          getButtColor(); 
          if (gotBalls == false) {//手上沒球
            takeBalls();
          } else {//手上有球,顏色相同才拿
            if (gotColor==buttColor) {
              takeBalls();
            } else ballDown=false;
          }
        } else ballDown=false;
      } else if (key =='w') {
        soundBallDown.stop();

        if (gotBalls) {//如果手上有球就丟
          findStartY();
          throwAndWait(nBalls);
          findStartY();//更新starty讓動畫正確
          ballX=posX;//丟球動畫的x會停留在丟球瞬間(不會跟著玩家移動)
        } else ballUp=false;
      }
    }

    //---------------------player2----------------------------------------
    //-----------------------左右移動------------------------
    else if (playerIndex==2) {
      if (keyCode == LEFT && posX > 0) {
        if (gotBalls) {
          grid[posX-1][posY]=grid[posX][posY];
          grid[posX][posY]=0;
          posX--;
        } else {
          posX--;
        }
      } else if (keyCode == RIGHT && posX < gridW-1) {
        if (gotBalls) {
          grid[posX+1][posY]=grid[posX][posY];
          grid[posX][posY]=0;
          posX++;
        } else {
          posX++;
        }
      } 
      //---------------------上下拿球丟球---------------------

      else if (keyCode ==DOWN) { 
        soundBallUp.stop();
        findStartY();
        buttHasBall();//偵測底部的球是不是可以拿的球
        if (isBall) {//是可以拿的球才判斷是不是可以拿的顏色
          getButtColor(); 
          if (gotBalls == false) {//手上沒球
            takeBalls();
          } else {//手上有球,顏色相同才拿
            if (gotColor==buttColor) {
              takeBalls();
            } else ballDown=false;
          }
        } else ballDown=false;
      } else if (keyCode ==UP) {
        soundBallDown.stop();

        if (gotBalls) {//如果手上有球就丟
          findStartY();
          throwAndWait(nBalls);
          findStartY();//更新starty讓動畫正確
          ballX=posX;//丟球動畫的x會停留在丟球瞬間(不會跟著玩家移動)
        } else ballUp=false;
      }
    }
  }

  //--------------------balldelay---------------
  void throwAndWait(int nBalls) {
    soundBallUp.stop();
    soundBallUp.play();
    ballUp = true;
    ballDown = false;

    for (int i=startY; i<startY+nBalls; i++) {
      grid[posX][i]=gotColor;
    } 

    detectThree();//偵測是否三個相連(是否觸發消除)
    if (bomb) {//有待爆球的情況
      combo();
      colorReadyBomb(posX, startY+this.nBalls-1);
      findSix();
      endBomb=false;
    } else if (endBomb==true) {
      for (int x=0; x<gridW; x++) {//死亡判定
        if (grid[x][posY]!=0&&grid[x][posY]!=5) {
          if (playerIndex==1) {
            println("player1 Suicide");
            println("player2 Win!");
            mode = 222;
          } else if (playerIndex==2) {
            println("player2 Suicide");
            println("player1 Win!");
            mode = 221;
          }
          //exit();
        }
      }
    }
    this.nBalls = 0;//丟完之後手上拿的球歸零
    gotBalls = false;
  }
  void bombAndFly() {

    bombBall();
    detectHole();//球往上飄
    comboPlus=false;
    for (int i = 0; i < gridW; i++) {
      for (int j = 0; j < gridH-1; j++) {//偵測往上飄的所有球
        if (state[i][j]==6) {
          detectThree(i, j);//偵測是否三個相連(是否觸發消除)
          if (bomb) {
            colorReadyBomb(i, j);
            comboPlus=true;
          }
        }
      }
    }
    if (comboPlus==false) {
      clearSix();
      endBombchild=true;
      bomb=false;
    }

    if (comboPlus) {//有待爆球的情況
      combo();
      findSix();
      endBombchild=false;
    }
  }
  //-----------------BallControls------------

  void getButtColor() {//獲得底部球的顏色(拿球時使用)
    buttColor = grid[posX][butt-1];
    if (!isBall)buttColor=0;
  }
  void buttHasBall() {//判斷底部是不是可拿的球(拿球時使用)
    if (butt-1>=0) {//butt-1:不是0也不是5的位置上方 
      isBall=true;
    } else {
      isBall=false;
    }
  }
  void getButt() {//不斷更新底部空格(不包含5)的位置(使用於line以及拿球)
    for (int j = gridH-2; j >= 0; j--) {
      if (grid[posX][j] != 0&&grid[posX][j] != 5) {
        butt = j+1;
        break;
      } else {
        butt =0;
      }
    }
  }
  void takeBalls() {
    soundBallDown.stop();
    soundBallDown.play();
    ballDown = true;
    ballUp = false;

    if (state[posX][butt-1]==6)state[posX][butt-1]=0;//拿還沒往上飄的球時把state歸零            
    gotColor = buttColor;//手上的球變成底部球的顏色
    ballY = startY;//讓動畫開始跑

    for (int j = gridH-2; j >= 0; j--) {//把吸掉的球清空
      if (grid[posX][j] == gotColor) {//計算顏色相同的球數
        nBalls++;       
        grid[posX][j] = 0;
      } else if (grid[posX][j]!=0&&grid[posX][j]!=5)break;//由下往上偵測顏色不與玩家相同就跳出迴圈
    }
    gotBalls = true;
  }

  void ballRun() {  //丟球拿球動畫(放在draw裡面)

    if (ballDown && ballY < posY) {//吸球時x看玩家的位置(動畫會跟玩家移動)
      ballY++;
      if (gotColor == 1) image(imgRedBall, posX*rectSize, ballY*rectSize);
      else if (gotColor == 2) image(imgYellowBall, posX*rectSize, ballY*rectSize);
      else if (gotColor == 3) image(imgGreenBall, posX*rectSize, ballY*rectSize);
      else if (gotColor == 4) image(imgBlueBall, posX*rectSize, ballY*rectSize);
    } else if (ballUp && ballY >= startY) {//丟球時x停留在丟球當下的位置(動畫不會跟玩家移動)
      if (ballY > startY) {
        ballY--;      
        if (gotColor == 1) image(imgRedBall, ballX*rectSize, ballY*rectSize);
        else if (gotColor == 2) image(imgYellowBall, ballX*rectSize, ballY*rectSize);
        else if (gotColor == 3) image(imgGreenBall, ballX*rectSize, ballY*rectSize);
        else if (gotColor == 4) image(imgBlueBall, ballX*rectSize, ballY*rectSize);
      } else gotColor=0;//動畫跑完下面的球才歸零(先歸零或用starty動畫都會消失)(使用starty因為不會略過5所以消除時不會有動畫)
    }
  }


  void detectHole() {//球上有空格就往上飄
    boolean hole=false;
    for (int x=0; x<gridW; x++) {

      for (int y=0; y<gridH-2; y++) {
        if (grid[x][y]==0&&grid[x][y+1]!=0) {//檢查是否有空格
          hole=true;
          fillHole(x, y);
          break;//跳出迴圈
        } else {
          hole=false;
        }
      }
      if (hole) {
        detectHole();
      }
    }
  }

  void fillHole(int x, int y) {
    for (int j=y; j<gridH-2; j++) {//往上移
      grid[x][j]=grid[x][j+1];
      state[x][j]=state[x][j+1];
      grid[x][j+1]=0;
      state[x][j+1]=0;
    }
  }

  void findStartY() {//找底部空格的y(丟球拿球時觸發)(就算左右移動也不會改變)

    for (int j = gridH-2; j >= 0; j--) {
      if (grid[posX][j] != 0) {
        startY = j+1;
        break;
      } else {
        startY =0;
      }
    }
  }

  void detectThree() {//偵測往上丟的球是否觸發引爆,且沒有引爆時會斷combo
    bomb=false;
    stopCombo = true;
    if (nBalls>=3) {
      bomb=true;
      stopCombo = false;
      return;
    } else if (nBalls==2) {
      if (startY>0) {
        if (grid[posX][startY-1]==grid[posX][startY]) {
          bomb=true;
          stopCombo = false;
          return;
        }
      }
    } else if (startY-1>0) {
      if (grid[posX][startY-2]==grid[posX][startY-1]&&grid[posX][startY-1]==grid[posX][startY]) {
        bomb=true;
        stopCombo = false;
        return;
      }
    }
  }


  void detectThree(int x, int y) {//偵測往上飄的球是否的觸發引爆
    if (grid[x][y]!=0) {
      bomb=false;
      if (y-1>=0) {
        if (grid[x][y-1]==grid[x][y]) {
          if (y-2>=0) {
            if (grid[x][y-2]==grid[x][y]) {
              bomb=true;
            }
          }
        }
      }
      if (y-1>=0) {
        if (grid[x][y-1]==grid[x][y]) {
          if (y+1<gridH-1) {
            if (grid[x][y+1]==grid[x][y]) {
              bomb=true;
            }
          }
        }
      }
      if (y+1<gridH-1) {
        if (grid[x][y+1]==grid[x][y]) {
          if (y+2<gridH-1) {
            if (grid[x][y+2]==grid[x][y]) {
              bomb=true;
            }
          }
        }
      }
    }
  }

  void colorReadyBomb(int x, int y) {//觸發周遭相同顏色的球變成5

    bombTarget=grid[x][y];
    subBomb(x, y);
  }

  void subBomb(int x, int y) {//
    state[x][y]=5;
    grid[x][y]=5;
    if (x>0) {
      if (grid[x-1][y]==bombTarget)subBomb(x-1, y);
    }
    if (x<gridW-1) {
      if (grid[x+1][y]==bombTarget)subBomb(x+1, y);
    }
    if (y>0) {
      if (grid[x][y-1]==bombTarget)subBomb(x, y-1);
    }
    if (y<gridH-2) {
      if (grid[x][y+1]==bombTarget)subBomb(x, y+1);
    }
  }
  void findSix() { //將正在爆破的球下方的球設為6=>等待往上飄的球
    for (int i=0; i<gridW; i++) {
      for (int j=0; j<gridH-1; j++) {
        if (state[i][j] == 5) {
          if (j+1<gridH-1) {
            if (state[i][j+1] != 5 && grid[i][j+1] != 0) state[i][j+1] = 6;
          }
        }
      }
    }
  }
  void bombBall() {
    for (int i=0; i<gridW; i++) {
      for (int j=0; j<gridH-1; j++) {
        if (state[i][j]==5) {
          bombN-=1;
          grid[i][j]=0;
          state[i][j]=0;
        }
      }
    }
  }
  void clearSix() {
    for (int i=0; i<gridW; i++) {
      for (int j=0; j<gridH-1; j++) {
        if (state[i][j] == 6) {
          state[i][j] =0;
        }
      }
    }
  }

  //-----------------------增加球-------------------------
  void addBalls() {
    soundAddBalls.stop();
    soundAddBalls.play();
    for (int i = 0; i < gridW; i++) {
      for (int j = gridH-2; j >= 0; j--) {
        grid[i][j+1] = grid[i][j];
        state[i][j+1]=state[i][j];
      }
      grid[i][0] = int(random(1, 5));
      state[i][0]=0;
    }
    for (int x=0; x<gridW; x++) {//死亡判定
      if (grid[x][posY]!=0&&grid[x][posY]!=5) {
        println("!!K.O!!");
        if (playerIndex==1) {
          println("player2 Win!");
          mode = 232;
        } else if (playerIndex==2) {
          println("player1 Win!");
          mode = 231;
        }
        //exit();
      }
    }
  }

  //---------------觸發combo------------------
  void combo() {
    stopCombo=false;
    combo+=1;
    delay = delaytime;
    comboSound();
  }
  //---------------攻擊加行-------------------
  void addLines() {
    if (lines < 8) lines++;
  }

  //---------------受到攻擊--------------------
  void attacked() {
    attacking = true;
    if (frameCount%20 == 0) {
      if (attacking) {
        if (lines > 0) {
          addBalls();
          lines--;
        } else attacking = false;
      }
    }
  }

  //----------------Deadline----------------------
  void drawDeadLine() {
    int flash = 1 ;
    //int deadButt=1;
    //for (int j = gridH-2; j >= 0; j--) {
    //  for (int i = 0; i <gridW; i++) {
    //    if (grid[i][j] != 0&&grid[i][j] != 5) {
    //      deadButt = j+1;
    //      break;
    //    } else {
    //      deadButt =0;
    //    }
    //  }
    //}
    //if (posY-deadButt<7 && posY-deadButt>=5) flash = 1;
    //else if (posY-deadButt<5 && posY-deadButt>=3) flash = 3;
    //else if (posY-deadButt<3 && posY-deadButt>=1) flash = 5;
    float a = sin(radians((frameCount%(360/flash))*flash))*127.5+127.5;
    pushMatrix();
    stroke(255, a, a);
    line(0*rectSize, (gridH-1)*rectSize, gridW*rectSize, (gridH-1)*rectSize);
    popMatrix();
  }
  //----------------line----------------------
  void drawLine() {
    strokeWeight(3);
    int v =frameCount%10;
    for (int i = posY; i > butt; i--) {
      for (int j = 0; j < 50; j+=10)
        if (gotBalls) {
          stroke(c);
          point((posX+0.5)*rectSize, i*rectSize-j-v);
        } else {
          stroke(c);
          point((posX+0.5)*rectSize, i*rectSize-j+v);
        }
    }
  }
  //----------------------sound----------------------
  void comboSound() {
    if (playerIndex==1) {
      for (int i = 0; i < 9; i++) {
        soundComboL[i].stop();
        if (combo == i+1) soundComboL[i].play();
      }
      if (combo > 9) soundComboL[8].play();
    }
    if (playerIndex==2) {
      for (int i = 0; i < 9; i++) {
        soundComboR[i].stop();
        if (combo == i+1) soundComboR[i].play();
      }
      if (combo > 9) soundComboR[8].play();
    }
  }
}
