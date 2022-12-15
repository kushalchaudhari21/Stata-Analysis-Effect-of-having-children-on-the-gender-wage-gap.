clear all
set more off
cd C:\Users\jaker\Documents\MS_in_Economics_and_CS\ECON550_Econometrics\Stata_Project
use usa_00009.dta

log using "FinalProjectLog_ChaudhariKasroviReichlin.txt", replace text

*Drop unused variables
drop educ classwkr

*Missing Values
replace ftotinc = . if ftotinc == 9999999
replace incwage = . if incwage >= 999998 | incwage == 0
replace classwkrd = . if classwkrd == 0
replace occ = . if occ == 0 | occ >= 9800
numlabel, add

*Recode marital status as a dummy variable
tab marst
recode marst (1/2=1) (3/6=0)
label drop MARST
label define MARST 0 "Single" 1 "Married"
rename marst married

*Recode sex FEMALE=1 MALE=0
tab sex
recode sex (1=0) (2=1)
label dir
label drop SEX
label define SEX 0 "Male" 1 "Female"
rename sex female

recode metro(0=1) (2/4=1) (1=0)
label drop METRO
label define METRO 0 "Not in/near metropolitan area" 1 "In/near metropolitan area"
tab metro

*Recode education as categorical variable
tab educd
recode educd (2/26=0) (30/61=1) (63/64=2) (65/71=3) (81=4) (101=5) (114=6) (115=7) (116=8)
label drop EDUCD
label define EDUCD 0 "No HS" 1 "Some HS" 2 "HS Diploma or Equivalent" 3 "Some College" 4 "Associates Degree" 5 "Bachelor's Degree" 6 "Master's Degree" 7 "Professional Degree" 8 "Doctoral Degree"
rename educd educ_simple
tab educ_simple

*Recode nchild as dummy variable 0=No children present 1 = at least 1 child present
recode nchild (0=0) (1/9=1), gen(child_pres)
label define Child_pres 0 "No children" 1 "At least 1 child"
label values child_pres Child_pres


recode nchlt5 (0=0) (1/9=1), gen(chlt5_pres)
label define Chlt5_pres 0 "No children under 5" 1 "At least 1 child under 5"
label values chlt5_pres Chlt5_pres

keep if age >= 25 & age <= 54


*------------------------------Regressions Without Sample Restrictions-------------------------*

*RESET MISSPECIFICATION TEST
reghdfe incwage age metro uhrswork married i.female##i.child_pres, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

predict yhat if e(sample)

reghdfe incwage age metro uhrswork married i.female##i.child_pres c.yhat#c.yhat c.yhat#c.yhat#c.yhat, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

test _b[c.yhat#c.yhat] = _b[c.yhat#c.yhat#c.yhat] = 0

*Model 1
reghdfe incwage married i.female##i.child_pres age c.age#c.age metro uhrswork, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

*Model 2
reghdfe incwage married i.female##i.chlt5_pres nchild age c.age#c.age metro uhrswork, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

*------------------------------Regressions With Sample Restrictions-------------------------*
*Sample Restriction 1
sum incwage, detail
gen incwage_p1 = .
replace incwage_p1 = incwage if incwage > r(p1) & incwage < r(p99)

reghdfe incwage_p1 married i.female##i.child_pres age c.age#c.age metro uhrswork, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

reghdfe incwage_p1 married i.female##i.chlt5_pres nchild age c.age#c.age metro uhrswork, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

sum incwage_p1 if e(sample), detail

drop incwage_p1

*Sample Restriction 2
sum incwage, detail
gen incwage_p5 = .
replace incwage_p5 = incwage if incwage > r(p5) & incwage < r(p95)

reghdfe incwage_p5 married i.female##i.child_pres age c.age#c.age metro uhrswork, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

reghdfe incwage_p5 married i.female##i.chlt5_pres nchild age c.age#c.age metro uhrswork, absorb(i.occ i.educ_simple i.classwkrd) vce(robust)

sum incwage_p5 if e(sample), detail

log close