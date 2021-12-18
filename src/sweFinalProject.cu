/*This program tries to replicate the code in custom_swe.py
in order to perform SWE equations. */

#include <iostream>
#include <vector>

// --------------- Physical prameters ---------------
#define L_x 1E+6              //Length of domain in x-direction
#define L_y  1E+6             //Length of domain in y-direction
#define g 9.81                //Acceleration of gravity [m/s^2]
#define H  100                //Depth of fluid [m]
#define f_0  1E-4              //Fixed part ofcoriolis parameter [1/s]
#define beta  2E-11            //gradient of coriolis parameter [1/ms]
#define rho_0  1024.0          //Density of fluid [kg/m^3)]
#define tau_0  0.1             //Amplitude of wind stress [kg/ms^2]

// --------------- Computational prameters ---------------
#define N_x 150
#define N_y 150

#define dx L_x/(N_x - 1)                   // Grid spacing in x-direction
#define dy  L_y/(N_y - 1)                   // Grid spacing in y-direction
#define dt  0.1* std::min(dx, dy)/ sqrt(g*H)    // Time step (defined from the CFL condition)
#define anim_interval 20 

//https://stackoverflow.com/questions/27028226/python-linspace-in-c
//Function uses to mimic linspace from NumPy
template<typename T>
std::vector<double> linspace(T start_in, T end_in, int num_in)
{

  std::vector<double> linspaced;

  double start = static_cast<double>(start_in);
  double end = static_cast<double>(end_in);
  double num = static_cast<double>(num_in);

  if (num == 0) { return linspaced; }
  if (num == 1) 
    {
      linspaced.push_back(start);
      return linspaced;
    }

  double delta = (end - start) / (num - 1);

  for(int i=0; i < num-1; ++i)
    {
      linspaced.push_back(start + delta * i);
    }
  linspaced.push_back(end); // I want to ensure that start and end
                            // are exactly the same as the input
  return linspaced;
}

//Function used to mimic transpose from NumPy
std::vector<std::vector<double>> transpose(std::vector<double> input, std::string axis){
  std::vector<std::vector<double>> newVect;

  //transpose on x-axis, implementation is not correct
  if(axis == "x"){

    for(int i = 0; i < input.size(); i++){
      std::vector<double> temp;
      for(int j = 0; j < input.size(); j++)
        temp.push_back(input[i]);
      newVect.push_back(temp);
    }
  }
  //transpose on y-axis, implementation not complete
  else if(axis == "y"){
    for(int i = 0; i < input.size(); i++){

    }

  }

  return newVect;
}


//Simple function used to print one dimentional vectors 
void print_1d_vector(std::vector<double> vec)
{
  std::cout << "[ ";
  for (double d : vec)
    std::cout << d << " ";
  std::cout << "]" << std::endl;
}

//Function used to print two dimentional vectors
void print_2d_vector(std::vector<std::vector<double>> vec){
  
  for(std::vector<double> list: vec){

    std::cout << "[ ";
    for(double d : list)
      std::cout << d << " ";
    std::cout << "]" << std::endl;
  }
}


int main(int argc, char** argv) {

  //Create matrixes that will do calculations 
  std::vector<double> x = linspace(-L_x/2, L_x/2, N_x);
  std::vector<double> y = linspace(-L_y/2, L_y/2, N_y);
  
  //Used to verify if linespace is working correctly
  //std::vector<double> X = {-100.0,-98.65771812,  -97.31543624,  -95.97315436,  -94.63087248,
  //-93.2885906,   -91.94630872,  -90.60402685,  -89.26174497,  -87.91946309,
  //-86.57718121,  -85.23489933,  -83.89261745,  -82.55033557,  -81.20805369,
  //-79.86577181,  -78.52348993,  -77.18120805,  -75.83892617,  -74.4966443,
  //-73.15436242,  -71.81208054,  -70.46979866,  -69.12751678,  -67.7852349,
  //-66.44295302,  -65.10067114,  -63.75838926,  -62.41610738,  -61.0738255,
  //-59.73154362,  -58.38926174,  -57.04697987,  -55.70469799,  -54.36241611,
  //-53.02013423,  -51.67785235,  -50.33557047,  -48.99328859,  -47.65100671,
  //-46.30872483,  -44.96644295,  -43.62416107,  -42.28187919, -40.93959732,
  //-39.59731544,  -38.25503356,  -36.91275168,  -35.5704698,  -34.22818792,
  //-32.88590604,  -31.54362416,  -30.20134228,  -28.8590604,   -27.51677852,
  //-26.17449664,  -24.83221477,  -23.48993289,  -22.14765101,  -20.80536913,
  //-19.46308725,  -18.12080537,  -16.77852349,  -15.43624161,  -14.09395973,
  //-12.75167785,  -11.40939597,  -10.06711409,   -8.72483221,   -7.38255034,
   //-6.04026846,   -4.69798658,   -3.3557047,    -2.01342282,   -0.67114094,
    //0.67114094,    2.01342282,    3.3557047,     4.69798658,    6.04026846,
    //7.38255034,    8.72483221,   10.06711409,   11.40939597,   12.75167785,
   //14.09395973,   15.43624161,   16.77852349,   18.12080537,   19.46308725,
   //20.80536913,   22.14765101,   23.48993289,   24.83221477,   26.17449664,
   //27.51677852,   28.8590604,    30.20134228,   31.54362416,   32.88590604,
   //34.22818792,   35.5704698,    36.91275168,   38.25503356,   39.59731544,
   //40.93959732,   42.28187919,   43.62416107,   44.96644295,   46.30872483,
   //47.65100671,   48.99328859,   50.33557047,   51.67785235,   53.02013423,
   //54.36241611,   55.70469799,   57.04697987,   58.38926174,   59.73154362,
   //61.0738255,    62.41610738,   63.75838926,   65.10067114,   66.44295302,
   //67.7852349,    69.12751678,   70.46979866,   71.81208054,   73.15436242,
   //74.4966443,    75.83892617,   77.18120805,   78.52348993,   79.86577181,
   //81.20805369,   82.55033557,   83.89261745,   85.23489933,   86.57718121,
  //87.91946309,   89.26174497,   90.60402685,   91.94630872,   93.2885906,
  //94.63087248,   95.97315436,   97.31543624,   98.65771812,  100.0 };

  //Do transpose function onto matrixes to accurately represent velocity vectors when plotting
  std::vector<std::vector<double>> newX = transpose(X, "x");
  std::vector<double> Y = X;

  
  //Testing transpose with print statements
  std::cout << dt << std::endl;
  print_1d_vector(X);
  print_1d_vector(newX[0]);


  return 0;
}