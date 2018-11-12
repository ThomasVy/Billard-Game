//Thomas Vy ENGG 233 B04 YELLOW
//POOL GAME
final float radius = 15; //radius of cue ball
final int lengthst = 200; //length of the pool stick
final int numberofballs=6;//the number of balls drawn not including the cue ball
float [] stick_col = {0, 0, 0};//the color of the pool stick
Table s = new Table();
final float friction=0.2;//friction
int Moving=0 ;  //decides when the user can shoot the cue ball again
float powbar=25; //To increase power bar  
float speed=4; //speed of the cue ball
int gamestate=0;//the gamemode the game is in.
boolean click;//set to true if the mouse is clicked
boolean nomovement; //Check if all the balls stop moving
int ballsleft=numberofballs;//balls that are still in play
float y=95+radius;//the position of the balls when they get sunk
int modechosen; //decides which screen should be printed
int Turn = 1;//who's turn it is
boolean skip=true;//skips the player's turn
int stripesleft=3;//how many stripe balls left for two player
int solidsleft=3;//how many solid balls are left for two player
Player [] Players= new Player [2];//made an array for two players
import ddf.minim.*;//import sound library
Minim minim; 
AudioPlayer audio1;
class Player//For 2 player
{
  int number;//Usernumber
  String type;//The assigned ball type
}
class Point 
{
  float x, y;
  Point (float a, float b)
  {
    x=a;
    y=b;
  }
  float distance (float a, float b) //distance between two points
  {
    float e =sqrt(pow(x-a, 2)+pow(y-b, 2));
    return e;
  }
}
class Ball
{
  float velocity_x;//velocity of cue ball in y
  float velocity_y;//The velocity of the cue ball in x
  float x_fric;// The friction that decreases the speed of the cue ball in the x direction.
  float y_fric;// The friction that decreases the speed of the cue ball in the y direction.
  float rad;//radius of the ball
  float rad2; //radius between the cue ball and mouse. To calculate the angle.
  Point center;//center of the ball
  Point contact_point;
  color col;//color of the ball
  boolean playing;//keeps the ball inside the boundaries of the pool table and allows collisions
  String type; //type of the ball, either stripes or solids
  void ball_movement (int a) //makes the ball move
  {
    if (Moving==1)//goes through the code if it is set to 1
    {
      center.x+=velocity_x;//changes the coordinates of the ball based on speed.
      center.y+=velocity_y;//changes the coordinates of the ball based on speed.
      velocity_x+=x_fric;//changes the speed based on the friction
      velocity_y+=y_fric;//changes the speed based on the friciion
      wallcollisions();//checks if the balls collide with the wall.
      ballcollisions(a);//if the balls collide with each other
      if ((velocity_x>0&&x_fric>0)||(velocity_x<0&&x_fric<0))//Makes sure that the friction is in the opposite direction of the velocity
      {
        x_fric*=-1;//makes the friction in the opposite direction
      }
      if ((velocity_y>0&&y_fric>0)||(velocity_y<0&&y_fric<0))//Makes sure that the friction is in the opposite direction of the velocity
      {
        y_fric*=-1;//makes the friction in the opposite direction
      }
    }
  }
  boolean stopballs()//stops the motion of the balls
  {
    int a = (int)velocity_x;//change the velocity into a int
    int b = (int)velocity_y;//change the velocity into a int
    if (a==0&&b==0)//if the velocity is 0
    {
      velocity_x=0;//set the velocity to actually be 0
      velocity_y=0;//set the velocity to actually be 0
      x_fric=0;//set the friction to be 0
      y_fric=0;//set the friction to be 0
      return true;//send back true if the ball is stopped
    }
    return false;//send back false if the ball is not stopped
  }
  void ballcollisions(int a)//checks if the ball collided with another ball. The variable a is the index of b_arr it is checking
  {
    for (int i=0; i<numberofballs; i++)//goes through all the balls
    {
      if (i!=a&&playing)//does not check if it collides with itself and collides with balls in play.
      {
        float dis=center.distance(s.b_arr[i].center.x, s.b_arr[i].center.y);
        if ((int)dis<(int)radius*2)
          //calculates the distance between two balls and changes the velocity and friction if the ball is inside the other ball.
        {
          /* sometimes the ball would go inside each other and create a weird motion, so the next four lines made it so when a ball collides 
          with another ball it is set outside the ball to stop them from overlapping*/
          float theta = acos((center.x-s.b_arr[i].center.x)/dis);
          float theta2= asin((center.y-s.b_arr[i].center.y)/dis);
          center.x =s.b_arr[i].center.x+cos(theta)*radius*2;
          center.y= s.b_arr[i].center.y+sin(theta2)*radius*2;
 
          float vx1b=velocity_x;//give a variable x the old velocity
          float vy1b=velocity_y;//give a variable y the old velocity
          float vx2b=s.b_arr[i].velocity_x;//give a variable the old velocity x of the ball hit
          float vy2b=s.b_arr[i].velocity_y;//give a variable the old velocity y of the ball hit
          float vx=(vx1b-vx2b);//minus the x velocities
          float vy=(vy1b-vy2b);//minus the y velocities
          float px=(center.x-s.b_arr[i].center.x);//subtract the x centers
          float py=(center.y-s.b_arr[i].center.y);//subtract the y centers
          float k = (vx*px+vy*py)/( pow(px, 2)+ pow(py, 2));//formula from online
          velocity_x=vx1b-k*px;//formula from online
          velocity_y=vy1b-k*py;//formula from online
          s.b_arr[i].velocity_x=vx2b+k*px;//formula from online
          s.b_arr[i].velocity_y=vy2b+k*py;//formula from online
          float r = sqrt(pow(velocity_x, 2)+pow(velocity_y, 2));//calculate the hypotenuse of the angle where the ball will rebound
          theta= acos(velocity_x/r);//calculate the angle of the ball will rebound
          theta2= asin(velocity_y/r);//calculate the angle of the ball will rebound
          fric(theta, theta2);//send the angle to calculate the friction
          r = sqrt(pow(s.b_arr[i].velocity_x, 2)+pow(s.b_arr[i].velocity_y, 2));//calulate the hypotenuse of the angle where the ball is shot
          theta = acos(s.b_arr[i].velocity_x/r);//calculate the angle of where the ball will be shot
          theta2= asin(s.b_arr[i].velocity_y/r);//calculate the angle of where the ball will be shot
          s.b_arr[i].fric(theta, theta2);//send the angle to calculate the friction
        }
      }
    }
  }

  void fric (float angle, float angle2)//calculates the friction of each ball in the opposite direction of velocity
  {
    //makes the friction in the opposite direction of the velocity.
    if (velocity_x>0)
    {
      x_fric = -friction*cos(angle);
      if (velocity_y>0)
      {
        y_fric = -friction*sin(angle2);
      } else if (velocity_y<0)
      {
        y_fric = friction*sin(angle2);
      }
    } else if (velocity_x<0)
    {
      x_fric= friction*cos(angle);
      if (velocity_y<0)
      {
        y_fric=friction*sin(angle2);
      } else if (velocity_y>0)
      {
        y_fric=-friction*sin(angle2);
      }
    }
  }
  void wallcollisions ()//When the ball collides with the wall.
  {
    if (playing)
    {
      if (center.x+radius>(width-75))//the ball hits the right wall
      {
        velocity_x*=-1;//changes the velocity direciton
        x_fric*=-1;   //changes the friction direction
        center.x=width-75-radius;//set the ball the postion before it hit the ball
        audio1.play();//plays sound when ball hits the walls
      } else if (center.x-radius<25)
      {    
        velocity_x*=-1;//changes the velocity
        x_fric*=-1; //changes the friction direction
        center.x=25+radius;//set the ball the postion before it hit the ball
        audio1.play();//plays sound when ball hits the walls
      } else if (center.y-radius<25)//the ball hits the top wall
      {
        velocity_y*=-1;//changes the velocity
        y_fric*=-1;//changes the friction direction
        center.y=25+radius;//set the ball the postion before it hit the ball
        audio1.play();//plays sound when ball hits the walls
      } else if (center.y+radius>height-75)//the wall hit the bottom wall
      {
        velocity_y*=-1;//changes the velocity
        y_fric*=-1;//changes the friction direction
        center.y=height-75-radius;//set the ball the postion before it hit the ball
        audio1.play();//plays sound when ball hits the walls
      }
      audio1.pause();
      audio1.rewind();
    }
  }
  void sink ()
  {
    if (((center.x<25+65&&(center.y<25+65||center.y>height-75-65)))||(center.x>width-75-65&&(center.y<25+65||center.y>height-75-65))) //if the ball is sunk
    {
      if (ballsleft==numberofballs&&gamestate==2)//assigns the ball type to each user in 2 player
      {
        skip=false;//if its the first ball to to be sunk, the player keeps their turm
        if (type=="Stripes")//if the ball they sunk was stripes the player who sunk it has stripes as their ball type
        {
          if (Turn==1)
          {
            Players[0].type="Stripes";
            Players[1].type="Solids";
          } else
          {
            Players[1].type="Stripes";
            Players[0].type="Solids";
          }
        } else//if the ball that sunk was solids, the player who sunk it has solids as their ball type
        {
          if (Turn==1)
          {
            Players[1].type="Stripes";
            Players[0].type="Solids";
          } else
          {
            Players[0].type="Stripes";
            Players[1].type="Solids";
          }
        }
      }
      if (ballsleft<numberofballs&&gamestate==2)//checks if the user sunk the wrong ball in 2 player
      {
        if (Players[Turn-1].type==type)//if its their ball is the right one, the player keeps their turn
          skip=false;
      }
      if (type=="Stripes")//if the ball that sunk was stripes then the number of stripe balls go down
      {
        stripesleft-=1;
      } else if (type=="Solids")//if the ball that sunk was solids then the number of solid balls go down
      {
        solidsleft-=1;
      }
      center.x=width-25;//set the ball to the sunk position
      center.y=y;//set the postition of the sunk ball
      ballsleft-=1;//decrease the number of balls in play
      velocity_y=0;//set the velocity to 0
      velocity_x=0;
      x_fric=0;//set the friction to 0
      y_fric=0;
      playing=false;//set the ball to a ball in not play.
      y+=30;//places the next ball to be underneath the other sunken balls.
    }
  }
  void drawballs()//draws the balls.
  {
    strokeWeight(1);
    fill(col);
    ellipse(center.x, center.y, rad*2, rad*2);
    if (type=="Stripes"&&gamestate==2)//if its 2 player mode and the ball type is stripes, it draws a line for the assigned balls
    {
      strokeWeight(5);
      stroke(0);
      line(center.x-radius, center.y, center.x+radius, center.y);
    }
  }
} 
class Stick 
{
  Point start_P;//Start Point of stick
  Point end_P;//End Point of stick
  color col;  //color of the pool stick
  int length; //length of the pool stick
  float r;//the distance between the cue ball and start point
  Stick ()//default setting
  {
    start_P= new Point(0, 0);
    end_P=new Point(0, 0);
    col= color(stick_col[0], stick_col[1], stick_col[2]);//black
    length = lengthst;
  }
  void drawstick (float x, float y) //x and y is cue ball center
  {

    r = sqrt(pow((mouseX-x), 2)+pow((mouseY-y), 2)); //radius between the the cue_ball and mouse(starting point)
    strokeWeight(4);
    col= color(stick_col[0], stick_col[1], stick_col[2]);
    stroke(col);
    start_P.x=mouseX; //starting point which is mouse x
    start_P.y=mouseY;//starting point which is mouse y
    end_P.x= x + ((length+r)*(mouseX-x)/r); //calculates position using the trig
    end_P.y=y+((mouseY-y)*(length+r)/r);
    line(start_P.x, start_P.y, end_P.x, end_P.y);
    stroke(0);
  }
  //More code
}
class Table
{
  Ball [] b_arr; //array of balls 
  Ball cue_ball;
  Stick st;//the pool stick
  Table ()
  {
    cue_ball= new Ball();
    st = new Stick ();
    b_arr = new Ball [numberofballs];
    for (int i =0; i<numberofballs; i++)//creates ball types for each element in the array
    {
      b_arr[i] = new Ball();
    }
  }
  //more code
}

void setup()
{
  size (1000, 600 );
  minim = new Minim(this);
  audio1 = minim.loadFile("Sound.wav");//loads in the proper sound file
  cue_ball_setup();// sets up the cueball
  otherballs_setup();//sets upp all the other balls.
  Playersetup();//sets up each player for 2 player
}
void draw()
{
  if (gamestate==3||gamestate==-1||gamestate==2||gamestate==1)
    backgrounddraw(); //draws the background
  if (gamestate==1||gamestate==2)//1 player or 2 player
  {
    powershot();//strength of shot
    drawcue();
    drawotherballs();//draw all the other balls
    s.st.drawstick(s.cue_ball.center.x, s.cue_ball.center.y);
    checkangleshot();//checks the angle of which the cue ball was shot at
    ballmovement();//if the balls in movement
    stopmoving();//stops the movement of the balls
    Sinkball();//check if the balls are sunk
    menu();//go back to the menu
    Lose();//checks the condition to lose
    Win();//checks the condition to win
  } else  if (gamestate==-1)//if you lose
  {
    printLose();
    restart();
  } else if (gamestate==3)//if you win
  {
    printWin();
    restart();
  } else if (gamestate==0)//menu
  {
    menudraw();//draws the menu
  }
}
void stop()//stops all the sounds
{
  minim.stop();
  super.stop();
}
void Playersetup ()//sets up the Players in 2 player mode
{
  Players[1]=new Player();
  Players[0]=new Player();
  Players[0].number=1;//assigns the player numbers
  Players[1].number=2;
}
void ballmovement ()//checks if balls are moving and then moves the ball
{
  s.cue_ball.ball_movement(-1);//moves the cue ball
  for (int i=0; i<numberofballs; i++)
    s.b_arr[i].ball_movement(i);//moves all the balls
}
void stopmoving()// stops any movement in the balls
{
  if (Moving ==1) // checks if the movement of balls are still active
  { 
    nomovement=checkifanymovement();//check if any balls are moving

    if (nomovement==true)//if there is no movement left, stop all the balls and resets the strength of the initial shot and lets the user click on the ball again
    {
      Moving =0;//mode that tells the program to stop changing the postion of the balls
      speed=4;//resets the speed of the initial hit
      stick_col[0]=0;//reset the color of the stick
      click=false;//reset so you can click the ball again
      powbar=25;//reset the powerbar
      if (gamestate==2&&skip)//changes turns for each user after each shot.
      {
        if (Turn==1)
          Turn=2;
        else
          Turn=1;
      }
      skip=true;//resets the skipping of turns until a ball is sunken
    }
  }
}   
boolean checkifanymovement()//checks if any movement, send true if there is no movement
{
  if (s.cue_ball.stopballs()==false)//if the cue ball hasn't stopped, send false
    return false;
  for (int i =0; i<numberofballs; i++)
  {
    if (s.b_arr[i].stopballs()==false)//if any ball hasn't stopped, sends false
      return false;
  }
  return true;//sends true only if all the balls stopped moving
}
void cue_ball_setup()//sets up the cue ball
{
  s.cue_ball.center = new Point (200, 300);
  s.cue_ball.contact_point = new Point (0, 0);
  s.cue_ball.rad= radius;
  s.cue_ball.col=color(255);
  s.cue_ball.playing =true;//allows the ball to have collisions
}
void otherballs_setup()//set up the other balls.
{
  s.b_arr[0].col=color(0, 255, 0);
  s.b_arr[1].col=color(255, 0, 0);
  s.b_arr[2].col=color(0, 0, 255);
  s.b_arr[3].col=color(255, 255, 0);
  s.b_arr[4].col=color(0);
  s.b_arr[5].col=color(255, 153, 204);
  s.b_arr[0].center = new Point (600, 300);
  s.b_arr[1].center = new Point (635, 280);
  s.b_arr[2].center = new Point (635, 320);
  s.b_arr[3].center = new Point (670, 260);
  s.b_arr[4].center = new Point (670, 300);
  s.b_arr[5].center = new Point (670, 340);


  for (int i=0; i<numberofballs; i++)
  {
    s.b_arr[i].rad=radius;
    s.b_arr[i].playing=true;//allows all the balls to have collisions
  }
}
void drawcue ()//draws the cue ball and a ellipse for the contact point
{
  s.cue_ball.rad2 = sqrt(pow(mouseX-s.cue_ball.center.x, 2)+pow(mouseY-s.cue_ball.center.y, 2));//calculates the distance between the cue ball and mouse
  s.cue_ball.contact_point.x=s.cue_ball.center.x+(mouseX-s.cue_ball.center.x)*s.cue_ball.rad/s.cue_ball.rad2;//calculate the contact point using trig
  s.cue_ball.contact_point.y=s.cue_ball.center.y+(mouseY-s.cue_ball.center.y)*s.cue_ball.rad/s.cue_ball.rad2;
  fill(149, 101, 25);
  ellipse(s.cue_ball.contact_point.x, s.cue_ball.contact_point.y, 25, 25);// draws an ellipse for the contact point
  s.cue_ball.drawballs();//draw the cue ball
}
void drawotherballs()// draw all the other balls
{
  for (int i=0; i<numberofballs; i++)
  {
    s.b_arr[i].drawballs();
  }
  if (gamestate==2)//if it is in 2 player mode set the ball types for each ball
  {
    s.b_arr[0].type="Stripes";
    s.b_arr[2].type="Stripes";
    s.b_arr[3].type="Stripes";
    s.b_arr[1].type="Solids";
    s.b_arr[4].type="Solids";
    s.b_arr[5].type="Solids";
  }
}
void restart ()//restarts the games
{
  if (keyPressed)
  {
    powbar=25;//reset the powerbar
    gamestate=modechosen;//resets the game based on the gamemode you chose in the beginning
    y=95+radius;// reset the position of the ball placement once sunk
    ballsleft=numberofballs;//reset the number of balls in play 
    //set the balls back in their original position
    s.cue_ball.center = new Point (150, 300);
    s.b_arr[0].center = new Point (600, 300);
    s.b_arr[1].center = new Point (635, 280);
    s.b_arr[2].center = new Point (635, 320);
    s.b_arr[3].center = new Point (670, 260);
    s.b_arr[4].center = new Point (670, 300);
    s.b_arr[5].center = new Point (670, 340);
    for (int i =0; i<numberofballs; i++)
    {
      //give all the balls no velocity and friction in the beginning
      s.b_arr[i].velocity_x=0;
      s.b_arr[i].velocity_y=0;
      s.b_arr[i].x_fric=0;
      s.b_arr[i].y_fric=0;
      s.b_arr[i].playing =true;//allows the ball to have collisions
    }
    Moving =0;//doesn't allow the ball to move
    click=false;//allows the user to click again
    speed=4;//reset initial speed of the cue ball
    stick_col[0]=0;//reset color of pool stick
    if (gamestate==2)//2 player
    {
      solidsleft=3;//resets the number of solids left
      stripesleft=3;//resets the number of stripes left
      Turn=1;//reset back to first player's turn
      //reset the assigned ball types.
      Players[0].type=null;
      Players[1].type=null;
    }
  }
}
void menu ()//checks if the user wants to go back to the menu
{
  if (keyPressed&&key=='1')
    gamestate=0;
}
void printLose ()//The cue ball was sunk and the player lost
{
  fill(255);
  textSize(25);
  text("press any key to restart ", width/2-200, height/2+50);
  textSize(100);
  if (modechosen==1)//if gamemode was single player 
  {
  text("Game Over", width/2-200, height/2);
  }
  else if (modechosen==2)//if gamemode was 2 player
  {
    if (Turn==1)
    {
      text("PLAYER 2 WINS", width/2-400,height/2);//Player 1 loses because they sunk the cue ball
    }
    else 
    {
      text("PLAYER 1 WINS",width/2-400,height/2);//Player 2 loses because they sunk the cue ball
    }
  }
}
void printWin()//all the balls sunk 
{
  fill(255);
  textSize(25);
  text("press any key to restart ", width/2-200, height/2+50);
  textSize(100);
  if (modechosen==1)//single player
  {
    text("YOU WIN", width/2-200, height/2);
  } 
  if (modechosen==2)//2 player
  {
    if (stripesleft==0)//all the stipe balls were sunk
    {
      //chooses the appropriate player and prints the win screen for the player that has stripes
      if (Players[0].type=="Stripes")
      {
        text("PLAYER 1 WINS", width/2-400, height/2);
      } else
      {
        text("PLAYER 2 WINS", width/2-400, height/2);
      }
    } else if(solidsleft==0)//all the solid balls were sunk
    {
      //chooses the appropriate player and prints the win screen for the player that has solids
      if (Players[0].type=="Solids")
      {
        text("PLAYER 1 WINS", width/2-400, height/2);
      } else 
      {
        text("PLAYER 2 WINS", width/2-400, height/2);
      }
    }
  }
}

void Sinkball()//check if the balls are sunk
{
  for (int i=0; i<numberofballs; i++)
  {
    s.b_arr[i].sink();
  }
} 
void Win()
{
  if (gamestate==1)//single player
  {
    if (ballsleft==0)//you win if there are no balls left
    {
      modechosen=gamestate;//allows the single player win screen to print
      gamestate=3;//win state
    }
  } else if (gamestate==2)//2 player
  {
    if (stripesleft==0)//all stripe balls were sunk
    {
      modechosen=gamestate;//allows the 2 player win screen to print
      gamestate=3;//win state
    } else if (solidsleft==0)//all solid balls were sunk
    {
      modechosen=gamestate;//allows the 2 player win screen to print
      gamestate=3;//win state
    }
  }
}
void Lose ()// you lose if all the cue ball goes into one of the pockets
{
  if (((s.cue_ball.center.x<25+65&&(s.cue_ball.center.y<25+65||s.cue_ball.center.y>height-75-65)))||(s.cue_ball.center.x>width-75-65&&(s.cue_ball.center.y<25+65||s.cue_ball.center.y>height-75-65)))
  {
    modechosen=gamestate;//keeps the memory of which gamemode was chosen
    gamestate=-1;//goes to the lose mode\
  }
}
void powershot ()//power ups the shot based on the keyboard presses
{
  if (keyPressed && (key =='b'||key=='B'))//reset the power to shot the cue ball with
  {
    speed=4;
    stick_col[0]=0;
    powbar=25;
  }

  if (keyPressed && key ==' ')//increases the power of the shot of the cue ball
  {
    powbar+=9;
    speed+=0.5;
    stick_col[0]+=5;
    if (speed>30)//creates a limit for the power
    {
      powbar=500;
      speed=30;
      stick_col[0]=255;
    }
  }
}
void backgrounddraw() //draws background
{

  strokeWeight(1);
  background (0, 100, 0);
  fill(0);     
  ellipse (25, 25, 130, 130); //top left pocket
  ellipse (width-75, 25, 130, 130);  // top right pocket
  ellipse (25, height-75, 130, 130); // bottom left pocket
  ellipse (width-75, height-75, 130, 130); //bottom right pocket 
  fill(149, 101, 25);
  rect(0, 0, width-50, 25);//wall on top
  rect(0, height-75, width-50, 25);//wall on bottom
  rect(0, 0, 25, height-50); //wall on left
  rect(width-75, 0, 25, height-50); // wall on right
  fill(255);
  noStroke();
  rect(0, height-50, width, 50);//the white bar on the bottom
  rect(width-50, 0, 50, height);//the white bar on the right
  stroke(0);
  fill(0);
  textSize(25);
  text("POWER", 0, height-25); //The power bar
  if (gamestate ==2)//prints the extra stuff for 2 player mode
  {
    text("Player "+Turn+ " turn", width-200, height-25);//prints who's turn it is in 2 player
    text("Ball Type: " + Players[Turn-1].type, width-250, height-5);//prints the ball type for the player
  }
  rect(100, height-25, 500, 25);//The black power bar
  fill(255, 0, 0);
  rect(100, height-25, powbar, 25);//The red power bar
}
void menudraw ()//draws the menu to select between modes
{
  background (255);
  fill(0);
  textSize(50);
  text("Thomas Vy's Pool Game", 50, 100);
  fill(100);
  text("Single Player", 100, 200);
  text("Two Player", 100, 300);
  textSize(30);
  text("Instructions(Press and hold)", 100, 400);
  Instructions();
} 
void Instructions()//displays the rules and controls of the game
{
  if (mousePressed && mouseX>99 && mouseX<500 && mouseY>370 && mouseY<404)
  {
    fill(255);
    rect(510, 300, 450, 200);
    fill(0);
    textSize(15);
    text("Shoot your balls into the pockets by shooting the cue ball", 520, 340);
    text("DO NOT SINK THE CUE BALL", 520, 360);
    text("Press Spacebar to Power up your shot", 520, 380);
    text("Press 'b' to reset your shot", 520, 400);
    text("Press '1' to go back to menu", 520, 420);
    text("Press the mouse button to launch the cue ball", 520, 440);
  }
}
void checkangleshot ()//uses the angle and power it is shot with to calculate the speed of the cue ball
{  
  if (click==false)
  {
    if (mousePressed)
    {
      float angle = acos((s.cue_ball.contact_point.x-s.cue_ball.center.x)/(radius));//calculate the angle of cue ball
      float angle2 =asin((s.cue_ball.contact_point.y-s.cue_ball.center.y)/(radius));//calculate the angle of cue ball
      s.cue_ball.velocity_x= -cos(angle)*speed;//velocity is based on speed and angle
      s.cue_ball.velocity_y= -sin(angle2)*speed;
      s.cue_ball.fric(angle, angle2);//calulate the friction of the ball
      Moving=1;
      click=true;//user cannot click more than once to move the ball.
    }
  }

  //More code
}
void mouseReleased()//changes game mode when you are on the menu and click certain spots
{
  audio1.play();//plays sound when ball is hit by the pool stick
  audio1.pause();//pauses the sound
  audio1.rewind();
  if (gamestate==0)
  {
    if (mouseX>84 && mouseX<409 && mouseY>152 && mouseY<210)
      gamestate=1;
    else if (mouseX>88 && mouseX<369 && mouseY>256 && mouseY<309)
      gamestate=2;
  }
}