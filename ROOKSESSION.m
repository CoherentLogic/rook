ROOKSESSION
 Q 
 ;
GET(KEY)
 Q $G(^ROOK("SESSION",$J,KEY),"")
 ;
SET(KEY,VALUE)
 S:KEY'="" ^ROOK("SESSION",$J,KEY)=VALUE
 Q
 ;