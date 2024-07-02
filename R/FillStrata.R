# R Kode for generiske beregning optimal allokering # Test av Oyvind
# Author: Oyvind Langsrud
# Edited by Susie Jentoft and Oyvind Langsrud
# Edited: 14/10-2015, max_n new input, 
# Edited:23/10-2015
#   NEW INPUT: totY,cvLimits,totYgroup, groupNames, returnGroupN,returnGroupn,returnTable,returnTotYgroup,returnVarLimits,returnMulti,returnMatrix
#   Many new possible output
#   Several alternative functions (alias). Most importan is FSmatrix
#   s2=0 problems solved
#   New initial checks (min_n)
# Edited: 13/1-2016: Small change in simPrint
# Edited: 1/3 and 11/3-2016: totnGroup and min_nGroup new input

#' @rdname FillStrata
#' @export
FSmatrix           <- function(s2,N,...) FillStrata(s2=s2,N=N,...,returnMatrix=TRUE)

#' @rdname FillStrata
#' @export
FStotnAlloc        <- function(s2,N,totn,...) FillStrata(s2=s2,N=N,totn=totn,...,returnTable=TRUE)

#' @rdname FillStrata
#' @export
FSvarAlloc         <- function(s2,N,varLimits,group,...)          FillStrata(s2=s2,N=N,varLimits=varLimits,group=group,...)

#' @rdname FillStrata
#' @export
FScvAlloc          <- function(s2,N,totY,cvLimits,group,...)      FillStrata(s2=s2,N=N,totY=totY,cvLimits=cvLimits,group=group,...)

#' @rdname FillStrata
#' @export
FScvAlloc2         <- function(s2,N,totYgroup,cvLimits,group,...) FillStrata(s2=s2,N=N,totYgroup=totYgroup,cvLimits=cvLimits,group=group,...)

#' @rdname FillStrata
#' @export
FSvarLimits        <- function(totY,cvLimits,group,...) FillStrata(totY=totY,cvLimits=cvLimits,group=group,...,s2=rep(0,length(totY)),N=rep(0,length(totY)),returnVarLimits=TRUE)

#' @rdname FillStrata
#' @export
FStotVar           <- function(s2,N,min_n,group,...)      FillStrata(s2=s2,N=N,min_n=min_n,group=group,...,varLimits=Inf)

#' @rdname FillStrata
#' @export
FStotCV            <- function(s2,N,totY,min_n,group,...) FillStrata(s2=s2,N=N,totY=totY,min_n=min_n,group=group,...,cvLimits=Inf)

# Extra wrapper functions. Not included in export at this stage
FSgroupN           <- function(N,group=rep("group1",length(N)),...) FillStrata(N=N,group=group,...,s2=rep(0,length(N)),returnGroupN=TRUE,varLimits=Inf)
FSgroupn           <- function(min_n,group=rep("group1",length(min_n)),N=min_n,...) FillStrata(N=N,min_n=min_n,group=group,...,s2=rep(0,length(N)),returnGroupn=TRUE,varLimits=Inf)
FStotYgroup        <- function(totY,group=rep("group1",length(totY)),...) FillStrata(totY=totY,group=group,...,s2=rep(0,length(totY)),N=rep(0,length(totY)),cvLimits=Inf,returnTotYgroup=TRUE)
FStotVarGroup      <- function(s2,N,min_n,group=rep("group1",length(N)),...) FillStrata(s2=s2,N=N,min_n=min_n,group=group,...,varLimits=Inf)
FStotVarStrata     <- function(s2,N,min_n,group=factor(cbind(names(s2),names(N),1:length(N))[,1]),...) FillStrata(s2=s2,N=N,min_n=min_n,group=group,...,varLimits=Inf)
FStotCVgroup       <- function(s2,N,totY,min_n,group=rep("group1",length(N)),...) FillStrata(s2=s2,N=N,totY=totY,min_n=min_n,group=group,...,cvLimits=Inf)
FStotCVstrata      <- function(s2,N,totY,min_n,group=factor(cbind(names(s2),names(N),1:length(N))[,1]),...) FillStrata(s2=s2,N=N,totY=totY,min_n=min_n,group=group,...,cvLimits=Inf)

FSgroupMulti       <- function(s2,N,totY,min_n,group=rep("group1",length(N)),...) FillStrata(s2=s2,N=N,totY=totY,min_n=min_n,group=group,...,cvLimits=Inf,returnMulti=TRUE)




#' Optimal allocation of sample sizes
#' 
#' This function finds an optimal allocation by filling up strata one unit at a
#' time. This approach works when the variance function of n decreases smoothly
#' (The derivative should be strictly increasing).
#' 
#' @param s2 An estimate for the variance within each strata. For example s2 =
#' c(35, 3, 2, 30, 7)
#' @param N The population size within each strata. For example N = c(100, 100,
#' 500, 50, 150)
#' @param totVar The function for calculating the total variance from s2, n
#' (sample size) and N as inputs.  The function should be able to handle
#' vectors as inputs and give a vector as an output.
#' @param nullcorrection Variance at n=0 is set to nullcorrection times
#' variance at n=1. A large value is needed by the algorithm (not Inf).
#' @param totn The total desired sample size
#' @param min_n A minimum sample size in each stratum. This can be a single
#' number used in all strata or a vector of numbers (one for each stratum).
#' @param use_n Matrix with the same number of columns as there are strata.
#' Each column should contain the desired sample size choices (will accept
#' missing values)
#' @param corrSumVar Logical value giving if the corrected variance should be
#' used. Default is FALSE.
#' @param dotprint Condition to invoke printing of "---------#--------...."
#' during calculations. Default is set for when totn > 1000.
#' @param varLimits The desired maximum variance for each group.  Note: When
#' varLimits is given, a different output value is returned - the sample size
#' that fulfills the required group variance for totVar.  If varLimits = Inf,
#' the output is the group sum of totVar with "n = min_n".
#' @param group A vector or dummy matrix giving the groups to be used with
#' varLimits
#' @param intern Logical value giving if the function is being used internally
#' within this or another function or not. Default is set to FALSE.
#' @param max_n A maximum sample size in each stratum. This can be a single
#' number used in all strata or a vector of numbers (one for each stratum).
#' @param totY Estimate of total Y in each stratum.
#' @param cvLimits The desired maximum CV for each group. This can be a single
#' value or a vector of values.
#' @param totYgroup Estimate of total Y in each group. Alternative instead of
#' totY.
#' @param groupNames Alternative instead of finding group names from other
#' input.
#' @param returnGroupN Logical on whether to return the population group size. 
#' @param returnGroupn Logical on whether to return the sample group size. 
#' @param returnTable Logical on whether to return the table
#' @param returnTotYgroup Logical on whether to return the total Y values
#' @param returnVarLimits Logical on whether to return the  Y limits
#' @param returnMulti Logical on whether to return the multi
#' @param returnMatrix Logical on whether to return the matrix
#' @param totnGroup Maximal total sample size within group (override cvLimits)
#' @param min_nGroup Minimal total sample size within group (override cvLimits)
#' @param ... Additional arguments to be passed to the function.
#' @return The output from \bold{FSmatrix} (FillStrata with returnMatrix=TRUE)
#' is a two-dimensional list.
#' 
#' \item{Column:Strata}{Output values according to each strata.}
#' \item{Column:Group}{Output values according to each group as specified by
#' input.} \item{Column:All}{Output by treating all strata as a single group.}
#' \item{Row:n}{Allocated sample size} \item{Row:N}{Population size}
#' \item{Row:totVar}{Total variance} \item{Row:totY}{Total Y} \item{Row:cv}{CV
#' (\%)} \item{Row:varLimits}{As input (only Group)} \item{Row:cvLimits}{As
#' input or computed from varLimits (only Group)}
#' 
#' The output from \bold{FillStrata} is a list with two elements when varLimits
#' or cvLimits is not used.  \item{filledstrata}{Strata is filled sequentially
#' according to this vector. } \item{sumVar}{Total variance for all values of
#' total n. }
#' 
#' When returnTable=TRUE and when varLimits or cvLimits is used (FStotnAlloc,
#' FSvarAlloc, FScvAlloc, FScvAlloc2) the output is the allocated sample size
#' in each strata.
#' 
#' Other elements of the FSmatrix-output can be obtained by setting other
#' return-parameters to TRUE or by using varLimits=Inf or cvLimits=Inf.
#' @keywords survey
#' 
#' @export
#' 
#' @examples
#'
#' # Examples with 5 strata based on FSmatrix
#'   s2    = c(35, 3, 2, 30, 7)         # Variance estimate
#'   N     = c(100, 100, 500, 50, 150)  # N in each strata
#'   names(N) = paste("st",1:5,sep="")  # Strata-names
#'   totY  = c(8800,900,5500,400,300)   # Totals in each strata
#'   g     = c("grA","grA","grB","grB","grB") # Two groups
#'  

#' # Total sample size of 200 chosen in advance
#'   m = FSmatrix(s2=s2,N=N,totn=200,group=g)
#'   # Three ways of getting allocated n in each strata
#'   m[,1]$n
#'   m[1,]$Strata
#'   m[[1,1]]
#'   
#' # Alloc from varLimits
#'   vL = c(5000,10000)   # variance limits for groups 
#'   m = FSmatrix(s2=s2,N=N,varLimits=vL,group=g)
#'   m[[1,1]] # Allocated n in each strata
#'   m[3,] # Total variance in strata, group (less than limits) and all.
#'   
#' #  Calculate CV from totY in strata from known allocation (20%)
#'   m = FSmatrix(s2=s2,N=N,totY=totY,max_n=round(N/5),group=g)
#'   m[5,] # CV in strata, group and all.
#' 
FillStrata <- function(s2, N, totVar = function(s2, n, N){s2 * N * (N - n) / n}, nullcorrection = 1E20,
                       totn = min(sum(max_n_exact), 20000), min_n = NULL, use_n = NULL, corrSumVar = FALSE, dotprint = totn > 1000,    # max_n-31/8-2015
                       varLimits = NULL, group = rep("All", length(s2)), intern = FALSE, max_n = N,                                        # max_n-31/8-2015
                       totY=NULL,cvLimits=NULL,totYgroup=NULL,groupNames=NULL,
                       returnGroupN=FALSE, returnGroupn=FALSE, returnTable=FALSE,returnTotYgroup=FALSE,returnVarLimits=FALSE,
                       returnMulti=FALSE,returnMatrix=FALSE,totnGroup=NULL,min_nGroup=NULL){    #### Ny 1/3-2016 totnGroup, min_nGroup 11/3-2016
  #initial checks
  if(is.vector(group) & (length(group) != length(s2))) stop("the spesified groups and s2 do not contain the same number of elements")
  if(length(s2) != length(N)) stop("the spesified s2 and N do not contain the same number of elements") 
  if(length(max_n) == 1) max_n <- rep(max_n, length(N))                                                                                # max_n-31/8-2015
  if(length(s2) != length(max_n)) stop("the spesified s2 and max_n do not contain the same number of elements")                        # max_n-31/8-2015
  max_n <- pmin(max_n,N)     # Tillater for h?y verdi av max_n som input                                                               # max_n-31/8-2015
  max_n_exact <- max_n       # Brukes til beregning av default totn                                                                    # max_n-31/8-2015
  
  if(is.null(min_n))    min_n <- 0                                              ###################### NY ENDRING 19/10
  if(length(min_n)==1)  min_n <- rep(min_n, length(N))                          ###                                      
  if(length(s2) != length(min_n)) stop("min_n: wrong number of elements")       ### 
  min_n <- pmin(max_n,min_n)                                                    ###
  
                                                                                                                                        
  #get names for strata levels - new in version 1.1
  if (!is.null(names(s2))) {
    stratanames <- names(s2) 
  } else if (!is.null(names(N))) {
      stratanames <- names(N) 
    } else { stratanames <- 1:length(s2) }
    
  # s2 justering for de med rare verdi og null med min_n
  s2[is.na(s2) | s2 == Inf] <- 0 ### forsikre at det ikke er noen rart i s2 input
  #if (!is.null(min_n)) {   # Problemet er fjernet 6/10-2015
  #  problemS2 <- stratanames[s2 == 0 & N >= 1 & min_n >=1] #endret i versjon1.1
  #  s2[s2 == 0 & N >= 1 & min_n >=1] <- 0.00001 # lagt inn for C% bruke min_n for de med N=1
  #  if (length(problemS2) > 0 & !intern){
  #  warning(paste("\n", "The following strata had an s2 value equal to 0 which has been adjusted to 0.00001 to envoke the required min_n value: ", problemS2, sep=""))
  #  }}
  
  
  
  
  if(!is.null(cvLimits) | !is.null(varLimits) | !is.null(min_nGroup)){  ###########  Flyttet enda høyere opp i ny kode 11/3-2016
    
    # Lager group om til dummymatrise. HVis den ikke er det fra foer.
    if(!is.matrix(group)) {
      group <- makeDummy(group)
    } else {
      if(dim(group)[1] < length(s2)) {  
        group <- makeDummy(group) 
      }
    }
    group <- group == 1  # Gjoer om til TRUE/FALSE
  }  
  
  
  if(!is.null(min_nGroup)){  # Ny 11/3-2016
    if(length(min_nGroup) != dim(group)[2]) stop("Number of elements in min_nGroup is not equal to number of groups")
    for(i in 1:dim(group)[2])	{
      d <- group[,i]
      totni = min_nGroup[i] #### Samme som brukes for totnGroup lenger ned
      max_n_d <-max_n[d]   # Samme som brukes lenger ned
      a <- FillStrata(s2[d], N[d], totVar, nullcorrection, totni, min_n[d], use_n[, d, drop=FALSE], corrSumVar, dotprint, intern = TRUE,max_n=max_n_d)   # max_n-31/8-2015
      ni <- length(a$sumVar)  ### Dvs antallet fra FillStrata   ### max(c(0,which(a$sumVar >= varLimits[i]))) + 1   
      min_n_i <- table(c(1:sum(d), a$filledStrata[1:ni])) - 1 # triks for aa faa med 0
      up <- updateMinN(min_n_i, min_n[d], use_n[, d, drop = FALSE])
      min_n[d] <- up$min_n
      if(!is.null(use_n)) {
        use_n[,d] = up$use_n
      }
   }  
  }
  
  
  if(!is.null(cvLimits) | !is.null(varLimits)){  ###########  Flyttet opp i ny kode 6/10
    if(is.null(groupNames)) groupNames <-colnames(group)
    groupN=NULL
    groupn=NULL
    for(i in 1:dim(group)[2]){
      groupN <- c(groupN, sum(N[group[, i]]))
      groupn <- c(groupn, sum(min_n[group[, i]]))            
    }                  
    names(groupN) <- groupNames 
    names(groupn) <- groupNames 
    if(returnGroupN) return(groupN)
    if(returnGroupn) return(groupn)
    
    totYgroup_ = NULL   ## totYgroup calculated from totY
    for(i in 1:dim(group)[2])	 {
      if(is.null(totY)) sumTotY = NA  else  sumTotY = sum(totY[group[, i]])
      totYgroup_ <- c(totYgroup_,sumTotY)
    }  
    names(totYgroup_) <- groupNames 
    
    if(is.null(totYgroup)){
      totYgroup = totYgroup_
    } else {
      if(!is.null(totY) & !intern) {
        totYgroup_diff =abs((totYgroup_-totYgroup)/totYgroup)
        if(sum(totYgroup_diff, na.rm =TRUE)!=0){
          pdiff = round(100*max(totYgroup_diff, na.rm =TRUE),4)
          if(pdiff>=0.0001)
            warning(paste("Both totY and totYgroup as input: ",pdiff,"% difference.",sep=""))
        }  
      }  
    }
  }  
  
  ###########  Ny kode 6/10
  if(!is.null(cvLimits)){
    if(returnTotYgroup) return(totYgroup)
    if(length(cvLimits)==1) cvLimits = rep(cvLimits,dim(group)[2])
    if(length(cvLimits) != dim(group)[2]) stop("Number of elements in cvLimits is not equal to number of groups")
    
    varLimits=(cvLimits*totYgroup/100)^2
    varLimits[is.na(varLimits)]=Inf
    if(returnVarLimits) return(varLimits)
  } else cvLimits=NA
  #if(is.null(totYgroup)) totYgroup=NA
  
  if(!is.null(varLimits))	{ 
    
    if(min(varLimits) == Inf) { # Beregner varianse innen grupper isteden. totn is now total for each group!!
      # med min_n
     totVarGroup <- NULL
      for(i in 1:dim(group)[2])	 
       #totVarGroup <- c(totVarGroup, sum(totVar(s2[group[, i]], min_n[group[, i]], N[group[, i]])))
      totVarGroup <- c(totVarGroup, sum(corrTotVar(s2[group[, i]], min_n[group[, i]], N[group[, i]],nullcorrection, totVar)))  ### Bruker corrTotVar endring 19/10-15 
      
      
      names(totVarGroup) <- groupNames 
      cv = 100*sqrt(totVarGroup)/totYgroup
      if(returnMulti|returnMatrix) 
        list2 = list(groupn=groupn,groupN=groupN,totVarGroup=totVarGroup,totYgroup=totYgroup,cv=cv)
      if(returnMulti)  return(list2)
      if(returnMatrix) 
      {
        list1 = 
          FillStrata(s2=s2,N=N,totVar=totVar,nullcorrection=nullcorrection,totn=totn,min_n=min_n,use_n=use_n,corrSumVar=corrSumVar,
                     dotprint=dotprint,varLimits=Inf,intern=TRUE,max_n=max_n,totY=totY,cvLimits=Inf,
                     group=factor(stratanames,levels=stratanames),returnMulti=TRUE,totYgroup=NULL)  # totYgroup må IKKE med 
        
        list3 = 
          FillStrata(s2=s2,N=N,totVar=totVar,nullcorrection=nullcorrection,totn=totn,min_n=min_n,use_n=use_n,corrSumVar=corrSumVar,
                     dotprint=dotprint,varLimits=Inf,intern=TRUE,max_n=max_n,totY=totY,cvLimits=Inf,
                     group=rep("all",length(N)),returnMulti=TRUE,totYgroup=NULL)  # totYgroup må IKKE med 
        
        list1 = c(list1,list(varLimits=NA,cvLimits=NA))
        list2 = c(list2,list(varLimits=varLimits,cvLimits=cvLimits))
        list3 = c(list3,list(varLimits=NA,cvLimits=NA))
        
        out = cbind(list1,list2,list3)
        #"groupn"      "groupN"      "totVarGroup" "totYgroup"   "cv"          "varLimits"   "cvLimits" 
        rownames(out) = c("n","N","totVar","totY","cv","varLimits","cvLimits")
        colnames(out) = c("Strata","Group","All")
        return(out)
      }  
      
      if( sum(!is.na(cvLimits))==0 ) return(totVarGroup) # totvar in groups returned
      return(cv)
      
    }
    if(length(varLimits) != dim(group)[2]) stop("Number of elements in varLimits is not equal to number of groups")
    for(i in 1:dim(group)[2])	{
      d <- group[,i]
      if(is.null(totnGroup)) totni = totn    #### Ny 1/3-2016 totnGroup
      else totni = totnGroup[i]              #### Ny 1/3-2016 totnGroup
      max_n_d <-max_n[d]   # Tar dette med for ? hindre navneproblemer(?) i input  # max_n-31/8-2015
      a <- FillStrata(s2[d], N[d], totVar, nullcorrection, totni, min_n[d], use_n[, d, drop=FALSE], corrSumVar, dotprint, intern = TRUE,max_n=max_n_d)   # max_n-31/8-2015
      ni <- max(c(0,which(a$sumVar >= varLimits[i]))) + 1
      
      min_n_i <- table(c(1:sum(d), a$filledStrata[1:ni])) - 1 # triks for aa faa med 0
      up <- updateMinN(min_n_i, min_n[d], use_n[, d, drop = FALSE])
      min_n[d] <- up$min_n
      if(!is.null(use_n)) {
        use_n[,d] = up$use_n
      }
    }
    usemin <- rbind(use_n, min_n)
    if(!is.null(usemin)) {
      for(i in 1:dim(usemin)[2]) min_n[i] <- min(usemin[, i], na.rm = TRUE)
    }
    if (!intern) names(min_n) <- stratanames #new v1.1
    
    if(returnMatrix){
      out = FillStrata(s2=s2,N=N,totVar=totVar,nullcorrection=nullcorrection,totn=totn,min_n=min_n,use_n=use_n,corrSumVar=corrSumVar,
                 dotprint=dotprint,varLimits=Inf,intern=TRUE,max_n=max_n,totY=totY,cvLimits=Inf,
                 group=group,returnMatrix=TRUE,totYgroup=totYgroup) 
      out[,2]$varLimits=varLimits
      out[,2]$cvLimits=cvLimits
      return(out)
    }
    
    if(returnMulti) return(n=min_n,varLimits=varLimits,cvLimits=cvLimits)
    return(min_n)   # Retur ved varLimits-input
  } 
  
 
  totn <- min(sum(max_n[s2 > 0]), totn) # totn <- min(sum(N[s2 > 0]), totn)          # max_n-31/8-20
  nStrata <- length(s2)
  if(length(N) != nStrata) return(-1)
  sumVar <- rep(NaN, totn)
  filledStrata <- rep(NaN, totn)
  n <- rep(0, nStrata)  # forel?pig antall i hvert strata
  tVar <- corrTotVar(s2, n, N, nullcorrection, totVar = totVar) # forelopig varians i hvert strata
  tVar1 <- corrTotVar(s2, n + 1, N, nullcorrection, totVar = totVar) # varians dersom forelopig antall okes med 1
  
  if(!is.null(min_n) | !is.null(use_n)) {     # Endringer pga min_n eller use_n
    if(is.null(use_n)) {
      use_n <- min_n 
    } else {
      use_n <- rbind(matrix(use_n, ncol = nStrata), N) # Sikrer at fulltelling blir med ved use_n
      if(!is.null(min_n)) {  # B?de use_n og min_n, Spesiell variant
        min_n <- matrix(min_n,ncol=nStrata)[1,] # Sikrer lengde nStrata
        min_n[min_n >= N] <- NaN
        minbigger_n <- min_n
        for(k in 1:nStrata){
          if(is.na(min_n[k])) {
            minbigger_n[k] <- NaN
          } else {
            minbigger_n[k] <- minbigger(use_n[, k], min_n[k]) 
          }
        }
        use_n <- rbind(-min_n,-minbigger_n,min_n,use_n) # Negativ er spesiell kode 	    
      }
    }  
    use_n <- rbind(0,matrix(use_n,ncol=nStrata)) # 0 m? med for at det skal virke
    # Heltall integer slik at "=" og ">" garanteres
    use_n <- matrix(as.integer(round(use_n)), dim(use_n)[1], dim(use_n)[2]) 
    # sikrer at N ikke overskrides
    for(k in 1:nStrata) use_n[,k][use_n[,k] > N[k]] <- N[k]
    # tVar1 lages p? nytt med ny funksjon
    for(k in 1:nStrata) tVar1[k] <- corrTot_Var(s2[k], n[k] + 1, N[k], nullcorrection, use_n[, k], totVar = totVar)
  } else {
    use_n <- matrix(0, ncol = nStrata)
  }
  
  # Her er det mulig aa lage mye raskere algoritme ved aa lagre beregninger i tabell 
  # og bruke diff og sort. Kan ogs? droppe  approx-funskjonen 
  
  diffVar <- tVar - tVar1     # variansreduksjon ved ? ?ke med 1 i hvert strata
  for(i in 1:totn){
    if(dotprint) simPrint(i, totn)
    
    #k <- which.max(diffVar)   # finner stata nummer k med best variansreduksjon
    
    which_min = which(n<min_n)               # Nytt fyller direkte opp min_n 
    if(length(which_min)) k = which_min[1]   # unngår problem ved s2=0,   6/10-2015
    else k <- which.max(diffVar*as.numeric(n<max_n)) # finner stata nummer k med best variansreduksjon  # max_n-31/8-20
    
    
    # Oppdater med med nytt tall i strata nummer k
    n[k] <- n[k]+1
    tVar[k] <- tVar1[k]
    tVar1[k] <- corrTot_Var(s2[k], n[k]+1, N[k], nullcorrection, use_n[,k], totVar = totVar)
    diffVar[k] <- tVar[k]-tVar1[k]
    
    # Skriver inn hvilket strata som ble fyllt og varians etter dette
    filledStrata[i] <- k
    if(corrSumVar)  sumVar[i] <- sum(tVar)     # Total varians etter siste stratafylling
    else sumVar[i] <- abs(sum(totVar(s2, n, N), na.rm=T)) # abs sikrer inf og ikke -inf ########### har lagt inn na.rm for s2=0 (Susie)
  }
  
  
  
  if(returnTable|returnMatrix){
    t=table(c(1:length(stratanames), filledStrata)) - 1
    names(t) = stratanames
    if(returnMatrix){
      out = FillStrata(s2=s2,N=N,totVar=totVar,nullcorrection=nullcorrection,totn=totn,min_n=t,use_n=use_n,corrSumVar=corrSumVar,
                       dotprint=dotprint,varLimits=Inf,intern=TRUE,max_n=max_n,totY=totY,cvLimits=Inf,
                       group=group,returnMatrix=TRUE,totYgroup=totYgroup) 
      out[,2]$varLimits=NA
      out[,2]$cvLimits=NA
      return(out)
    }
    
    return(t)
  }
  if (!intern) filledStrata <- stratanames[filledStrata]
  return(list(filledStrata = filledStrata, sumVar = sumVar))
}



###################################################################################
# Funksjon for aa skrive #### 
simPrint <- function(i, nSim){
  if(i>nSim) return(NULL)  # Ny 13/1-2016
  if(i == 1){
    cat("\n")
    utils::flush.console()
  }
  if(i==nSim){
    cat("#\n")
    utils::flush.console()
  } else if (floor(100 * i / nSim)>floor(100 * (i - 1) / nSim)){
    if(floor(10 * i / nSim) > floor(10 * (i - 1) / nSim)) { 
      cat("#")
      utils::flush.console()    # Ny 13/1-2016
    }
    else   {
      cat("-")
      utils::flush.console() }
  }
  NULL
}

rowNr <- function(m){
  matrix(1:dim(m)[1], dim(m)[1], dim(m)[2])
}

colNr <- function(m){
  t(matrix(1:dim(m)[2], dim(m)[2], dim(m)[1]))
}


# Lager matrise med dummyvariabler fra faktor-variabel
makeDummy <- function(x){
  x <- as.factor(x)
  if(length(levels(x)) == 1) m <- matrix(as.numeric(x), length(x), 1)
  else m <- stats::model.matrix(~x-1)[, ]
  colnames(m) <- levels(x)
  m
}  


updateMinNsingle <- function(new_min_n, min_n=NULL, use_n=NULL){
  if(is.null(use_n)) # returnerer kun ny min_n-verdi
  {
    if(is.null(min_n))  min_n <- new_min_n
    if(is.na(min_n))    min_n <- new_min_n
    min_n <- (max(new_min_n, min_n))
    return(list(min_n = min_n, use_n = use_n))   
  }
  
  if(is.null(min_n)) # returnerer kun ny use_n-verdi
  {
    use_n[use_n<new_min_n] <- NA
    return(list(min_n = min_n,use_n = use_n))   
  }
  if(is.na(min_n)) min_n <- 0 # Forhindre error nedenfor
  use_n[use_n<min_n] <- NA
  if(new_min_n>min_n) min_n <- new_min_n
  if(min_n >= min(use_n, na.rm = TRUE))
  {
    use_n[use_n<min_n] <- NA
    min_n <- NA
    
  }
  return(list(min_n = min_n, use_n = use_n))   
}

updateMinN <- function(new_min_n, min_n = NULL, use_n = NULL)
{
  if(is.null(min_n) & is.null(use_n))
    return(list(min_n = new_min_n, use_n = use_n))   
  if(!is.null(min_n)) min_n <- matrix(min_n, ncol = length(new_min_n))[1, ]
  for(i in 1:length(new_min_n)) {
    a <- updateMinNsingle(new_min_n[i], min_n[i], use_n[, i])
    min_n[i] <- a$min_n
    use_n[,i] <- a$use_n
  }	
  return(list(min_n = min_n, use_n = use_n))
}

# Lager funksjon med korrigert totVar slik at n=0 ogs? gir resultat   
corrTotVar <- function(s2, n, N, nullcorrection, totVar) {
  correction <- rep(1,length(n))
  correction[n == 0] <- nullcorrection
  n[is.finite(n) & n == 0] <- pmin(1, N[is.finite(n) & n == 0] / 2) # Bare "1" gir "feil" ved N=1
  n[n > N] <- N
  return(correction * totVar(s2, n, N))
}


# Ny modifiseret totVar som brukes til min_n og/eller use_n
# Linear interpolasjon mellom onskelige verdier ved bruk av approx
# I denne funksjonen fungerer ikke vektor som input
corrTot_Var <- function(s2, n, N, nullcorrection, use_n, totVar){
  min_use_n <- min(use_n, na.rm = TRUE)
  approxok <- TRUE
  if(min_use_n < 0){  # Dvs baade use_n og min_n
    neg <- (use_n < 0 & is.finite(use_n))
    nSpes <- -use_n[neg]
    if(n<min(nSpes) | n > max(nSpes)){
      use_n = use_n[!neg] 
    } else { 
      approxok = FALSE 
    }
  }
  if (approxok & n < max(use_n, na.rm = TRUE)) { # Linear interpolasjon mellom verdier i use_n
    return(stats::approx(use_n, corrTotVar(s2, use_n, N, nullcorrection, totVar), n)$y)
  }
  return(corrTotVar(s2, n, N, nullcorrection, totVar))
}


minbigger <- function(x, a){
  min(x[x > a], na.rm = TRUE)
}
