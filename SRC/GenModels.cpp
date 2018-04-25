#include<iostream>
#include<fstream>
#include<sstream>
#include<cstdio>
#include<cstdlib>
#include<vector>
#include<string>
#include<cmath>

#include<PointInPolygon.hpp>

using namespace std;

int main(int argc, char **argv){

    enum PIenum{input1,FLAG1};
    enum PSenum{input2,FLAG2};
    enum Penum{input3,input4,FLAG3};

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
		cerr << "In C++: Ints name count error!" << endl;
		return 1;
	}
	if (FLAG2!=string_num){
		cerr << "In C++: Strings name count error!" << endl;
		return 1;
	}
	if (FLAG3!=double_num){
		cerr << "In C++: Doubles name count error!" << endl;
		return 1;
	}

	string InputTmpStr;
	int InputTmpInt,InputTmpCnt;
	double InputTmpDouble;

	InputTmpCnt=0;
	while (getline(cin,InputTmpStr)){
		++InputTmpCnt;
		stringstream ss(InputTmpStr);
		if (InputTmpCnt<=int_num){
			if (ss >> InputTmpInt && ss.eof()){
				PI.push_back(InputTmpInt);
			}
			else{
				cerr << "In C++: Ints reading Error !" << endl;
				return 1;
			}
		}
		else if (InputTmpCnt<=int_num+string_num){
			PS.push_back(InputTmpStr);
		}
		else if (InputTmpCnt<=int_num+string_num+double_num){
			if (ss >> InputTmpDouble && ss.eof()){
				P.push_back(InputTmpDouble);
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
	if (InputTmpCnt!=int_num+string_num+double_num){
		cerr << "In C++: Not enough inputs !" << endl;
		return 1;
	}


	cout << "C++ Inputs are:" << endl;
	for (auto i: PI){
		cout << i << endl;
	}
	for (auto i: PS){
		cout << i << endl;
	}
	for (auto i: P){
		cout << i << endl;
	}
	return 1;

    /****************************************************************

                              Job begin.

    ****************************************************************/

    return 0;
}
