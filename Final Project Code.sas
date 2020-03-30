/*Final Project Code for Promotional Effectiveness (Shoprite)
BIA 672-A Marketing Analytics
Guided by Professor Khasha Dehnad
Authors : Mohit Mhapuskar & Nipun Gupta*/
libname sasdata "G:\Classwork\BIA-672\SAS\SAS_DATA"; run;

%macro drive(dir,ext); 
   %local cnt filrf rc did memcnt name; 
   %let cnt=0;          

   %let filrf=mydir;    
   %let rc=%sysfunc(filename(filrf,&dir)); 
   %let did=%sysfunc(dopen(&filrf));
    %if &did ne 0 %then %do;   
   %let memcnt=%sysfunc(dnum(&did));    

    %do i=1 %to &memcnt;              
                       
      %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);                    
                    
      %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&name) %then %do;
       %if %superq(ext) = %superq(name) %then %do;                         
          %let cnt=%eval(&cnt+1);       
          %put %qsysfunc(dread(&did,&i));  
          proc import datafile="&dir\%qsysfunc(dread(&did,&i))" out=data&cnt 
           dbms=csv replace;            
          run;          
       %end; 
      %end;  

    %end;
      %end;
  %else %put &dir cannot be open.;
  %let rc=%sysfunc(dclose(&did));      
             
 %mend drive;
 
%drive(G:\Classwork\BIA-672\Final Project\Promo255, csv)
proc copy in = sasdata out=work;
select beer_sales; run;
/*Combining datasets for the 6 month period*/
data dataset;
   set data1 data2 data3 data4 data5 data6 data7 data8 data9 data10 data11 data12 data13 data14 data15 data16 data17 data18 data19 data20 data21 data22 data23 data24 data25 data26 data27;
run;


/*Creation of dummy variables for storing categorical values*/
data converted;
set dataset;
if (AD_ITM_PRTY_CODE = '0') or (AD_ITM_PRTY_CODE = '4') or (AD_ITM_PRTY_CODE = ' ') then NOT_PROMOTED=1;
else if (AD_ITM_PRTY_CODE = '3') or (AD_ITM_PRTY_CODE = '5') then IN_STORE=1;
else if (AD_ITM_PRTY_CODE = '6') then IN_PAGE_NO_PHOTO=1;
else if (AD_ITM_PRTY_CODE = '7') then IN_PAGE_SMALL_PHOTO=1;
else if (AD_ITM_PRTY_CODE = '8') then IN_PAGE_LARGE_PHOTO=1;
else if (AD_ITM_PRTY_CODE = '9') then FRONT_PAGE=1;
if NOT_PROMOTED=. then NOT_PROMOTED=0;
if IN_STORE=. then IN_STORE=0;
if IN_PAGE_NO_PHOTO=. then IN_PAGE_NO_PHOTO=0;
if IN_PAGE_SMALL_PHOTO=. then IN_PAGE_SMALL_PHOTO=0;
if IN_PAGE_LARGE_PHOTO=. then IN_PAGE_LARGE_PHOTO=0;
if FRONT_PAGE=. then  FRONT_PAGE=0;
run;


/* Creating a dataset of all cereal category sales */
data cereal;
set converted;
if upc_cat_code =41800 ;
run;

/*Analyzing data to find out stores with highest sales within cereal category*/
proc sql;
create table analysis as select
item_num,
sum(TTL_SCAN_DLR_AMNT) as Cereal_Sales
from cereal
group by item_num;
quit;
proc sort data=analysis out=Top_Sales_Cereals;
by descending Cereal_Sales;
run;

/*Creating a dataset of all cereal sales from store 662*/
data cerealstore;
set cereal;
if cust_num=662;
run;

ods graphics on;
/*Regression Model for Cereal*/
title"Promotional Effectiveness for Dollar Sales of Cereals from Store 662";
proc reg data=cerealstore plots(maxpoints=none);
id dscnt_amt digtl_dscnt_amt mixnmtch_dscnt_amt Not_promoted Front_page In_page_large_photo In_page_small_photo In_page_no_photo In_store;
model ttl_scan_dlr_amt = dscnt_amt digtl_dscnt_amt mixnmtch_dscnt_amt Not_promoted Front_page In_page_large_photo In_page_small_photo In_page_no_photo In_store / VIF selection=stepwise slentry=.1 slstay=.1;
run;


/*Creating a dataset of all wholesome pantry category sales*/
data pantry;
set converted;
if upc_cat_code = 40900;
run;

/*Analyzing data to find out stores with highest sales within wholesome pantry category*/
proc sql;
create table temp as select
cust_num,
sum(TLL_SCAN_DLR_AMNT) as Pantry_Sales
from pantry
group by cust_num;
quit;
proc sort data=temp out= Top_Sales_Pantry;
by descending Pantry_Sales;
run;

/*Creating a dataset of all wholesome pantry sales from store 385*/
data pantrystore;
set pantry;
if cust_num=385;
run;

/*Regression Model for Wholesome Pantry*/
title"Promotional Effectiveness for Dollar Sales of Wholesome Pantry from Store 385";
proc reg data=pantrystore plots(maxpoints=none);
id dscnt_amt digtl_dscnt_amt mixnmtch_dscnt_amt Not_promoted Front_page In_page_large_photo In_page_small_photo In_page_no_photo In_store;
model ttl_scan_dlr_amt = dscnt_amt digtl_dscnt_amt mixnmtch_dscnt_amt Not_promoted Front_page In_page_large_photo In_page_small_photo In_page_no_photo In_store / VIF selection=stepwise slentry=.1 slstay=.1;
run;

/*Creating a dataset of all poultry category sales*/
data poultry;
set converted;
if upc_cat_code = 300;
run;

/*Analyzing data to find out stores with highest sales within poultry category*/
proc sql;
create table temp as select
cust_num,
sum(TTL_SCAN_DLR_AMT) as Poultry_Sales
from pantry
group by cust_num;
quit;
proc sort data=temp out= Top_Sales_Poultry;
by descending Poultry_Sales;
run;

/*Creating a dataset of all poultry sales from store 501*/
data poultrystore;
set poultry;
if cust_num=501;
run;

/*Regression Model for Poultry*/
title"Promotional Effectiveness for Dollar Sales of Poultry from Store 501";
proc reg data=poultrystore plots (maxpoints=none);
id dscnt_amt digtl_dscnt_amt mixnmtch_dscnt_amt Not_promoted Front_page In_page_large_photo In_page_small_photo In_page_no_photo In_store;
model ttl_scan_dlr_amt = dscnt_amt digtl_dscnt_amt mixnmtch_dscnt_amt Not_promoted Front_page In_page_large_photo In_page_small_photo In_page_no_photo In_store /VIF selection=stepwise slentry=.1 slstay=.1;
run;
