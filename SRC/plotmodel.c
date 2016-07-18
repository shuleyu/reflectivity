#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int main(int argc, char **argv){

    // Deal with inputs.
    int    int_num,string_num,double_num,count;
    int    *PI;
    char   **PS;
    double *P;

    enum PIenum {NPTS};
    enum PSenum {infile,outfile};
//     enum Penum  {};

    int_num=atoi(argv[1]);
    string_num=atoi(argv[2]);
    double_num=atoi(argv[3]);

    PI=(int *)malloc(int_num*sizeof(int));
    PS=(char **)malloc(string_num*sizeof(char *));
    P=(double *)malloc(double_num*sizeof(double));

    for (count=0;count<string_num;count++){
        PS[count]=(char *)malloc(200*sizeof(char *));
    }

    for (count=0;count<int_num;count++){
        if (scanf("%d",PI+count)!=1){
            printf("In C : Int parameter reading Error !\n");
            return 1;
        }
    }

    for (count=0;count<string_num;count++){
        if (scanf("%s",PS[count])!=1){
            printf("In C : String parameter reading Error !\n");
            return 1;
        }
    }

    for (count=0;count<double_num;count++){
        if (scanf("%lf",P+count)!=1){
            printf("In C : Double parameter reading Error !\n");
            return 1;
        }
    }

    // Job begin.
    int    *LayerN,count2;
    FILE   *fpin,*fpout;
    double *depth,*vp,*vs,*rho,d;
    depth=(double *)malloc(PI[NPTS]*sizeof(double));
    vp=(double *)malloc(PI[NPTS]*sizeof(double));
    vs=(double *)malloc(PI[NPTS]*sizeof(double));
    rho=(double *)malloc(PI[NPTS]*sizeof(double));
    LayerN=(int *)malloc(PI[NPTS]*sizeof(int));

    fpin=fopen(PS[infile],"r");
    for (count=0;count<PI[NPTS];count++){
        fscanf(fpin,"%lf%lf%*lf%lf%*lf%lf%d",&depth[count],&vp[count],&vs[count],&rho[count],&LayerN[count]);
    } 
    fclose(fpin);

    fpout=fopen(PS[outfile],"w");
    for (count=0;count<PI[NPTS];count++){
        if (LayerN[count]>1){
            for (count2=1;count2<=LayerN[count];count2++){
                d=1.0*count2/LayerN[count];
                fprintf(fpout,"%lf\t%lf\t%lf\t%lf\n",depth[count-1]+(depth[count]-depth[count-1])*d,vp[count-1]+(vp[count]-vp[count-1])*d,vs[count-1]+(vs[count]-vs[count-1])*d,rho[count-1]+(rho[count]-rho[count-1])*d);
            }
        }
        else{
            fprintf(fpout,"%lf\t%lf\t%lf\t%lf\n",depth[count],vp[count],vs[count],rho[count]);
        }
    }

    // Free spaces.
    free(depth);
    free(vp);
    free(vs);
    free(rho);
    free(LayerN);
    for (count=0;count<string_num;count++){
        free(PS[count]);
    }
    free(P);
    free(PI);
    free(PS);
    return 0;
}
