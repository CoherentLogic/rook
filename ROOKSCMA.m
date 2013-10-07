ROOKSCMA
 Q
 ;
ADDSCHEMA(NEST)
 N RESULT,RETURN,OLDNEST,DA
 ;
 ; SAVE THE CURRENTLY SELECTED NEST AND SELECT 
 ; INFORMATION_SCHEMA
 ;
 S OLDNEST=$$CURRENTNEST^ROOK
 S RETURN=$$USE^ROOK("INFORMATION_SCHEMA",.RESULT)
 ; 
 ; BUILD THE DATA ARRAY
 ; 
 S DA("SCHEMATA",1,"CATALOG_NAME")="DEFAULT"
 S DA("SCHEMATA",1,"SCHEMA_NAME")=NEST
 S DA("SCHEMATA",1,"DEFAULT_CHARACTER_SET_NAME")=$$GETCFG^ROOK("CHARSET")
 S DA("SCHEMATA",1,"DEFAULT_COLLATION_NAME")=$$GETCFG^ROOK("COLLATION")
 S DA("SCHEMATA",1,"SQL_PATH")=""
 ;
 ; INSERT IT 
 ;
 D TRANSTART^ROOKDM
 S RETURN=$$INSERT^ROOKDM(.DA,.RESULT)
 S RETURN=$$TRANCOMMIT^ROOKDM
 S RETURN=$$USE^ROOK(OLDNEST,.RESULT)
 Q
 ;
ADDEGG