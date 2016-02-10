#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

// Fun‹o para abrir determinada tabela de dados
/*User Function OpenTbl()

Local oDlg := Nil
Local cTab := Space(3)
Local oBtOpen   

@ 100, 100 To 250, 310 Dialog oDlg Title "Criar tabela"
@  30,  10 Say "Alias da Tabela"
@  30,  55 Get cTab size 40,10  Picture "@!" 
@  50,  30 BmpButton Type 01 Action OpenTab(cTab)
@  50,  75 BmpButton Type 02 Action Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED
Return Nil 


Static Function OpenTab(cTab)
If MsFile(RetSqlName(cTab) , NIL , __cRdd)
	dbSelectArea(cTab)
	dbCloseArea()
	MsgInfo("Tabela " + RetSqlName(cTab) + " aberta com sucesso!")
else
	Alert("Tabela " + cTab + " n‹o existe") 
EndIf
Return Nil
*/

User Function CriaTabB()
Local aTabs := {}
Local aDADOSEMP := {}
Local cEMPATU 	:= cEmpAnt
Local cFILATU 	:= cFilAnt
Local cMODIMP 	:= "FAT"
Local aArea := GetArea()   


dbSelectArea("SX2")
SX2->(dbSetOrder(1))  
SX2->(dbGoTop())   
While ! SX2->(EOF())
    Aadd(aTabs, SX2->X2_CHAVE)
	SX2->(dbSkip())
EndDo 

dbSelectArea("SM0")
aAreaSM0 := SM0->(GetArea())
SM0->(dbSetOrder(1))
SM0->(dbGoTop())
While ! SM0->(EOF())
	If SM0->M0_CODIGO != "00"
		nPOS := aScan ( aDADOSEMP, { |x| x[1] == SM0->M0_CODIGO } )
		If nPOS == 0
			aAdd ( aDADOSEMP, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
	EndIf
	SM0->(dbSkip())
Enddo
RestArea(aAreaSM0) 


For nR := 1 To Len(aDADOSEMP)

	RpcClearEnv()
	RPCSetType(3)
	
	PREPARE ENVIRONMENT EMPRESA (aDADOSEMP[nR][01]) FILIAL (aDADOSEMP[nR][02]) MODULO cMODIMP 
	
	For nE := 1 To Len(aTabs)
		cTab := aTabs[nE]
		
		If MsFile(RetSqlName(cTab) , NIL , __cRdd)
			dbSelectArea(cTab)
			dbCloseArea()
		else
			Alert("Tabela " + cTab + " n‹o existe") 
		EndIf
		
		(cTab)->(dbCloseArea())
	Next
	
Next

RpcClearEnv()

PREPARE ENVIRONMENT EMPRESA (cEMPATU) FILIAL (cFILATU) MODULO cMODIMP

RestArea(aAreaSM0)
RestArea(aArea)
Alert("Fim")
Return