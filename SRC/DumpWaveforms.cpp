#include<iostream>
#include<fstream>
#include<sstream>
#include<cstdio>
#include<cstdlib>
#include<vector>
#include<string>
#include<cmath>

#include<SACSignals.hpp>
#include<ReadParameters.hpp>

using namespace std;

int main(int argc, char **argv){

    enum PI{FLAG1};
    enum PS{CenterPhase,FileNames,FLAG2};
    enum PF{GCARC_MIN,GCARC_MAX,Time_MIN,Time_MAX,FLAG3};
    auto P=ReadParameters<PI,PS,PF>(argc,argv,cin,FLAG1,FLAG2,FLAG3);

    /****************************************************************

                              Job begin.

    ****************************************************************/

    SACSignals Data(P[FileNames]);
    Data.CheckDist(P[GCARC_MIN],P[GCARC_MAX]);
    Data.CheckAndCutToWindow(Data.GetTravelTimes(P[CenterPhase]),P[Time_MIN],P[Time_MAX]);
    Data.SetBeginTime(P[Time_MIN]);
//     Data.FindPeakAround(vector<double> (Data.size(),0),10);
//     Data.NormalizeToPeak();
    Data.Integrate();
    Data.NormalizeToSignal();
    DumpWaveforms(Data,"./");

    return 0;
}
