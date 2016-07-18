#include<iostream>
#include<fstream>
#include<sstream>
#include<cstdio>
#include<cstdlib>
#include<vector>
#include<string>
#include<cstring>
extern "C"{
#include<sac.h>
#include<sacio.h>
#include<ASU_tools.h>
}

using namespace std;

int main(int argc, char **argv){

    enum PIenum{FLAG1};
    enum PSenum{FileList,NoiseFile,FLAG2};
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

	int nptsx=filenr(PS[FileList].c_str());

	// Read in noise.

	int maxl=2000000,rawnpts,rawnpts_noise,nerr;
	float rawbeg,rawdel;

	float *noise=(float *)malloc(maxl*sizeof(float));
	int *random_begin=(int *)malloc(nptsx*sizeof(int));
	char tmpfilename[200];

	strcpy(tmpfilename,PS[NoiseFile].c_str());
	rsac1(tmpfilename,noise,&rawnpts_noise,&rawbeg,&rawdel,&maxl,&nerr,PS[NoiseFile].size());
	retrend(0.0,noise,rawnpts_noise,rawbeg);
	normalize(noise,rawnpts_noise);
	random_int(0,rawnpts_noise-1,random_begin,nptsx);

	// Read in file and add noise and output.
	ifstream filelist;
	string infilename;

	float *amp=(float *)malloc(maxl*sizeof(float));
	double S_amp;

	filelist.open(PS[FileList]);

	for (int index1=0;index1<nptsx;index1++){

		filelist >> infilename >> S_amp;
		strcpy(tmpfilename,infilename.c_str());

		rsac1(tmpfilename,amp,&rawnpts,&rawbeg,&rawdel,&maxl,&nerr,infilename.size());

		for (int index2=0;index2<rawnpts;index2++){
			amp[index2]+=noise[(random_begin[index1]+index2)%rawnpts_noise]*P[NoiseLevel]*S_amp;
		}

		wsac1(tmpfilename,amp,&rawnpts,&rawbeg,&rawdel,&nerr,infilename.size());

	}
	filelist.close();

    return 0;
}
