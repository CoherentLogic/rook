ROOKTEST
 n result,return,username,password,flags
 n nest,egg,emb
 ;
 s flags="V",nest="books",eggName="books"
 ; build the egg definition
 s egg(eggName,"ENTRYNUMBER")=1
 s egg(eggName,"EMBRYOS")=""
 ; build the embryo definition
 ; id
 s emb("id","TYPE")="NUMBER"
 s emb("id","UNIQUE")=1
 s emb("id","REQUIRED")=1
 s emb("id","PRIMARY")=1
 ; title
 s emb("title","TYPE")="STRING"
 ; author
 s emb("author","TYPE")="STRING"
 ; ISBN
 s emb("isbn","TYPE")="STRING"
 ; get username and password
 s username="jpw",password=""
 ; connect to Rook
 s return=$$CONNECT^ROOK(username,password,flags,.result)
 ; make the nest
 s return=$$MKNEST^ROOKDD(nest,.result)
 ; select it
 s return=$$USE^ROOK(nest,.result)
 ; make the egg
 s return=$$MKEGG^ROOKDD(.egg,.result)
 ; make the 4 embryos
 s return=$$MKEMBRYO^ROOKDD(eggName,.emb,.result)
 n da
 w !,"id?     " r da(eggName,1,"id")
 w !,"title?  " r da(eggName,1,"title")
 w !,"author? " r da(eggName,1,"author")
 w !,"isbn?   " r da(eggName,1,"isbn")
 n insertResult,insertReturn
 d TRANSTART^ROOKDM
 s insertReturn=$$INSERT^ROOKDM(.da,.insertResult)
 
 q