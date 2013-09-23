ROOKDM
 Q
 ;
SELECT()
 Q RKRESULT
 ;
INSERT(DA,RESULT)
 ;
 ; SUBROUTINE DATA
 ; 
 N EGG,ENTR,EMBR,VAL,ERRCT,IMMEDIATE S (EGG,ENTR,EMBR)="",(IMMEDIATE,ERRCT)=0
 N TYPE,IXF,OXF,PATTERN,TRANARRAY S (TYPE,IXF,OXF,PATTERN)=""
 N RES,RET
 N RCNT S RCNT=0
 N TIMER
 S TIMER=$$BTIME^ROOK
 ;
 ; REQUIRE CONNECTION TO ROOK
 ;
 I '$$CONNECTED^ROOK D
 . D ERR^ROOK(13,.RESULT)
 G:RKRESULT=0 ERINSERT
 S RKRESULT=1
 ;
 ; REQUIRE SELECTED NEST
 ; (SUCCESS HERE IMPLIES THAT THE NEST EXISTS)
 ;
 S NEST=$$CURRENTNEST^ROOK
 I NEST="" D
 . D ERR^ROOK(10,.RESULT)
 G:RKRESULT=0 ERINSERT
 S RKRESULT=1
 ;
 ; IF NO TRANSACTION IS PENDING, START ONE AND SET THE IMMEDIATE FLAG
 ; 
 ;
 I '$D(RKTRPEND) D 
 . D TRANSTART
 . S IMMEDIATE=1
 E  D
 . S IMMEDIATE=0
 ;
 ; LOOP OVER THE DATA ARRAY (DA)
 ;
 S EGG=""
 F  S EGG=$O(DA(EGG)) Q:EGG=""  D
 . Q:ERRCT>0
 . S ENTR="",RCNT=RCNT+1
 . F  S ENTR=$O(DA(EGG,ENTR)) Q:ENTR=""  D
 . . Q:ERRCT>0
 . . S EMBR=""
 . . F  S EMBR=$O(DA(EGG,ENTR,EMBR)) Q:EMBR=""  D
 . . . ;
 . . . ; MAKE SURE EGG EXISTS
 . . . ; 
 . . . S RET=$$EGGEXISTS^ROOKDD(EGG,.RES)
 . . . I RET=0 S ERRCT=$I(ERRCT) D ERR^ROOK(12,.RESULT)
 . . . Q:ERRCT>0 
 . . . S RKRESULT=1
 . . . ; 
 . . . ; MAKE SURE EMBRYO EXISTS
 . . . ;
 . . . K RET,RES
 . . . S RET=$$EMBRYOEXISTS^ROOKDD(EGG,EMBR,.RES)
 . . . I RET=0 S ERRCT=$I(ERRCT) D ERR^ROOK(9,.RESULT)
 . . . Q:ERRCT>0
 . . . S RKRESULT=1
 . . . ;
 . . . ; GET PROPOSED VALUE
 . . . ;
 . . . S VAL=DA(EGG,ENTR,EMBR)
 . . . ; 
 . . . ; GET TYPE, PATTERN, AND INPUT TRANSFORM
 . . . ;
 . . . S TYPE=$$TYPE^ROOKDICT(EGG,EMBR)
 . . . S PATTERN=$$PATTERN^ROOKDICT(EGG,EMBR)
 . . . S IXF=$$IXFORM^ROOKDICT(EGG,EMBR)
 . . . ;
 . . . ; VALIDATE DATATYPE OF VAL
 . . . ;
 . . . S RET=$$BYTYPE^ROOKVALI(TYPE,VAL)
 . . . I RET=0 S ERRCT=$I(ERRCT) D ERR^ROOK(6,.RESULT)
 . . . Q:ERRCT>0
 . . . S RKRESULT=1
 . . . ;
 . . . ; EXECUTE THE INPUT TRANSFORM AND TAKE RKOUT AS NEW VALUE
 . . . ;
 . . . I IXF'="" D
 . . . . S RKIN=VAL X IXF S VAL=RKOUT
 . . . . S DA(EGG,ENTR,EMBR)=VAL 
 . . . ; 
 . . . ; MAKE SURE VAL MATCHES PATTERN
 . . . ;
 . . . I PATTERN'="" D
 . . . . S RET=$$PATTERN^ROOKVALI(VAL,PATTERN)
 . . . . I RET=0 S ERRCT=$I(ERRCT) D ERR^ROOK(4,.RESULT)
 . . . Q:ERRCT>0
 . . . S RKRESULT=1 
 . . . ; 
 . . . ; INSTALL THIS EGG,ENTRY,EMBRYO INTO THE TRANSACTION QUEUE
 . . . ;
 . . . S TRANARRAY(EGG,ENTR,EMBR)=VAL
 . . . D TRANINST("INSERT",NEST,.TRANARRAY)
 G:ERRCT>0 ERINSERT
 ;
 ; COMMIT IF THE IMMEDIATE FLAG WAS SET 
 ;
 N TCRES,TCRET
 I IMMEDIATE D 
 . S TCRET=$$TRANCOMMIT(.TCRES)
 N QTIME S QTIME=$$ETIME^ROOK(TIMER)
 D SUCCESS^ROOK(.RESULT,0,QTIME,RCNT,.DA)
ERINSERT
 Q RKRESULT
 ;
UPDATE
 Q RKRESULT
 ;
DELETE
 Q RKRESULT
 ;
TRANSTART
 ; 
 ; SET UP THE RKQUEUE DATA STRUCTURE
 ;
 S RKTRPEND=$I(RKQIDX)
 S RKQUEUE(RKQIDX)=""
 Q
 ;
TRANINST(OPERATION,NEST,TRANARRAY)
 M RKQUEUE(RKQIDX,NEST,OPERATION)=TRANARRAY
 Q
 ;
TRANCOMMIT(RESULT)
 S RKRESULT=1
 ;
 ; SUBROUTINE DATA
 ; 
 N NEST,OPER,DA,ERRCT,GLVN S (NEST,OPER,DA)="",ERRCT=0
 N ROWS S ROWS=0
 N TIMER S TIMER=$$BTIME^ROOK
 N QTIME
 ; 
 ; LOOP OVER RKQUEUE
 ;
 F  S NEST=$O(RKQUEUE(RKQIDX,NEST)) Q:NEST=""  D
 . S GLVN="^"_NEST
 . ;
 . ; LOCK THE DATA DICTIONARY FOR THIS NEST
 . ;
 . LOCK (^ROOK("DD",NEST)):30
 . I '$TEST D
 . . S ERRCT=$I(ERRCT)
 . . D ERR^ROOK(20,.RESULT)
 . Q:ERRCT>0
 . S RKRESULT=1
 . ;
 . ; LOCK THE NEST
 . ;
 . LOCK (@GLVN@("DATA"),@GLVN@("INDEX")):30
 . I '$TEST D
 . . S ERRCT=$I(ERRCT)
 . . D ERR^ROOK(20,.RESULT)
 . Q:ERRCT>0
 . S RKRESULT=1
 G:ERRCT>0 TCEND
 ;
 ; WE SHOULD NOW HAVE LOCKS ON THE NESTS AND THE DATA DICTIONARY 
 ; SUBSCRIPTS FOR THE NESTS. 
 ;
 ; NOW, WE WILL PROCESS ANY OPERATIONS.
 ;
 N RET,RES,INSDA,TMPENT,CENT,IDXDA,EGG,EMBR,VAL,EGGIDX,NENT
 N INSERTS S (INSERTS,NEST)="",NENT=0
 F  S NEST=$O(RKQUEUE(RKQIDX,NEST)) Q:NEST=""  D
 . S RET=$$USE^ROOK(NEST,.RES)
 . I $D(RKQUEUE(RKQIDX,NEST,"INSERT")) D 
 . . M INSERTS=RKQUEUE(RKQIDX,NEST,"INSERT")
 . . ; 
 . . ; RUN THROUGH THE INSERT OPS, RE-NUMBERING THE ENTRY NUMBERS TO INCREMENT
 . . ; FROM ^ROOK("DD",NEST,EGG,ENTRYNUMBER) TO THE TOTAL NUMBER OF ENTRIES FOR 
 . . ; EACH EGG. 
 . . ;
 . . S (EGG,INSDA)=""
 . . F  S EGG=$O(INSERTS(EGG)) Q:EGG=""  D
 . . . S TMPENT="",CENT=$$EGGPROP^ROOKDICT(EGG,"ENTRYNUMBER")
 . . . F  S TMPENT=$O(INSERTS(EGG,TMPENT)) Q:TMPENT=""  D
 . . . . S ROWS=$I(ROWS)
 . . . . M INSDA(EGG,CENT)=INSERTS(EGG,TMPENT)
 . . . . S CENT=$I(CENT)
 . . . . S NENT=CENT
 . . . ; 
 . . . ; NOW, BUILD THE INDEX ARRAY
 . . . ;
 . . . S (EGGIDX,CENT,EMBR)=""
 . . . F  S EGGIDX=$O(INSDA(EGGIDX)) Q:EGGIDX=""  D
 . . . . S CENT=""
 . . . . F  S CENT=$O(INSDA(EGGIDX,CENT)) Q:CENT=""  D
 . . . . . S EMBR=""
 . . . . . F  S EMBR=$O(INSDA(EGGIDX,CENT,EMBR)) Q:EMBR=""  D
 . . . . . . S VAL=INSDA(EGGIDX,CENT,EMBR)
 . . . . . . I $L(VAL)<81 S IDXDA(EGGIDX,EMBR,VAL,CENT)=""
 . . . S ^ROOK("DD",NEST,EGG,"ENTRYNUMBER")=NENT
 . . S GLVN="^"_NEST
 . . M @GLVN@("DATA")=INSDA
 . . M @GLVN@("INDEX")=IDXDA
 ;
 ; KILL RKTRPEND, SIGNIFYING THAT NO TRANSACTION IS IN PROGRESS 
 ;
 K RKTRPEND
 ;
 ; RELEASE ALL THE LOCKS WE GRABBED
 ;
 LOCK
 S QTIME=$$ETIME^ROOK(TIMER)
 N DATA S DATA(0)=1
 D SUCCESS^ROOK(.RESULT,0,QTIME,ROWS,.DATA)
TCEND
 Q RKRESULT
 ;
