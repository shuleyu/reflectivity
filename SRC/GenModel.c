#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<ASU_tools.h>

// Model Q for P:

// double qp(double depth){
//     if ( 0<=depth && depth<=15 ) {
//         return 180;
//     }
//     else if ( 15<depth && depth<=600 ) {
//         return 322;
//     }
//     else if ( 600<depth && depth<=670 ) {
//         return 322+1.0*(702-322)/70.0*(depth-600);
//     }
//     else if ( 670<depth && depth<=2891 ) {
//         return 702;
//     }
//     else {
//         return 10000.0;
//     }
// }

// PREM Q for P:

double qp(double depth){
    if ( 0<=depth && depth<=15 ) {
        return 180;
    }
    else if ( 15<depth && depth<=600 ) {
        return 322;
    }
    else if ( 600<depth && depth<=670 ) {
        return 322+1.0*(702-322)/70.0*(depth-600);
    }
    else if ( 670<depth && depth<=2891 ) {
        return 702;
    }
    else {
        return 10000.0;
    }
}

// Model Q for S:

// double qs(double depth){
//     if ( 0<=depth && depth<=24.4 ) {
//         return 150;
//     }
//     else if ( 24.4<depth && depth<=220 ) {
//         return 150+1.0*(183-150)/(220-24.4)*(depth-24.4);
//     }
//     else if ( 220<depth && depth<=670 ) {
//         return 183;
//     }
//     else if ( 670<depth && depth<=2891 ) {
//         return 312;
//     }
//     else if ( 2891<depth && depth<=5149.5 ) {
//         return 1.0;
//     }
//     else {
//         return 5000.0;
//     }
// }

// PREM Q for S:

double qs(double depth){
    if ( 0<=depth && depth<=24.4 ) {
        return 150;
    }
    else if ( 24.4<depth && depth<=220 ) {
        return 150+1.0*(183-150)/(220-24.4)*(depth-24.4);
    }
    else if ( 220<depth && depth<=670 ) {
        return 183;
    }
    else if ( 670<depth && depth<=2891 ) {
        return 312;
    }
    else if ( 2891<depth && depth<=5149.5 ) {
        return 1.0;
    }
    else {
        return 5000.0;
    }
}

int InsertToDiscon(double *p,int npts,double newval){
    int count,count2;

    for (count=0;count<npts;count++){
        if (p[count]==newval){
            return -1;
        }

        if (p[count]>newval){
            for (count2=npts;count2>count;count2--){
                p[count2]=p[count2-1];
            }
            p[count]=newval;
            return 1;
        }
    }
    p[npts]=newval;
    return 1;
}

int main(int argc, char **argv){

    // Deal with inputs.
    int    int_num,string_num,double_num,count;
    int    *PI;
    char   **PS;
    double *P;

    enum PIenum {RaypN,NPTS,M1,M2,LayerN,RemoveCrust,Remove220,Remove400,Remove670,PREM_X};
    enum PSenum {Model,PREM,Model_Out,Suffix,tmpfile_1,tmpfile_2,tmpfile_reflzone};
    enum Penum  {strike,dip,rake,EVDE,AZMIN,AZMAX,AZINC,DISTMIN,DISTMAX,DISTINC,REDE,BEGIN,V1,V2,V3,V4,F1,F2,F3,F4,ATTEN,DELTA,M3,M4,OMARKER,VRED,LayerInc,ReflDepth};

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
    FILE   *fpout,*fpmodel,*fpref,*fptmp1,*fptmp2,*fprefl;
    int    AZN,DISTN,count2,count3,position,PREM_Discon,Model_Discon,PREM_Anchor,Model_Anchor,PREM_Rollback,Model_Rollback,position2,position3,isdiscon,isanchor,rollback,flag,flag2,reflindex,Total;
    double kmperdeg,realaz,*RollbackDepth,*DisconDepth,*AnchorDepth,*height,*vp1,*vp2,*vs1,*vs2,*rho1,*rho2,h;
    double RHO,VP,VS,QP,QS,tmp1,tmp2,tmp3,tmp4,tmp5,dvp,dvs,drho,change,topdepth,downdepth,h_refl,VP_refl,VS_refl,VS_refl_model,VP_refl_model;

	if (PI[PREM_X]==1) PI[RemoveCrust]=PI[Remove220]=PI[Remove400]=PI[Remove670]=1;

	Total=2*PI[RemoveCrust]+PI[Remove220]+PI[Remove400]+PI[Remove670];
    PREM_Discon=8-Total;
    PREM_Anchor=0;
    PREM_Rollback=PREM_Anchor+PREM_Discon;

    DisconDepth=(double *)malloc((PREM_Discon+2*PI[LayerN])*sizeof(double));
    AnchorDepth=(double *)malloc((PREM_Anchor+2*PI[LayerN])*sizeof(double));
    RollbackDepth=(double *)malloc((PREM_Rollback+2*PI[LayerN])*sizeof(double));

    DisconDepth[0]=0;
    RollbackDepth[0]=0;

	if (PI[RemoveCrust]==0){
		DisconDepth[1]=15.0;
		DisconDepth[2]=24.4;
		RollbackDepth[1]=15.0;
		RollbackDepth[2]=24.4;
	}
	if (PI[Remove220]==0){
		DisconDepth[3-2*PI[RemoveCrust]]=220.0;
		RollbackDepth[3-2*PI[RemoveCrust]]=220.0;
	}
	if (PI[Remove400]==0){
		DisconDepth[4-2*PI[RemoveCrust]-PI[Remove220]]=400.0;
		RollbackDepth[4-2*PI[RemoveCrust]-PI[Remove220]]=400.0;
	}
	if (PI[Remove670]==0){
		DisconDepth[5-2*PI[RemoveCrust]-PI[Remove220]-PI[Remove400]]=670;
		RollbackDepth[5-2*PI[RemoveCrust]-PI[Remove220]-PI[Remove400]]=670;
	}

    DisconDepth[6-Total]=2891;
    DisconDepth[7-Total]=5149.5;
    RollbackDepth[6-Total]=2891;
    RollbackDepth[7-Total]=5149.5;

    kmperdeg=111.195;

    height=(double *)malloc(PI[LayerN]*sizeof(double));
    vp1=(double *)malloc(PI[LayerN]*sizeof(double));
    vp2=(double *)malloc(PI[LayerN]*sizeof(double));
    vs1=(double *)malloc(PI[LayerN]*sizeof(double));
    vs2=(double *)malloc(PI[LayerN]*sizeof(double));
    rho1=(double *)malloc(PI[LayerN]*sizeof(double));
    rho2=(double *)malloc(PI[LayerN]*sizeof(double));

    // Deal with parameters and station position.

    fpout=fopen(PS[Suffix],"w");
    fptmp1=fopen(PS[tmpfile_1],"w");
    fptmp2=fopen(PS[tmpfile_2],"w");
    fprefl=fopen(PS[tmpfile_reflzone],"w");

    AZN=(int)floor((P[AZMAX]-P[AZMIN])/P[AZINC])+1;
    DISTN=(int)floor((P[DISTMAX]-P[DISTMIN])/P[DISTINC])+1;
    P[AZMAX]=P[AZMIN]+P[AZINC]*(AZN-1);
    P[DISTMAX]=P[DISTMIN]+P[DISTINC]*(DISTN-1);

    // Properties of the source.
    fprintf(fpout,"%10.4lf\n",P[REDE]);
    fprintf(fpout,"%10.4lf%10.4lf%10.4lf%10.4lf%10.4lf\n",0.0,0.0,P[EVDE],P[OMARKER],1.0);
    fprintf(fpout,"%10.4lf%10.4lf%10.4lf\n",P[strike],P[dip],P[rake]);
    fprintf(fpout,"%10.4lf%10.4lf%10.4lf%10.4lf%10d\n",P[DISTMIN]*kmperdeg,P[DISTMAX]*kmperdeg,kmperdeg,0.0,AZN*DISTN);

    // Station distances.
    count=0;
    for (count2=0;count2<AZN;count2++){
        for (count3=0;count3<DISTN;count3++){
            fprintf(fpout,"%10.4lf",(P[DISTMIN]+P[DISTINC]*count3)*kmperdeg);
            fprintf(fptmp1,"%10.4lf\n",P[DISTMIN]+P[DISTINC]*count3);
            count++;
            if (count%8==0){
                fprintf(fpout,"\n");
            }
        }
    }
    if (count%8!=0){
        fprintf(fpout,"\n");
    }

    // Station azimuths.
    count=0;
    for (count2=0;count2<AZN;count2++){
        for (count3=0;count3<DISTN;count3++){
            realaz=P[AZMIN]+P[AZINC]*count2;
            realaz=(realaz>360)?(realaz-360):realaz;
            fprintf(fpout,"%10.4lf",realaz);
            fprintf(fptmp2,"%10.4lf\n",realaz);
            count++;
            if (count%8==0){
                fprintf(fpout,"\n");
            }
        }
    }
    if (count%8!=0){
        fprintf(fpout,"\n");
    }

    // Calculation details.
    fprintf(fpout,"%10.4lf%10.4lf\n",P[VRED],P[BEGIN]);
    fprintf(fpout,"%10.4lf%10.4lf%10.4lf%10.4lf%10d\n",P[V1],P[V2],P[V3],P[V4],PI[RaypN]);
    fprintf(fpout,"%10.4lf%10.4lf%10.4lf%10.4lf%10.4lf\n",P[F1],P[F2],P[F3],P[F4],P[ATTEN]);
    fprintf(fpout,"%10.4lf%10d%10d%10d%10.4lf%10.4lf\n",P[DELTA],PI[NPTS],PI[M1],PI[M2],P[M3],P[M4]);

    fclose(fpout);
    fclose(fptmp1);
    fclose(fptmp2);

    // Deal with model.

    fpmodel=fopen(PS[Model],"r");
    fpref=fopen(PS[PREM],"w");
    fpout=fopen(PS[Model_Out],"w");

    for (count=0;count<PI[LayerN];count++){
        fscanf(fpmodel,"%lf%lf%lf%lf%lf%lf%lf",&height[count],&vp1[count],&vp2[count],&vs1[count],&vs2[count],&rho1[count],&rho2[count]);
    }
    fclose(fpmodel);

    // change is the top layer of all the perturbations.
    change=2891.0;
    for (count=0;count<PI[LayerN];count++){
        change-=height[count];
    }

    // Account for discontinuity and anchor point introduced by properties change.
    Model_Discon=PREM_Discon;
    Model_Anchor=PREM_Anchor;
    Model_Rollback=PREM_Rollback;
    downdepth=change;

    for (count=0;count<PI[LayerN];count++){
        topdepth=downdepth;
        downdepth=topdepth+height[count];

        if (InsertToDiscon(RollbackDepth,Model_Rollback,downdepth)==1){
            Model_Rollback++;
        }
        if (InsertToDiscon(RollbackDepth,Model_Rollback,topdepth)==1){
            Model_Rollback++;
        }

        if (vp1[count]!=vp2[count] || vs1[count]!=vs2[count] || rho1[count]!=rho2[count] ){
            if (InsertToDiscon(AnchorDepth,Model_Anchor,downdepth)==1){
                Model_Anchor++;
            }
        }

        if (count==0){
            if ( vp2[count]!=1.0 || vs2[count]!=1.0 || rho2[count]!=1.0 ){
                if (InsertToDiscon(DisconDepth,Model_Discon,topdepth)==1){
                    Model_Discon++;
                }
            }
            if (PI[LayerN]>1){
                if ( vp1[count]!=vp2[count+1]  || vs1[count]!=vs2[count+1] || rho1[count]!=rho2[count+1] ){
                    if (InsertToDiscon(DisconDepth,Model_Discon,downdepth)==1){
                        Model_Discon++;
                    }
                }
            }
        }
        if(count==PI[LayerN]-1){
            if ( vp1[count]!=1.0 || vs1[count]!=1.0 || rho1[count]!=1.0 ){
                if (InsertToDiscon(DisconDepth,Model_Discon,downdepth)==1){
                    Model_Discon++;
                }
            }
            if (PI[LayerN]>1){
                if ( vp2[count]!=vp1[count-1]  || vs2[count]!=vs1[count-1] || rho2[count]!=rho1[count-1] ){
                    if (InsertToDiscon(DisconDepth,Model_Discon,downdepth)==1){
                        Model_Discon++;
                    }
                }
            }
        }
        if (0<count && count<PI[LayerN]-1){
            if ( vp2[count]!=vp1[count-1] || vs2[count]!=vs1[count-1] || rho2[count]!=rho1[count-1] ){
                if (InsertToDiscon(DisconDepth,Model_Discon,topdepth)==1){
                    Model_Discon++;
                }
            }
            if ( vp1[count]!=vp2[count+1] || vs1[count]!=vs2[count+1] || rho1[count]!=rho2[count+1] ){
                if (InsertToDiscon(DisconDepth,Model_Discon,downdepth)==1){
                    Model_Discon++;
                }
            }
        }
    }
// for (count=0;count<Model_Discon;count++){
//     printf("Model_Discon:%lf\n",DisconDepth[count]);
// }
// for (count=0;count<Model_Anchor;count++){
//     printf("Model_Anchor:%lf\n",AnchorDepth[count]);
// }
// for (count=0;count<Model_Rollback;count++){
//     printf("Model_Rollback:%lf\n",RollbackDepth[count]);
// }

    h=0;
    reflindex=-1;
    position=0;
    position2=0;
    position3=0;

    while ( h<6171.0 ){

        if ( h>=RollbackDepth[position3] && position3 < Model_Rollback ) {
            h=RollbackDepth[position3];
            position3++;
        }

        if ( h>=DisconDepth[position] && position < Model_Discon ) {
            isdiscon=1;
            position++;
        }
        else{
            isdiscon=0;
        }

        if ( h>=AnchorDepth[position2] && position2 < Model_Anchor) {
            isanchor=1;
            position2++;
        }
        else{
            isanchor=0;
        }

		if (PI[PREM_X]==1){
			prem_x(h,&RHO,&VP,&tmp1,&VS,&tmp2,&tmp3,&tmp4,&tmp5);
		}
		else {
			prem_smoothed(h,&RHO,&VP,&tmp1,&VS,&tmp2,&tmp3,&tmp4,&tmp5,PI[RemoveCrust],PI[Remove220],PI[Remove400],PI[Remove670]);
		}

        if (VS<0.001){
            VS=0.001;
        }
        QP=qp(h);
        QS=qs(h);

        if (change<h && h<=2891.0){
            tmp1=h-change;
            tmp2=0;
            for (count=0;count<PI[LayerN];count++){
                tmp2+=height[count];
                if (tmp1<=tmp2){
                    dvp=vp2[count]-(vp2[count]-vp1[count])/height[count]*(tmp1-tmp2+height[count]);
                    dvs=vs2[count]-(vs2[count]-vs1[count])/height[count]*(tmp1-tmp2+height[count]);
                    drho=rho2[count]-(rho2[count]-rho1[count])/height[count]*(tmp1-tmp2+height[count]);
                    if ( vp1[count]!=vp2[count] || vs1[count]!=vs2[count] || rho1[count]!=rho2[count] ) {
                        flag=1;
                    }
                    break;
                }
            }
        }
        else{
            flag=0;
            dvp=1;
            dvs=1;
            drho=1;
        }

        if (isanchor==1 || flag==1 ){
            fprintf(fpref,"%10.4lf%10.4lf%10.2lf%10.4lf%10.3lf%10.4lf%10d\n",h,VP,QP,VS,QS,RHO,5);
            fprintf(fpout,"%10.4lf%10.4lf%10.2lf%10.4lf%10.3lf%10.4lf%10d\n",h,VP*dvp,QP,VS*dvs,QS,RHO*drho,5);
        }
        else if (h>0){
            fprintf(fpref,"%10.4lf%10.4lf%10.2lf%10.4lf%10.3lf%10.4lf%10d\n",h,VP,QP,VS,QS,RHO,1);
            fprintf(fpout,"%10.4lf%10.4lf%10.2lf%10.4lf%10.3lf%10.4lf%10d\n",h,VP*dvp,QP,VS*dvs,QS,RHO*drho,1);
        }

        if(isdiscon==1){
            h+=0.001;

			if (PI[PREM_X]==1){
				prem_x(h,&RHO,&VP,&tmp1,&VS,&tmp2,&tmp3,&tmp4,&tmp5);
			}
			else {
				prem_smoothed(h,&RHO,&VP,&tmp1,&VS,&tmp2,&tmp3,&tmp4,&tmp5,PI[RemoveCrust],PI[Remove220],PI[Remove400],PI[Remove670]);
			}

            if (VS<0.001){
                VS=0.001;
            }
            QP=qp(h);
            QS=qs(h);

            if (change<h && h<=2891.0){
                tmp1=h-change;
                tmp2=0;
                for (count=0;count<PI[LayerN];count++){
                    tmp2+=height[count];
                    if (tmp1<=tmp2){
                        dvp=vp2[count]-(vp2[count]-vp1[count])/height[count]*(tmp1-tmp2+height[count]);
                        dvs=vs2[count]-(vs2[count]-vs1[count])/height[count]*(tmp1-tmp2+height[count]);
                        drho=rho2[count]+(rho2[count]-rho1[count])/height[count]*(tmp1-tmp2+height[count]);
                        break;
                    }
                }
            }
            else{
                dvp=1;
                dvs=1;
                drho=1;
            }

            h-=0.001;

            fprintf(fpref,"%10.4lf%10.4lf%10.2lf%10.4lf%10.3lf%10.4lf%10d\n",h,VP,QP,VS,QS,RHO,0);
            fprintf(fpout,"%10.4lf%10.4lf%10.2lf%10.4lf%10.3lf%10.4lf%10d\n",h,VP*dvp,QP,VS*dvs,QS,RHO*drho,0);
        }

        if (h<=P[ReflDepth]){
            reflindex++;
            flag2=0;

            h_refl=h;
            tmp5=6371.0/(6371.0-h_refl);
            VP_refl=VP*tmp5;
            VS_refl=VS*tmp5;
            VP_refl_model=VP*dvp*tmp5;
            VS_refl_model=VS*dvs*tmp5;
        }

        if (h>P[ReflDepth] && flag2==0){
            flag2=1;
            tmp1=6371.0/(6371.0-h_refl);
            printf("\nLayer @ %.2lf ~ %.2lf km is the first refl. zone layer.\n\n",h_refl,h);

            printf("Velocity (before,after earth-flatening) in the layer right above refl. zone is:\n");
            printf("PREM  Vp / Vs: %.2lf,%.2lf / %.2lf,%.2lf \n",VP_refl,VP_refl*tmp1,VS_refl,VS_refl*tmp1);
            printf("Model Vp / Vs: %.2lf,%.2lf / %.2lf,%.2lf \n\n",VP_refl_model,VP_refl_model*tmp1,VS_refl_model,VS_refl_model*tmp1);

//             if (P[V1]<VS_refl || P[V1]<VS_refl_model){
//                 printf("Warning ! Phase velocity V1 may be too small !\n");
//                 printf("--------- %.3lf < %.3lf (%.3lf)...\n",P[V1],VS_refl,VS_refl_model);
//             }

            printf("Given Phase velocity window is ( V1 / V2 ~ V3 / V4 ): %.2lf / %.2lf ~ %.2lf / %.2lf. \n",P[V1],P[V2],P[V3],P[V4]);
//             printf("After earth-flatening conversion ( V1 / V2 ~ V3 / V4 ): %.2lf / %.2lf ~ %.2lf / %.2lf. \n",tmp1*P[V1],tmp1*P[V2],tmp1*P[V3],tmp1*P[V4]);
//             tmp1=pow((6371-h_refl),2)/6371.0*M_PI/180.0;
//             printf("According to Rayp Range: %.2lf(V3) ~ %.2lf(V2).\n",tmp1/P[V3],tmp1/P[V2]);

            printf("According to TakeOff Range: \n");
            printf("According to P TakeOff (in deg): %.2lf(V4),%.2lf(V3) ~ %.2lf(V2),%.2lf(V1).\n",
                    180/M_PI*asin(VP_refl/P[V4]*tmp1),180/M_PI*asin(VP_refl/P[V3]*tmp1),180/M_PI*asin(VP_refl/P[V2]*tmp1),180/M_PI*asin(VP_refl/P[V1]*tmp1));
            printf("According to S TakeOff (in deg): %.2lf(V4),%.2lf(V3) ~ %.2lf(V2),%.2lf(V1).\n",
                    180/M_PI*asin(VS_refl/P[V4]*tmp1),180/M_PI*asin(VS_refl/P[V3]*tmp1),180/M_PI*asin(VS_refl/P[V2]*tmp1),180/M_PI*asin(VS_refl/P[V1]*tmp1));

        }

        h+=P[LayerInc];
    }

    fprintf(fprefl,"%d",reflindex);

    fclose(fpout);
    fclose(fpref);
    fclose(fprefl);

    // Free spaces.
    free(DisconDepth);
    free(AnchorDepth);
    free(RollbackDepth);

    free(height);
    free(vp1);
    free(vp2);
    free(vs1);
    free(vs2);
    free(rho1);
    free(rho2);

    for (count=0;count<string_num;count++){
        free(PS[count]);
    }
    free(P);
    free(PI);
    free(PS);
    return 0;
}
