ROOKSQL
 Q
 ;
EXEC(SQL,RESULT)
 ;
 ; SUBROUTINE DATA
 ;
 N DATA,TIMER,QTIME,RCNT,ERRCT S TIMER=$$BTIME^ROOK,(ERRCT,RCNT)=0
 ;
 ; LEXER STUFF
 ;
 N GDELIM,GDELINC,TERMS S GDELIM=" ;",GDELINC=""
 N CDELIM,CDELINC,LIST S CDELIM=";,",CDELINC=""
 K TERMS S TERMS=""
 ;
 ; REQUIRE CONNECTION TO ROOK
 ; 
 I '$$CONNECTED^ROOK D
 . D ERR^ROOK(13,.RESULT)
 . S ERRCT=$I(ERRCT)
 G:ERRCT>0 QERR
 S RKRESULT=1
 ;
 ; FIND OUT WHAT SQL STATEMENT AND JUMP ACCORDINGLY
 ;
 D LEX(SQL,.TERMS,GDELIM,GDELINC)
 N SQLSTMT S SQLSTMT=$$UCASE($P(SQL," ",1))
 G:SQLSTMT="USE" QUSE
 G:SQLSTMT="SHOW" QSHOW
 G:SQLSTMT="SELECT" QSELECT
 G:SQLSTMT="INSERT" QINSERT
 G:SQLSTMT="UPDATE" QUPDATE
 G:SQLSTMT="DELETE" QDELETE
 ;
 ; IF WE REACH THIS POINT, THE STATEMENT IS WRONG OR IS UNSUPPORTED
 ;
 D ERR^ROOK(23,.RESULT) G QERR
QUSE			;USE
 N NEST S NEST=$P(SQL," ",2),ERRCT=0
 S RKRESULT=$$USE^ROOK(NEST,.RESULT)
 I RKRESULT=1 D 
 . D MSG^ROOK("NEST CHANGED") 
 E  D
 . S ERRCT=$I(ERRCT)
 G:ERRCT=0 QSUCCESS
 G QERR
QSHOW			;SHOW
 ;
 G QSUCCESS
QSELECT			;SELECT
 N FIELDS,TABLES,PREDICATES,F,T,P
 S F=TERMS(2),T=TERMS(4),P=TERMS(6)
 F I=1:1:$L(F,",")  D
 . S FIELDS(I)=$P(F,",",I)
 F I=1:1:$L(T,",")  D
 . S TABLES(I)=$P(T,",",I)
 F I=1:1:$L(P,"=")  D
 . S PREDICATES(I)=$P(P,"=",I)
 
 N SELRES
 S RKRESULT=$$GETROWS^ROOKIDX(TABLES(1),PREDICATES(1),PREDICATES(2),.SELRES)
 S RCNT=SELRES("RECORDCOUNT")
 M DATA=SELRES("DATA")
 

 G QSUCCESS
QINSERT			;INSERT

 G QSUCCESS
QUPDATE			;UPDATE

 G QSUCCESS
QDELETE			;DELETE

 G QSUCCESS
QERR
 S RKRESULT=0
QSUCCESS
 S QTIME=$$ETIME^ROOK(TIMER)
 I RKRESULT D SUCCESS^ROOK(.RESULT,0,QTIME,RCNT,.DATA)
 Q RKRESULT
 ;
UCASE(STR)
 Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
LCASE(STR)
 Q $TR(STR,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 ;
LEX(SQL,WORDS,DELIM,DELINC)
 D SPLIT(SQL,.WORDS,DELIM,DELINC)
 Q

OLDLEX(SQL,WORDS,DELIM,DELINC)
 N INSTR S INSTR=0
 N LEN S LEN=$L(SQL)
 N WI S WI=0
 N C,B,I S I=1,B=""
 F  Q:I>LEN  D
 . S C=$E(SQL,I)
 . I '(DELIM[C) D
 . . I '("'"[C) S B=B_C
 . I C="'" D
 . . I INSTR=1 D
 . . . S WI=$I(WI)
 . . . S WORDS(WI)=$P(B,"'",2)
 . . . S B=""
 . . . S INSTR=0
 . . E  D
 . . . S INSTR=1
 . I INSTR=0 D
 . . I (DELIM[C)!(I=LEN) D
 . . . ; W "INSTR=0,DELIM[C!I=LEN",!
 . . . S WI=$I(WI)
 . . . S WORDS(WI)=B
 . . . ;I I=LEN S WORDS(WI)=B_C E  S WORDS(WI)=B
 . . . I DELINC[C S WI=$I(WI) S WORDS(WI)=C
 . . . S B="" 
 . ;W "I=",I," C=",C," B='",B,"' WI=",WI," INSTR=",INSTR,!
 . S I=$I(I)
 Q
SPLIT(STRING,WORDS,DELIM,DELINC)
 ;
 ; We want to split SQL into array WORDS:
 ;  WORDS are delimited by any character in DELIM
 ;  Any character in DELINC will be put into WORDS as its own word
 ;  Delimiters are disregarded in quoted strings
 ;
 new inQuotedString,stringLength,currentChar,currentPos,currentWord,working
 new appendThis,thisIncluded
 ;
 ; initialize everything
 ;
 set (inQuotedString,currentWord,thisIncluded)=0,(appendThis,currentPos)=1
 set stringLength=$l(STRING)
 set (currentChar,working,WORDS)=""
 ;
 for currentPos=1:1:stringLength  do
 . ; 
 . ; get the next character
 . ; 
 . set currentChar=$extract(STRING,currentPos)
 . ;
 . ; are we in a string?
 . ;
 . if currentChar="'" do
 . . set appendThis=0
 . . if inQuotedString do	; this is the end quote of the string
 . . . do installWord(.WORDS,.currentWord,.working)
 . . . set inQuotedString=0
 . . else  do			; this is the start quote of the string
 . . . set inQuotedString=1
 . . . ;			; end of quoted string processing
 . else  do			; this is NOT a quote
 . . if $$isDelimiter(currentChar,DELIM,inQuotedString) do		;this is a delimiter
 . . . set appendThis=0
 . . . do installWord(.WORDS,.currentWord,.working)
 . . else  do						;this is not a delimiter
 . . . set appendThis=1
 . ; end of specific non-quoted-string processing
 . s thisIncluded=$$isIncluded(currentChar,DELINC)
 . if thisIncluded do installWord(.WORDS,.currentWord,.working)
 . if appendThis do 
 . . set working=working_currentChar
 set WORDS(currentWord)=$get(WORDS(currentWord))_$extract(STRING,stringLength)
 ;. write "working length: '",$l(working),"' currentChar: '",currentChar,"' currentPos: '",currentPos,"' currentWord ; : ",currentWord," appendThis: ",appendThis," inQuotedString: ",inQuotedString," thisIncluded: ",thisIncluded,!
 Q
 ;
installWord(WORDS,NUM,WORD)
 S NUM=$I(NUM)
 S WORDS(NUM)=WORD
 S WORD=""
 Q
 ;
isDelimiter(C,DELIM,inQuotedString)
 Q:inQuotedString=1 0
 Q:'(DELIM[C) 0
 Q:(DELIM[C) 1
 ;
isIncluded(C,DELINC)
 Q (DELINC[C)
 ;