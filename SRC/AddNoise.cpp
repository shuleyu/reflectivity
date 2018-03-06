#include<iostream>
#include<fstream>
#include<sstream>
#include<cstdio>
#include<cstdlib>
#include<vector>
#include<string>
#include<cstring>
#include<cmath>
#include<random>
#include<ctime>
#include<unistd.h>
extern "C"{
#include<sac.h>
#include<sacio.h>
#include<ASU_tools.h>
}

using namespace std;

int main(int argc, char **argv){

    enum PIenum{UniformNoise,FLAG1};
    enum PSenum{FileList,NoiseFiles,FLAG2};
    enum Penum{NoiseLevel,FLAG3};

    /****************************************************************

				Deal with inputs. (Store them in PI,PS,P)

    ****************************************************************/

	if (argc!=4){
		cerr << "In C++: Argument Error!" << endl;
		return 1;
	}

    int int_num,string_num,double_num;

    vector<int> PI;
    vector<string> PS;
    vector<double> P;

    int_num=atoi(argv[1]);
    string_num=atoi(argv[2]);
    double_num=atoi(argv[3]);

	if (FLAG1!=int_num){
		cerr << "In C++: Ints Naming Error !" << endl;
	}
	if (FLAG2!=string_num){
		cerr << "In C++: Strings Naming Error !" << endl;
	}
	if (FLAG3!=double_num){
		cerr << "In C++: Doubles Naming Error !" << endl;
	}

	string tmpstr;
	int tmpint,Cnt;
	double tmpval;

	Cnt=0;
	while (getline(cin,tmpstr)){
		++Cnt;
		stringstream ss(tmpstr);
		if (Cnt<=int_num){
			if (ss >> tmpint && ss.eof()){
				PI.push_back(tmpint);
			}
			else{
				cerr << "In C++: Ints reading Error !" << endl;
				return 1;
			}
		}
		else if (Cnt<=int_num+string_num){
			PS.push_back(tmpstr);
		}
		else if (Cnt<=int_num+string_num+double_num){
			if (ss >> tmpval && ss.eof()){
				P.push_back(tmpval);
			}
			else{
				cerr << "In C++: Doubles reading Error !" << endl;
				return 1;
			}
		}
		else{
			cerr << "In C++: Redundant inputs !" << endl;
			return 1;
		}
	}
	if (Cnt!=int_num+string_num+double_num){
		cerr << "In C++: Not enough inputs !" << endl;
		return 1;
	}

    /****************************************************************

                              Job begin.

    ****************************************************************/


	// Read in noise file names.
	vector<string> NoiseFileNames;
	ifstream fpin;
	fpin.open(PS[NoiseFiles]);
	while (fpin >> tmpstr){
		NoiseFileNames.push_back(tmpstr);
	}
	fpin.close();


	// Chose a random noise for each trace.
	int nptsx=filenr(PS[FileList].c_str());
	int *WhichNoise=(int *)malloc(nptsx*sizeof(int));

	std::default_random_engine generator;
	generator.seed(time(NULL));sleep(1);
	std::uniform_int_distribution<int> distribution1(0,NoiseFileNames.size()-1);
	for (int index1=0;index1<nptsx;index1++){
		WhichNoise[index1]=distribution1(generator);
	}


	// Read in noises.
	int maxl=2000000,rawnpts,nerr,Length=0;
	float rawbeg,rawdel;
	float *amp=(float *)malloc(maxl*sizeof(float));
	char tmpfilename[200];

	vector<float *> Noises;
	vector<int> SignalLength;
	for (size_t index1=0;index1<NoiseFileNames.size();index1++){

		// Read in noise SAC.
		strcpy(tmpfilename,NoiseFileNames[index1].c_str());
		rsac1(tmpfilename,amp,&rawnpts,&rawbeg,&rawdel,&maxl,&nerr,
			  NoiseFileNames[index1].size());
		retrend(0.0,amp,rawnpts,rawbeg);
		normalize(amp,rawnpts);


		// Taper this noise so that it's reasonable to period adding the noise.
		taper(amp,rawnpts,10.0/rawnpts);


		// Push it into the noise set.
		float *NewNoise=(float *)malloc(rawnpts*sizeof(float));
		for(int index2=0;index2<rawnpts;index2++){
			NewNoise[index2]=amp[index2];
		}

		Noises.push_back(NewNoise);
		SignalLength.push_back(rawnpts);
		if (Length<rawnpts){
			Length=rawnpts;
		}
	}

	// For each signal, assign a random start ponit.

	int *Random_Begin=new int [nptsx];


	generator.seed(time(NULL));sleep(1);
	std::uniform_int_distribution<int> distribution2(0,Length-1);
	for (int index1=0;index1<nptsx;index1++){
		Random_Begin[index1]=distribution2(generator);
		Random_Begin[index1]%=SignalLength[WhichNoise[index1]];
	}


	// For each signal, assign a random/fixed noise level.
	double *NL=new double [nptsx];
	if (PI[UniformNoise]!=1){
		random_num(NL,nptsx);
		for (int index1=0;index1<nptsx;index1++){
			NL[index1]*=P[NoiseLevel];
		}
	}
	else{
		for (int index1=0;index1<nptsx;index1++){
			NL[index1]=P[NoiseLevel];
		}
	}


	// Main stuff.
	ifstream filelist;
	string infilename;
	double S_amp,AmpScale=1;
	int Position,Polarity;

	filelist.open(PS[FileList]);

	for (int index1=0;index1<nptsx;index1++){

		int Chosen=WhichNoise[index1];
		Length=SignalLength[Chosen];


		// Read in signal, S amplitude.
		filelist >> infilename >> S_amp;
		strcpy(tmpfilename,infilename.c_str());

		rsac1(tmpfilename,amp,&rawnpts,&rawbeg,&rawdel,&maxl,&nerr,
		      infilename.size());


		// Need to rescale the peak to its original amplitude.
		// Note the maximum amplitude may shift time, because we added noise.
		Polarity=max_amp(amp,rawnpts,&Position);
		double y=Noises[Chosen][(Random_Begin[index1]+Position)%Length];
		AmpScale=1.0/(1-Polarity*y*NL[index1]);
		S_amp=Polarity*amp[Position];


		// Add noise.
		for (int index2=0;index2<rawnpts;index2++){
			amp[index2]+=Noises[Chosen][(Random_Begin[index1]+index2)%Length]
			             *NL[index1]*S_amp*AmpScale;
			amp[index2]/=AmpScale;
		}


		// Output modified signal.
		wsac1(tmpfilename,amp,&rawnpts,&rawbeg,&rawdel,&nerr,infilename.size());

	}
	filelist.close();

    return 0;
}
