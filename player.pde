class player {

  int [][] grid;
  int [][] state;
  int lines, flash;
  int gridW, gridH, posX, posY, nBalls, samei, starty, buttColor, gotColor, butt, deadButt, ballY, rectSize, noBall;
  boolean gotBalls, bomb, ballDown, ballUp, isBall, delayStart, stopCombo;
  int combo=0;
  int v, delay, delaytime;
  color c;
  boolean comboPlus;
  boolean attacking;

  boolean endBomb, endBombchild;
  int bombCount, bombtime;

  int ballX;
  int playerIndex;
  int bombN;

  player(int _playerIndex) {

    playerIndex=_playerIndex;
    rectSize = 50;
    gridW = 7;
    gridH = 13;
    posX = 3;
    posY = gridH-1;
    starty=0;
    nBalls = 0;
    ballY = 0;
    noBall = 0;
    v = 0;
    flash = 1;
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
    deadButt = 1;
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

  void drawPlayer(PImage _BGimg) {
    image(_BGimg, 0, 0);
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
        if (comboPlus==true||bomb==true)BombAndFly();
      }
      //---------------combo計算的delay,combo時播聲音一次--------------------

      if (delayStart) {
        if (delay == 0) {
          stopCombo = true;
          delayStart = false;
        } else {
          if (delay == delaytime)comboSound();
          delay--;
        }
      }
      if (stopCombo) {
        combo=0;
        delayStart = false;
      }

      //------------------------畫出上面的球---------------
      for (int i = 0; i < gridW; i++) {
        for (int j = 0; j < gridH-1; j++) {

          if (grid[i][j] == 1) image(red, i*rectSize, j*rectSize);
          else if (grid[i][j] == 2) image(yellow, i*rectSize, j*rectSize);
          else if (grid[i][j] == 3) image(green, i*rectSize, j*rectSize);
          else if (grid[i][j] == 4) image(blue, i*rectSize, j*rectSize);
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

      noBall = 0;
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
        image(empty, posX*rectSize, posY*rectSize);
      } else if (gotColor == 1) {
        c = color(255, 0, 0);
        image(red, posX*rectSize, posY*rectSize);
      } else if (gotColor == 2) {
        c = color(255, 255, 0);
        image(yellow, posX*rectSize, posY*rectSize);
      } else if (gotColor == 3) {
        c = color(0, 255, 0);
        image(green, posX*rectSize, posY*rectSize);
      } else if (gotColor == 4) {
        c = color(0, 0, 255);
        image(blue, posX*rectSize, posY*rectSize);
      }
      //----------------------------死線--------------------------------
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
      //println(a);
      pushMatrix();
      stroke(255, a, a);
      line(0*rectSize, (gridH-1)*rectSize, gridW*rectSize, (gridH-1)*rectSize);
      popMatrix();
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
        up.stop();
        findstarty();
        buttisBall();//偵測底部的球是不是可以拿的球
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
        down.stop();

        if (gotBalls) {//如果手上有球就丟
          findstarty();
          ThrowAndWait(nBalls);
          findstarty();//更新starty讓動畫正確
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
        up.stop();
        findstarty();
        buttisBall();//偵測底部的球是不是可以拿的球
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
        down.stop();

        if (gotBalls) {//如果手上有球就丟
          findstarty();
          ThrowAndWait(nBalls);
          findstarty();//更新starty讓動畫正確
          ballX=posX;//丟球動畫的x會停留在丟球瞬間(不會跟著玩家移動)
        } else ballUp=false;
      }
    }
  }

  //--------------------balldelay---------------
  void ThrowAndWait(int _nBalls) {
    up.stop();
    up.play();
    ballUp = true;
    ballDown = false;

    for (int i=starty; i<starty+_nBalls; i++) {
      grid[posX][i]=gotColor;
    } 

    detectThree();//偵測是否三個相連(是否觸發消除)
    if (bomb) {//有待爆球的情況
      combo+=1;
      colorReadyBomb(posX, starty+nBalls-1);
      findSix();
      endBomb=false;
      delayStart = true;
      delay = delaytime;
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
    nBalls = 0;//丟完之後手上拿的球歸零
    gotBalls = false;
  }
  void BombAndFly() {

    BombBall();
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
      combo+=1;
      findSix();
      endBombchild=false;
      delayStart = true;
      delay = delaytime;
    }
  }
  //-----------------BallControls------------

  void getButtColor() {//獲得底部球的顏色(拿球時使用)
    buttColor = grid[posX][butt-1];
    if (!isBall)buttColor=0;
  }
  void buttisBall() {//判斷底部是不是可拿的球(拿球時使用)
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
    down.stop();
    down.play();
    ballDown = true;
    ballUp = false;

    if (state[posX][butt-1]==6)state[posX][butt-1]=0;//拿還沒往上飄的球時把state歸零            
    gotColor = buttColor;//手上的球變成底部球的顏色
    ballY = starty;//讓動畫開始跑

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
      if (gotColor == 1) image(red, posX*rectSize, ballY*rectSize);
      else if (gotColor == 2) image(yellow, posX*rectSize, ballY*rectSize);
      else if (gotColor == 3) image(green, posX*rectSize, ballY*rectSize);
      else if (gotColor == 4) image(blue, posX*rectSize, ballY*rectSize);
    } else if (ballUp && ballY >= starty) {//丟球時x停留在丟球當下的位置(動畫不會跟玩家移動)
      if (ballY > starty) {
        ballY--;      
        if (gotColor == 1) image(red, ballX*rectSize, ballY*rectSize);
        else if (gotColor == 2) image(yellow, ballX*rectSize, ballY*rectSize);
        else if (gotColor == 3) image(green, ballX*rectSize, ballY*rectSize);
        else if (gotColor == 4) image(blue, ballX*rectSize, ballY*rectSize);
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

  void fillHole(int _x, int _y) {
    for (int j=_y; j<gridH-2; j++) {//往上移
      grid[_x][j]=grid[_x][j+1];
      state[_x][j]=state[_x][j+1];
      grid[_x][j+1]=0;
      state[_x][j+1]=0;
    }
  }

  void findstarty() {//找底部空格的y(丟球拿球時觸發)(就算左右移動也不會改變)

    for (int j = gridH-2; j >= 0; j--) {
      if (grid[posX][j] != 0) {
        starty = j+1;
        break;
      } else {
        starty =0;
      }
    }
  }

  void detectThree() {//偵測往上丟的球是否觸發引爆,且沒有引爆時會斷combo
    bomb=false;
    stopCombo = true;
    if (starty+nBalls-2>=0) {
      if (grid[posX][starty+nBalls-2]==grid[posX][starty+nBalls-1]) {
        if (starty+nBalls-3>=0) {
          if (grid[posX][starty+nBalls-3]==grid[posX][starty+nBalls-1]) {
            bomb=true;
            stopCombo = false;
          }
        }
      }
    }
  }


  void detectThree(int _x, int _y) {//偵測往上飄的球是否的觸發引爆
    if (grid[_x][_y]!=0) {
      bomb=false;
      if (_y-1>=0) {
        if (grid[_x][_y-1]==grid[_x][_y]) {
          if (_y-2>=0) {
            if (grid[_x][_y-2]==grid[_x][_y]) {
              bomb=true;
            }
          }
        }
      }
      if (_y-1>=0) {
        if (grid[_x][_y-1]==grid[_x][_y]) {
          if (_y+1<gridH-1) {
            if (grid[_x][_y+1]==grid[_x][_y]) {
              bomb=true;
            }
          }
        }
      }
      if (_y+1<gridH-1) {
        if (grid[_x][_y+1]==grid[_x][_y]) {
          if (_y+2<gridH-1) {
            if (grid[_x][_y+2]==grid[_x][_y]) {
              bomb=true;
            }
          }
        }
      }
    }
  }

  void colorReadyBomb(int _x, int _y) {//觸發周遭相同顏色的球變成5

    samei=grid[_x][_y];
    subBomb(_x, _y);
  }

  void subBomb(int _x, int _y) {//
    state[_x][_y]=5;
    grid[_x][_y]=5;
    if (_x>0) {
      if (grid[_x-1][_y]==samei)subBomb(_x-1, _y);
    }
    if (_x<gridW-1) {
      if (grid[_x+1][_y]==samei)subBomb(_x+1, _y);
    }
    if (_y>0) {
      if (grid[_x][_y-1]==samei)subBomb(_x, _y-1);
    }
    if (_y<gridH-2) {
      if (grid[_x][_y+1]==samei)subBomb(_x, _y+1);
    }
  }
  void findSix() {
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
  void BombBall() {
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
    addballs.stop();
    addballs.play();
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

  //----------------line----------------------
  void drawLine() {
    strokeWeight(3);
    if (v < 10) v++;
    else v = 0;
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
        comboL[i].stop();
        if (combo == i+1) comboL[i].play();
      }
      if (combo > 9) comboL[8].play();
    }
    if (playerIndex==2) {
      for (int i = 0; i < 9; i++) {
        comboR[i].stop();
        if (combo == i+1) comboR[i].play();
      }
      if (combo > 9) comboR[8].play();
    }
  }
}