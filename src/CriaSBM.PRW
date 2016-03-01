#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"


User Function CRIASBM()

Local cAliasTMP := GetNextAlias()
Local aTABELAS  := {}
Local nTABELAS  := 0


	TCConType("TCPIP")
	nCONNLOC := TCLink("ORACLE/DADOSADV", "10.200.0.99", 7890) // NOME BCO / NOME ALIAS / IP SERVIDOR OU NOME SERVIDOR
	
	If nCONNLOC <= 0
		Alert("Falha na conex‹o TOPCONN - ID-Erro: " + Alltrim(STR(nCONNLOC)) )
		TCUnLink(nCONNLOC)
		Return
	EndIf
	
	//cQuery := "	SELECT 	NAME "
	//cQuery += "	FROM 	SYSIBM.SYSTABLES "
	//cQuery += "	WHERE 	CREATOR          	= 'DB2INST1' "
	//cQuery += "	AND 	SUBSTR(NAME,4,2)	= '"+SM0->M0_CODIGO+"' "
	//cQuery += "	AND 	LENGTH(TRIM(NAME))	= 6 "
	//cQuery += "	ORDER BY NAME "
	
	// Tabela FJU010 precisa ser importada pelo apsdu
	
	cQuery := "SELECT table_name "
	cQuery += " from user_tables "
	cQuery += " where substr(table_name, 4, 2) = '"+SM0->M0_CODIGO+"' "
	cQuery += " and substr(table_name, 1, 3) = 'SBM'"
	cQuery += " and num_rows > 0 "
	cQuery += " order by table_name"
	Aviso("Aviso",cQuery,{"OK"},3)
	TCQUERY ChangeQuery(cQuery) NEW ALIAS (cAliasTMP)
	dbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGoTop())
	While !(cAliasTMP)->(EOF())
		aAdd ( aTABELAS, SUBSTR((cAliasTMP)->table_name,1,3) )
		nTABELAS += 1
		(cAliasTMP)->(dbSkip())
	Enddo
	(cAliasTMP)->(dbCloseArea())
	
	TCUnLink(nCONNLOC)
	
	If Len(aTABELAS) > 0
		For nTAB := 1 to Len(aTABELAS)
			dbSelectArea(aTABELAS[nTAB])
		Next nTAB
	EndIf
	
	Aviso("Aviso","Processo conclu’do - Nœmero de tabela(s) criada(s): "+cValToChar(nTABELAS),{"OK"})
		
Return