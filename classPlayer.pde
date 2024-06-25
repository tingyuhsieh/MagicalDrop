final int RECT_SIZE = 50; //一格的大小 //<>//
final int COL_NUM = 7; //行數
final int ROW_NUM = 13; //列數
final int BALL_COL_NUM_INIT = 5; //遊戲開始時的球池列數
final int BOMBING_DURATION = 250; //爆破的表演時間(毫秒)
final int COMBO_VAILD_DURATION = 1666; //combo計算的有效期間(毫秒)
final int QUICK_ATTACK_COMBO_THRESHOLD = 9; //高速攻擊的combo臨界值
final int ADD_BALL_INTERVAL = 333; //加球的間隔時間(毫秒)
final int AUTO_ADD_BALL_THRESHOLD = 8000; //自動加球的時間臨界值(毫秒)，0則關閉該功能

enum GameResult {
  DEUCE, //平手
    WIN, //勝者
    LOSE //敗者
}

class Player {

  int [][] grid; //儲存球的類型資訊 0:空格, 1:紅, 2:黃, 3:綠, 4:藍, 5:爆破中
  int [][] state; //儲存球的狀態資訊 0:正常, 5:爆破中, 6:往上飄的球

  int deadlinePos; //出局的界線，在該位置或超出界線的球則玩家被判出局
  int posX, posY; //玩家的位置
  int nBalls; //玩家持有的球數
  color refLineColor; //參考線的顏色
  int gotColor; //玩家持有球的顏色
  int butt; //底部空格(不包含5)的位置y(使用於line以及拿球)

  int combo;
  int bombStartTime;
  boolean isBombing; //正在表演爆破的動畫

  int lastAddBallTime;
  int rowsWaitingToAdd; //等待加的行數

  boolean ballDown, ballUp; //丟球拿球動畫的判斷
  int startY; //底部空格的y(丟球拿球時觸發)(就算左右移動也不會改變)
  int ballX, ballY; //丟球拿球動畫的位置

  String playerName;
  int bombTargetNum; //結束遊戲所需消去的目標數量
  int bombingNum; //爆破中的數量

  Player opponent; //攻擊的玩家

  PlayerStatus status;
  GameResult gameResult; //遊戲結果

  SoundFile[] soundCombo;

  Player(String playerName, int deadlinePos, int bombTargetNum, SoundFile[] soundCombo) {

    this.playerName = playerName;
    this.deadlinePos = deadlinePos >= ROW_NUM ? (ROW_NUM - 1) : deadlinePos;
    this.bombTargetNum = bombTargetNum;
    this.soundCombo = soundCombo;

    posX = COL_NUM/2;
    posY = ROW_NUM-1;
    startY=0;
    nBalls = 0;
    ballY = 0;
    bombStartTime = 0;

    isBombing = false;
    combo = 0;
    ballDown = false;
    ballUp = false;
    lastAddBallTime = 0;
    rowsWaitingToAdd = 0;


    grid = new int [COL_NUM][ROW_NUM];
    state = new int [COL_NUM][ROW_NUM];
    for (int i = 0; i < COL_NUM; i++) {
      for (int j = 0; j < ROW_NUM; j++) {
        grid[i][j] = 0;
      }
    }
    for (int i = 0; i < COL_NUM; i++) {
      for (int j = 0; j < ROW_NUM; j++) {
        state[i][j] = 0;
      }
    }

    status = PlayerStatus.ACTIVE;
    gameResult = GameResult.DEUCE;
  }

  void setOpponentPlayer(Player opponent) {
    this.opponent = opponent;
  }

  void drawPlayer(PImage imgPlayer) {
    image(imgPlayer, 0, 0);
    if (gameState == GameState.GAMING) {
      getButt();
      drawRefLine();
      ballRun();
      //--------------------------bomb結束判定---------------------------
      if (isBombing) {
        if (millis() - bombStartTime > BOMBING_DURATION) { //bomb結束
          isBombing = false;
          if (bombingNum >= 3)bombAndFly(); //有待爆球時將球消除並向上填補空位
        }
      }
      //---------------檢查combo計算的有效時間,超過時結束combo------------------
      if (combo > 0 && millis() - bombStartTime > COMBO_VAILD_DURATION) {
        stopCombo();
      }
      //------------------------畫出上面的球---------------
      for (int i = 0; i < COL_NUM; i++) {
        for (int j = 0; j < ROW_NUM; j++) {

          if (grid[i][j] == 1) image(imgRedBall, i*RECT_SIZE, j*RECT_SIZE);
          else if (grid[i][j] == 2) image(imgYellowBall, i*RECT_SIZE, j*RECT_SIZE);
          else if (grid[i][j] == 3) image(imgGreenBall, i*RECT_SIZE, j*RECT_SIZE);
          else if (grid[i][j] == 4) image(imgBlueBall, i*RECT_SIZE, j*RECT_SIZE);
          else if (grid[i][j] == 5) {
            pushMatrix();
            if (frameCount%4 == 0) fill(255, 100, 0);
            else if (frameCount%3 == 1) fill(0, 255, 100);
            else fill(100, 0, 255);
            noStroke();
            ellipse((i+0.5)*RECT_SIZE, (j+0.5)*RECT_SIZE, RECT_SIZE, RECT_SIZE);
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
      //-------------檢查是否需加球------------------
      checkAddBalls();
      //--------------------------------玩家球的顏色------------------------
      if (gotColor == 0) {
        refLineColor = color(255, 255, 255);
        image(imgEmpty, posX*RECT_SIZE, posY*RECT_SIZE);
      } else if (gotColor == 1) {
        refLineColor = color(255, 0, 0);
        image(imgRedBall, posX*RECT_SIZE, posY*RECT_SIZE);
      } else if (gotColor == 2) {
        refLineColor = color(255, 255, 0);
        image(imgYellowBall, posX*RECT_SIZE, posY*RECT_SIZE);
      } else if (gotColor == 3) {
        refLineColor = color(0, 255, 0);
        image(imgGreenBall, posX*RECT_SIZE, posY*RECT_SIZE);
      } else if (gotColor == 4) {
        refLineColor = color(0, 0, 255);
        image(imgBlueBall, posX*RECT_SIZE, posY*RECT_SIZE);
      }
      //----------------------------死線--------------------------------
      drawDeadLine();
    } else if (gameState == GameState.GAME_OVER) {
      switch(gameResult) {
      case WIN:
        image(imgWin, 0, 450);
        break;
      case LOSE:
        image(imgLose, 0, 450);
        break;
      default:
        break;
      }
    }
  }

  void keyPressed(int leftKeyCode, int rightKeyCode, int upKeyCode, int downKeyCode) { 
    //-----------------------左右移動------------------------
    if (keyCode == leftKeyCode && posX > 0) {
      posX--;
    } else if (keyCode == rightKeyCode && posX < COL_NUM-1) {
      posX++;
    } 
    //---------------------上下拿球丟球---------------------
    else if (keyCode == upKeyCode) { 
      soundBallDown.stop();

      if (nBalls > 0) {//如果手上有球就丟
        findStartY();
        throwAndWait(nBalls);
        findStartY();//更新starty讓動畫正確
        ballX=posX;//丟球動畫的x會停留在丟球瞬間(不會跟著玩家移動)
      }
    } else if (keyCode == downKeyCode) {
      soundBallUp.stop();
      findStartY();

      if (butt-1>=0) { //檢查底部的球是不是可以拿的球
        int buttColor = grid[posX][butt-1];
        if (gotColor ==0 || gotColor==buttColor) { //是可以拿的球才判斷是不是可以拿的顏色
          takeBalls(buttColor);
        }
      }
    }
  }

  //--------------------balldelay---------------
  void throwAndWait(int nBalls) {
    soundBallUp.stop();
    soundBallUp.play();
    ballUp = true;
    ballDown = false;


    for (int i=startY; i<startY+nBalls&&i<ROW_NUM; i++) {
      grid[posX][i]=gotColor;
    } 

    if (checkBomb())//偵測是否三個相連(是否觸發消除)
    {
      startBomb();

      if (startY+this.nBalls-1>ROW_NUM-1)
      {
        bombingNum+=startY+this.nBalls-1-(ROW_NUM-1);
        colorReadyBomb(posX, ROW_NUM-1);
      } else 
      {
        colorReadyBomb(posX, startY+this.nBalls-1);
      }
    } else //沒有觸發消除時會斷combo
    {
      if (combo > 0) stopCombo();

      for (int x=0; x<COL_NUM; x++) {//死亡判定
        if (grid[x][deadlinePos]!=0&&grid[x][deadlinePos]!=5) {
          status = PlayerStatus.DEAD_BY_MISPLAY;
          break;
        }
      }
    }
    this.nBalls = 0;//丟完之後手上拿的球歸零
  }
  void bombAndFly() {
    findTriggerBalls();
    bombBall();
    detectHole();//球往上飄
    boolean comboPlus = false; //有爆破引發的子爆破
    for (int i = 0; i < COL_NUM; i++) {
      for (int j = 0; j < deadlinePos; j++) {//偵測往上飄的所有球
        if (state[i][j]==6) {
          if (checkTriggerBomb(i, j)) {//偵測是否三個相連(是否觸發消除)
            colorReadyBomb(i, j);
            comboPlus=true;
          }
          state[i][j] = 0;
        }
      }
    }

    if (comboPlus) {//有待爆球的情況
      startBomb();
    }
  }
  //-----------------BallControls------------
  void getButt() {//不斷更新底部空格(不包含5)的位置(使用於line以及拿球)
    for (int j = ROW_NUM-2; j >= 0; j--) {
      if (grid[posX][j] != 0&&grid[posX][j] != 5) {
        butt = j+1;
        break;
      } else {
        butt =0;
      }
    }
  }
  void takeBalls(int buttColor) {
    soundBallDown.stop();
    soundBallDown.play();
    ballDown = true;
    ballUp = false;

    gotColor = buttColor;//手上的球變成底部球的顏色
    ballY = startY;//讓動畫開始跑

    for (int j = deadlinePos-1; j >= 0; j--) {//把吸掉的球清空
      if (grid[posX][j] == gotColor) {//計算顏色相同的球數
        nBalls++;       
        grid[posX][j] = 0;
      } else if (grid[posX][j]!=0&&grid[posX][j]!=5)break;//由下往上偵測顏色不與玩家相同就跳出迴圈
    }
  }

  void ballRun() {  //丟球拿球動畫(放在draw裡面)

    if (ballDown && ballY < posY) {//吸球時x看玩家的位置(動畫會跟玩家移動)
      ballY++;
      if (gotColor == 1) image(imgRedBall, posX*RECT_SIZE, ballY*RECT_SIZE);
      else if (gotColor == 2) image(imgYellowBall, posX*RECT_SIZE, ballY*RECT_SIZE);
      else if (gotColor == 3) image(imgGreenBall, posX*RECT_SIZE, ballY*RECT_SIZE);
      else if (gotColor == 4) image(imgBlueBall, posX*RECT_SIZE, ballY*RECT_SIZE);
    } else if (ballUp && ballY >= startY) {//丟球時x停留在丟球當下的位置(動畫不會跟玩家移動)
      if (ballY > startY) {
        ballY--;      
        if (gotColor == 1) image(imgRedBall, ballX*RECT_SIZE, ballY*RECT_SIZE);
        else if (gotColor == 2) image(imgYellowBall, ballX*RECT_SIZE, ballY*RECT_SIZE);
        else if (gotColor == 3) image(imgGreenBall, ballX*RECT_SIZE, ballY*RECT_SIZE);
        else if (gotColor == 4) image(imgBlueBall, ballX*RECT_SIZE, ballY*RECT_SIZE);
      } else gotColor=0;//動畫跑完下面的球才歸零(先歸零或用starty動畫都會消失)(使用starty因為不會略過5所以消除時不會有動畫)
    }
  }


  void detectHole() {//球上有空格就往上飄
    boolean hole=false;
    for (int x=0; x<COL_NUM; x++) {

      for (int y=0; y<deadlinePos-1; y++) {
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
    for (int j=y; j<deadlinePos-1; j++) {//往上移
      grid[x][j]=grid[x][j+1];
      state[x][j]=state[x][j+1];
      grid[x][j+1]=0;
      state[x][j+1]=0;
    }
  }

  void findStartY() {//找底部空格的y(丟球拿球時觸發)(就算左右移動也不會改變)

    for (int j = ROW_NUM-2; j >= 0; j--) {
      if (grid[posX][j] != 0) {
        startY = j+1;
        break;
      } else {
        startY =0;
      }
    }
  }

  boolean checkBomb() {//偵測往上丟的球是否觸發引爆

    if (nBalls>=3) {
      return true;
    } 

    if (nBalls==2) {
      if (startY>0) {
        if (grid[posX][startY-1]==grid[posX][startY]) {
          return true;
        }
      }
    } 

    if (startY-1>0) {
      if (grid[posX][startY-2]==grid[posX][startY-1]&&grid[posX][startY-1]==grid[posX][startY]) {
        return true;
      }
    }

    //未觸發引爆
    return false;
  }


  boolean checkTriggerBomb(int x, int y) {//偵測往上飄的球是否的觸發引爆
    if (grid[x][y] == 0 || grid[x][y] == 5)
      return false;

    //triggerBall必須與下方的球相同顏色才能觸發引爆
    if (y+1<deadlinePos) {
      if (grid[x][y+1]==grid[x][y]) {
        if (y+2<deadlinePos) {
          if (grid[x][y+2]==grid[x][y]) {
            return true;
          }
          if (y-1>=0) {
            if (grid[x][y-1]==grid[x][y]) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void colorReadyBomb(int x, int y) {//觸發周遭相同顏色的球變成5
    subBomb(grid[x][y], x, y);
  }

  void subBomb(int ballColor, int x, int y) {
    state[x][y]=5;
    grid[x][y]=5;
    bombingNum+=1;
    if (x>0) {
      if (grid[x-1][y]==ballColor)subBomb(ballColor, x-1, y);
    }
    if (x<COL_NUM-1) {
      if (grid[x+1][y]==ballColor)subBomb(ballColor, x+1, y);
    }
    if (y>0) {
      if (grid[x][y-1]==ballColor)subBomb(ballColor, x, y-1);
    }
    if (y<ROW_NUM-1) {
      if (grid[x][y+1]==ballColor)subBomb(ballColor, x, y+1);
    }
  }
  void findTriggerBalls() { //將正在爆破的球上方的球設為6=>可以觸發子爆炸的球
    for (int i=0; i<COL_NUM; i++) {
      for (int j=deadlinePos; j>=1; j--) {
        if (grid[i][j] == 5) {
          if (grid[i][j-1] != 5 && grid[i][j-1] != 0) {
            state[i][j-1] = 6;
            j-=1; //下一次檢查跳過設為6的球
          }
        }
      }
    }
  }
  void bombBall() {
    for (int i=0; i<COL_NUM; i++) {
      for (int j=0; j<ROW_NUM; j++) {
        if (grid[i][j]==5) {
          grid[i][j]=0;
          state[i][j]=0;
        }
      }
    }
    bombTargetNum-=bombingNum;
    bombingNum=0;
  }

  //-----------------------增加球-------------------------  
  void checkAddBalls() {

    // 維持最低球數
    if (rowsWaitingToAdd == 0) {
      int ballNum = 0;
      for (int i = 0; i < COL_NUM; i++) {
        for (int j = 0; j < deadlinePos; j++) {
          if (grid[i][j] != 0) ballNum++;
        }
      }
      if (ballNum + nBalls < (COL_NUM * BALL_COL_NUM_INIT)) {      
        rowsWaitingToAdd++;
      }
    }

    // 超過一定時間自動加球
    if (rowsWaitingToAdd == 0) {
      if (AUTO_ADD_BALL_THRESHOLD > 0 && millis() - lastAddBallTime > AUTO_ADD_BALL_THRESHOLD ) {
        rowsWaitingToAdd++;
      }
    }

    // 加球判斷
    if (rowsWaitingToAdd > 0) {
      if (millis() - lastAddBallTime > ADD_BALL_INTERVAL) {
        addBalls();
      }
    }
  }

  void addBalls() {
    lastAddBallTime = millis();
    rowsWaitingToAdd--;
    soundAddBalls.stop();
    soundAddBalls.play();
    for (int i = 0; i < COL_NUM; i++) {
      for (int j = ROW_NUM-2; j >= 0; j--) {
        grid[i][j+1] = grid[i][j]; //<>//
        state[i][j+1]=state[i][j];
      }
      grid[i][0] = int(random(1, 5));
      state[i][0]=0;
    }
    for (int x=0; x<COL_NUM; x++) {//死亡判定
      if (grid[x][deadlinePos]!=0&&grid[x][deadlinePos]!=5) {
        status = PlayerStatus.KNOCKED_OUT;
        break;
      }
    }
  }

  //---------------觸發combo------------------
  void startBomb() {
    isBombing = true;
    bombStartTime = millis();
    combo+=1;
    comboSound();

    checkQuickAttackOpponent(); //每次觸發消除時確認是否要攻擊對手
  }
  //---------------結束combo------------------
  void stopCombo() { 
    if (combo < QUICK_ATTACK_COMBO_THRESHOLD) //combo結束後若沒有攻擊過才攻擊對手
      opponent.attacked(combo/2);

    combo = 0;
  }
  //---------------攻擊對手-------------------
  void checkQuickAttackOpponent() {
    if (opponent == null) return;

    if (combo == QUICK_ATTACK_COMBO_THRESHOLD) {
      opponent.attacked(combo/2);  //開啟高速攻擊模式會直接攻擊累積的行數
    } else if (combo > QUICK_ATTACK_COMBO_THRESHOLD)
      opponent.attacked(1); //高速攻擊模式時每次combo都攻擊1行
  }

  //---------------受到攻擊--------------------
  void attacked(int attackRows) {
    rowsWaitingToAdd += attackRows;
  } 
  //----------------Deadline----------------------
  void drawDeadLine() {
    int flash = 1 ;
    //int deadButt=1;
    //for (int j = COL_NUM-2; j >= 0; j--) {
    //  for (int i = 0; i <ROW_NUM; i++) {
    //    if (grid[i][j] != 0&&grid[i][j] != 5) {
    //      deadButt = j+1;
    //      break;
    //    } else {
    //      deadButt =0;
    //    }
    //  }
    //}
    //if (deadlinePos-deadButt<7 && deadlinePos-deadButt>=5) flash = 1;
    //else if (deadlinePos-deadButt<5 && deadlinePos-deadButt>=3) flash = 3;
    //else if (deadlinePos-deadButt<3 && deadlinePos-deadButt>=1) flash = 5;
    float a = sin(radians((frameCount%(360/flash))*flash))*127.5+127.5;
    pushMatrix();
    stroke(255, a, a);
    line(0 * RECT_SIZE, deadlinePos * RECT_SIZE, COL_NUM * RECT_SIZE, deadlinePos * RECT_SIZE);
    popMatrix();
  }
  //----------------refLine----------------------
  void drawRefLine() {
    strokeWeight(3);
    int v =frameCount%10;
    for (int i = posY; i > butt; i--) {
      for (int j = 0; j < 50; j+=10)
        if (nBalls > 0) {
          stroke(refLineColor);
          point((posX+0.5)*RECT_SIZE, i*RECT_SIZE-j-v);
        } else {
          stroke(refLineColor);
          point((posX+0.5)*RECT_SIZE, i*RECT_SIZE-j+v);
        }
    }
  }
  //-------------------是否達成目標----------------------
  boolean checkGoal() {
    return bombTargetNum <= 0;
  }
  //----------------------sound----------------------
  void comboSound() {
    if (soundCombo == null || soundCombo.length == 0)
      return;

    for (int i = 0; i < soundCombo.length; i++) {
      soundCombo[i].stop();
      if (combo == i+1) soundCombo[i].play();
    }
    if (combo > soundCombo.length) soundCombo[soundCombo.length - 1].play();
  }
}
