ROOKEM
 Q
 ;
INIT(sessid)
 N USERNAME,PASSWORD
 S USERNAME=$$getSessionValue^%zewdAPI("USERNAME",sessid)
 S PASSWORD=$$getSessionValue^%zewdAPI("PASSWORD",sessid)
 S RET=$$CONNECT^ROOK(USERNAME,PASSWORD,"Q",.RES)
 D FNSTTREE(sessid)
 D FSESGRID(sessid)
 D DISCONNECT^ROOK
 Q ""
 ;
LOGIN(sessid)
 N RET,RES,USERNAME,PASSWORD
 S USERNAME=$$getSessionValue^%zewdAPI("txtUsername",sessid)
 S PASSWORD=$$getSessionValue^%zewdAPI("txtPassword",sessid)
 S RET=$$CONNECT^ROOK(USERNAME,PASSWORD,"Q",.RES)
 I RET=1 D
 . D setSessionValue^%zewdAPI("USERNAME",USERNAME,sessid)
 . D setSessionValue^%zewdAPI("PASSWORD",PASSWORD,sessid)
 Q RES("ERROR","MESSAGE")
 ;
FNSTTREE(sessid)
 N NEST,EGG,EMBRYO,TREE,NESTIDX,EGGIDX,EMBRIDX,ICONCLS,RET,RES
 S (NESTIDX,EGGIDX,EMBRIDX)=1,(NEST,EGG,EMBRYO)=""
 S ICONCLS("STRING")="stringicon"
 S ICONCLS("NUMBER")="numbericon"
 S ICONCLS("HOROLOG")="horologicon"
 S ICONCLS("BOOLEAN")="booleanicon"
 ;
 ; POPULATE THE TREE
 ;
 F  S NEST=$O(^ROOK("DD",NEST)) Q:NEST=""  D
 . S EGG=""
 . S TREE(NESTIDX,"text")=NEST
 . S TREE(NESTIDX,"nextPage")="nestDetail"
 . S TREE(NESTIDX,"iconCls")="databaseicon"
 . F  S EGG=$O(^ROOK("DD",NEST,EGG)) Q:EGG=""  D
 . . S EMBRYO=""
 . . S TREE(NESTIDX,"child",EGGIDX,"text")=EGG
 . . S TREE(NESTIDX,"child",EGGIDX,"nextPage")="eggDetail"
 . . S TREE(NESTIDX,"child",EGGIDX,"iconCls")="tableicon"
 . . S TREE(NESTIDX,"child",EGGIDX,"replacePreviousPage")="true"
 . . S TREE(NESTIDX,"child",EGGIDX,"nvp")="nest="_NEST_"&egg="_EGG
 . . F  S EMBRYO=$O(^ROOK("DD",NEST,EGG,"EMBRYOS",EMBRYO)) Q:EMBRYO=""  D
 . . . S TREE(NESTIDX,"child",EGGIDX,"child",EMBRIDX,"text")=EMBRYO
 . . . S TREE(NESTIDX,"child",EGGIDX,"child",EMBRIDX,"nextPage")="embryoDetail"
 . . . S RET=$$USE^ROOK(NEST,.RES)
 . . . S TREE(NESTIDX,"child",EGGIDX,"child",EMBRIDX,"iconCls")=ICONCLS($$TYPE^ROOKDICT(EGG,EMBRYO))
 . . . S EMBRIDX=$I(EMBRIDX)
 . . S EGGIDX=$I(EGGIDX)
 . S NESTIDX=$I(NESTIDX)
 D mergeArrayToSession^%zewdAPI(.TREE,"tpnlSchemata",sessid)
 Q
 ;
FSESGRID(sessid)
 N GRID,PID,USERNAME,NEST,START,CACHEHITS,CACHEMISSES S PID=""
 N GIDX S GIDX=1
 ; 
 F  S PID=$O(^ROOK("SESSION",PID)) Q:PID=""  D
 . S GRID(GIDX,"PID")=PID
 . S GRID(GIDX,"USERNAME")=$G(^ROOK("SESSION",PID,"USERNAME"))
 . S GRID(GIDX,"NEST")=$G(^ROOK("SESSION",PID,"NEST"))
 . S GRID(GIDX,"START")=$ZDATE($G(^ROOK("SESSION",PID,"SESSION_START")))
 . S GRID(GIDX,"CACHE_HITS_DISK")=$G(^ROOK("SESSION",PID,"CACHE_HITS_DISK"))
 . S GRID(GIDX,"CACHE_HITS_MEMORY")=$G(^ROOK("SESSION",PID,"CACHE_HITS_MEMORY"))
 . S GRID(GIDX,"CACHE_MISSES")=$G(^ROOK("SESSION",PID,"CACHE_MISSES"))
 . S GIDX=$I(GIDX)
 D deleteFromSession^%zewdAPI("grdSessions",sessid)
 D mergeArrayToSession^%zewdAPI(.GRID,"grdSessions",sessid)
 Q
 ;
NESTDETAIL(sessid)
 Q ""
 ;
EGGDETAIL(sessid)
 ;
 N GRID,GIDX,NEST,EGG,EMBR,RET,RES S GIDX=1
 ;
 S NEST=$$getRequestValue^%zewdAPI("nest",sessid)
 S EGG=$$getRequestValue^%zewdAPI("egg",sessid)
 N USERNAME,PASSWORD
 S USERNAME=$$getSessionValue^%zewdAPI("USERNAME",sessid)
 S PASSWORD=$$getSessionValue^%zewdAPI("PASSWORD",sessid)
 S RET=$$CONNECT^ROOK(USERNAME,PASSWORD,"Q",.RES)
 S RET=$$USE^ROOK(NEST,.RES)
 ;
 S EMBR=""
 F  S EMBR=$O(^ROOK("DD",NEST,EGG,"EMBRYOS",EMBR)) Q:EMBR=""  D
 . S GRID(GIDX,"NAME")=EMBR
 . S GRID(GIDX,"TYPE")=$$TYPE^ROOKDICT(EGG,EMBR)
 . S GRID(GIDX,"PRIMARY")=$$YESNO($$PRIMARY^ROOKDICT(EGG,EMBR))
 . S GRID(GIDX,"REQUIRED")=$$YESNO($$REQUIRED^ROOKDICT(EGG,EMBR))
 . S GRID(GIDX,"UNIQUE")=$$YESNO($$UNIQUE^ROOKDICT(EGG,EMBR))
 . S GRID(GIDX,"PATTERN")=$$PATTERN^ROOKDICT(EGG,EMBR)
 . S GRID(GIDX,"INPUTXFORM")=$$IXFORM^ROOKDICT(EGG,EMBR)
 . S GRID(GIDX,"OUTPUTXFORM")=$$OXFORM^ROOKDICT(EGG,EMBR)
 . S GIDX=$I(GIDX)
 D deleteFromSession^%zewdAPI("grdEggEmbryos",sessid)
 D mergeArrayToSession^%zewdAPI(.GRID,"grdEggEmbryos",sessid) 
 D DISCONNECT^ROOK
 Q ""
 ;
YESNO(VALUE)
 N RETVAL
 I VALUE=0 S RETVAL="NO"
 I VALUE=1 S RETVAL="YES"
 Q RETVAL
 ;
EMBDETAIL(sessid)
 Q ""
 ;
