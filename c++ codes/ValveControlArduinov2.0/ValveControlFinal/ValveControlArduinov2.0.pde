/*
Arduino Valve Control 
 
 This is an arduino code that communicates with a PC in order to control pressure 
 through valves. The controller is a PID controller that is imported
 from a PID library. This program is meant to be used in conjuction
 with a GUI developed in Visual C#. 
 
 */

// Output Pins
#define Vent 6
#define Vacuum 5
//Input Pins
#define SensorIn 0

#define kPaTObits 7.930895559
#define bitsTOkPa 0.1260891651

// Outout max
#define FULL 255
#define ATM 103
#define pi 3.14159265

double cutlowfreq = 20;

// Global Variables
int Wform_index = 0;
int Ctrl_index = 0;
int fil_index = 0;
int counter = 0;
int e = 0;
int elast = 0;
double IntegralSum = 0;

boolean cmdControl = false;
boolean cmdsendCPrs = false;
boolean cmdsendTPrs = false;
boolean cmdWformConfirm = false;
boolean cmdControlConfirm = false;
boolean cmdWformReceiving = false;
boolean cmdCparamReceiving = false;
boolean cmdLPFilter = false;

double Ampl, Freq, DutyCycle, DCOffset;
int wform_decpos[4] = {
  0,0,0,0};
int Ctrl_decpos[3] = {
  0,0,0};
int fil_decpos = 0;

byte rcvByte, wparam[21], cparam[15], LPfilter[5], wform;
double currentPressure = 0;
double filteredPressure = 0;
double lastfilteredPressure = 0;
double targetPressure = 0;
double Time, dTime, lTime;

// These variables will serve as pointers for the PID function
double VA_Out, VE_Out, PGain, IGain, DGain;

// Setup for the Arduino board before the execution
void setup() 
{
  // sets the BAUD rate for serial communication. This value MUST match the one
  // the other device to be used
  Serial.begin(9600);
  // Flushes the serial buffer
  Serial.flush();

  //declares the pins as outputs
  pinMode(Vent, OUTPUT);
  pinMode(Vacuum, OUTPUT);
}

double squarewave(double amp, double freq, double dutycycle, double t)
{

  return amp;
}

// This function organizes 5 bytes received and returns a number of type double
// The parameter dpos is the position of the decimal point, if there is one
// The parameter form is used to locate where in the array the number is to be formed.
double datamanager(byte b[], int dpos, int form, char type[])
{
  //local variables
  int exponent;
  boolean decFlag = false;
  double Val = 0;
  int i;
  int bound;

  if (type == "wform")
    bound = 5*form;
  else if (type == "control" || type == "filter")
    bound = 5*form - 1;

  exponent = (bound-dpos);

  for (i = bound; i >=(bound-4) ; i--)
  {
    if (b[i] == '.') 
      decFlag = true;  
    else if (decFlag == true)	
      Val += (b[i] - '0')*pow(10,(bound-i-1));
    else
      Val += (b[i] - '0')*pow(10,(bound-i)); 
  }

  if (decFlag == true)
    Val /= pow(10,exponent);

  return Val;
}

double lowpassfilter(double cPr, double lfPr, double dt, double LPfreq)
{
  double fPr;
  double tau;
  
  tau = 1/(2*pi*LPfreq);
  
  double a = dt/(tau+dt);

  fPr = a*cPr + (1-a)*lfPr;

  return fPr;
}

// main program
void loop()
{ 
  // Each time loop() iterates the variable time gets a new value
  // this value is equivalent to the amount of time since the program 
  // started executing in seconds.
  Time = millis()/1000.0;
  dTime = Time - lTime;

  // the variable currentPressure stores the value of pressure recorded 
  // from the sensor. Once uploaded the arduino will keep 
  // keep reading the pressure continously.
  currentPressure = analogRead(SensorIn);
  filteredPressure = lowpassfilter(currentPressure,lastfilteredPressure, dTime, cutlowfreq);

  // Verifies if there has been any command sent from the connected device
  if (Serial.available() > 0)
  { 
    // Reads a Byte from the serial in buffer
    rcvByte = Serial.read();

    // Verifies if the byte is one of the characters c, s or r
    // c indicates that a constant value is the desired waveform
    // s indicates that a sine waveform is the desired
    // r indicates that a rectangular waveform is desired
    if ((rcvByte == 'c') || (rcvByte == 's')||(rcvByte == 'r'))
    {
      // the array wparam will receive all the bytes that describe the
      // properties of the waveform to be form
      // the first byte wparam[0] correspond to what waveform it is
      wparam[Wform_index] = rcvByte;
      Wform_index++;
      cmdWformReceiving = true;
    }

    // if the Byte received is e, indicates a command to send current pressure data
    else if(rcvByte == 'e')
      cmdsendCPrs = true;

    // send TargetPressure data
    else if (rcvByte == 'h')
      cmdsendTPrs = true;

    // if the Byte received is f, it is a command to stop acquiring data
    else if(rcvByte == 'f')
    {
      cmdsendCPrs = false;
      cmdsendTPrs = false;
    }
    // if the Byte received is y, it is a command to start the control action
    else if(rcvByte == 'y')
      cmdCparamReceiving = true;

    // if the Byte received is x, it is a command to stop the control action
    else if(rcvByte == 'x')
      cmdControl = false;

    else if (rcvByte == 'z')
      cmdLPFilter = true;

    // this section is enabled, if a control command has been sent
    // it reads the bytes and stores them accordingly
    else if (cmdCparamReceiving == true && Ctrl_index != 15)
    {
      if(rcvByte == '.')
      {
        cparam[Ctrl_index] = rcvByte;
        if (Ctrl_index <=4)
          Ctrl_decpos[0] = Ctrl_index;
        else if (Ctrl_index <=9)
          Ctrl_decpos[1] = Ctrl_index;
        else if (Ctrl_index <= 14)
          Ctrl_decpos[2] = Ctrl_index;
      }
      else
        cparam[Ctrl_index] = rcvByte;

      Ctrl_index++;
    }

    // this section is enabled if the first Byte received is to form a waveform
    else if (cmdWformReceiving == true && Wform_index != 21)
    {
      // if there is a decimal point, its position is stored 
      if(rcvByte == '.')
      {
        wparam[Wform_index] = rcvByte;
        if (Wform_index <=5)
          wform_decpos[0] = Wform_index;
        else if (Wform_index <=10)
          wform_decpos[1] = Wform_index;
        else if (Wform_index <= 15)
          wform_decpos[2] = Wform_index;
        else if (Wform_index <= 20)
          wform_decpos[3] = Wform_index;
      }

      // otherwise, the Byte should be a number and will be stored in the array wparam
      else
        wparam[Wform_index] = rcvByte;

      Wform_index++;
    }

    else if (cmdLPFilter == true && fil_index != 5)
    {
      if(rcvByte == '.')
      {
        LPfilter[fil_index] = rcvByte;
        fil_decpos = fil_index;
      }
      else
        LPfilter[fil_index] = rcvByte;

      fil_index++;
    }
  }

  // the following section establishes the paramaters for the waveform
  // this section is enabled when the Wform_index reaches 16, meaning that
  // all the necessary information has been acquired.
  if (Wform_index == 21)
  {
    // intializes the index and the other wave form parametes
    Wform_index = 0;
    Ampl = 0;
    Freq = 0;
    DutyCycle = 0;
    DCOffset = 0;

    // the type of waveform is stored in wform
    wform = wparam[0];

    // converts the array of bytes into a ussable double type number
    Ampl = datamanager(wparam,wform_decpos[0],1,"wform");
    Freq = datamanager(wparam,wform_decpos[1],2,"wform");
    DutyCycle = datamanager(wparam,wform_decpos[2],3,"wform");
    DCOffset = datamanager(wparam,wform_decpos[3],4,"wform");

    // intializes the arrays
    for (int i = 0; i < 21; i++) wparam[i] = 0;
    for (int i = 0; i < 3; i++) wform_decpos[i] = 0;

    // these two boolean variables are set to false to cue further actions 
    cmdWformReceiving = false;
    cmdWformConfirm = false;
  }

  // When the Ctrl_Index has reached 15, it means that all the information regarding
  // the control parameters has been received
  if (Ctrl_index == 15)
  {
    Ctrl_index = 0;
    PGain = 0;
    IGain= 0;
    DGain = 0;

    PGain = datamanager(cparam,Ctrl_decpos[0],1,"control");
    IGain = datamanager(cparam,Ctrl_decpos[1],2,"control");
    DGain = datamanager(cparam,Ctrl_decpos[2],3,"control");

    for (int i = 0; i <15; i++) cparam[i] = 0;
    for (int i = 0; i < 3; i++) Ctrl_decpos[i] = 0;

    cmdCparamReceiving = false;
    cmdControl = true;

    if (! (cmdsendCPrs || cmdsendTPrs))
      cmdControlConfirm = false;
  }

  if (fil_index == 5)
  {
    fil_index = 0;

    cutlowfreq = datamanager(LPfilter,fil_decpos,1,"filter");

    for (int i = 0; i <5; i++) LPfilter[i] = 0;
    fil_decpos = 0;

    cmdLPFilter = false;
  }
  // This section confirms the information sent to form the
  // waveform
  if (cmdWformConfirm == false)
  {
    if (wform == 'c') 
      targetPressure = Ampl*kPaTObits + ATM ; 
    else if (wform == 's')
      targetPressure = Ampl*kPaTObits/2.0*sin(2*PI*Freq*Time) + DCOffset*kPaTObits + ATM;
    else if(wform == 'r')
      targetPressure = squarewave(Ampl, Freq, DutyCycle, Time) + DCOffset*kPaTObits;
  }

  // this section executes when there is a command to Control the 
  // output and when tunning the control parametes is petioned
  if (cmdControl == true)
  {
    e = targetPressure - filteredPressure;

    if (((VA_Out < 255 || e <= 0)&&(VA_Out > 0 || e >= 0))&&!(wform == 'c' && targetPressure <= (ATM+5)))
      IntegralSum = IntegralSum + e*dTime; 

    VA_Out = (PGain * e + IGain*IntegralSum/100.0 + DGain * (e - elast)/dTime);

    if(VA_Out < 0)
      VA_Out = 0;
    else if(VA_Out > 255)
      VA_Out = 255;

    // The other Valve will be the opposite of VA_Out
    VE_Out = FULL - VA_Out;

    elast = e;

    // sends the outputs to the appropiate pins
    analogWrite(Vacuum, int(VA_Out));
    analogWrite(Vent, int(VE_Out));
  }
  else
  {
    cmdWformConfirm = true;
    analogWrite(Vacuum, 0);
    analogWrite(Vent, 0);
  }

  // this section is executed if there is a command to received the data
  if (cmdsendCPrs == true)
  {
    Serial.print(filteredPressure,0);
    Serial.print("$");
  }
  else if (cmdsendTPrs == true)
  {
    Serial.print(VA_Out);
    Serial.print("$");
  }

  // feedback information to the GUI about the parametes and outputs
  if (cmdsendCPrs == false && cmdsendTPrs == false && cmdControlConfirm == false)
  {
    cmdControlConfirm = true;
  }  

  lastfilteredPressure = filteredPressure;
  lTime = Time;

}  














