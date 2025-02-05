//-- copyright
// hbunit is a unit-testing framework for the Harbour language.
//
// Copyright (C) 2014 Enderson maia <endersonmaia _at_ gmail _dot_ com>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// See COPYRIGHT for more details.
//++

#include "hbunit.ch"

CLASS TAssert

  METHOD new( oResult ) CONSTRUCTOR
  METHOD ClassName()
  DATA cClassName

  METHOD equals( xExp, xAct, cMsg )
  METHOD notEquals( xExp, xAct, cMsg )
  METHOD true( xAct, cMsg )
  METHOD false( xAct, cMsg )
  METHOD null( xAct, cMsg )
  METHOD notNull( xAct, cMsg )
  DATA oResult

PROTECTED:
  METHOD isEqual( xExp, xAct )
  METHOD assert( xExp, xAct, cMsg, lInvert )
  METHOD fail( cMsg )
  METHOD arrToStr( aArr )
  METHOD toStr (xVal, lUseQuote )

ENDCLASS

METHOD new( oResult ) CLASS TAssert
  ::oResult := oResult
  ::cClassName := "TAssert"
  RETURN ( SELF )

METHOD ClassName() CLASS TAssert
  RETURN ( ::cClassName )

METHOD fail( cMsg ) CLASS TAssert
  RETURN ( ::assert( .f.,, "Failure: " + cMsg ) )

METHOD equals( xExp, xAct, cMsg ) CLASS TAssert
  LOCAL cErrMsg := ""

  cErrMsg += "Exp: " + ::toStr( xExp, .t. )
  cErrMsg += ", Act: " + ::toStr( xAct, .t. )
  cErrMsg += "( " + cMsg + " )"

  RETURN ( ::assert( xExp, xAct, cErrMsg ) )

METHOD notEquals( xExp, xAct, cMsg ) CLASS TAssert
  LOCAL cErrMsg := ""

  cErrMsg += "Exp: not " + ::toStr( xExp, .t. )
  cErrMsg += ", Act: " + ::toStr( xAct )
  cErrMsg += "( " + cMsg + " )"

  RETURN ( ::assert( xExp, xAct, cErrMsg, .t. ) )

METHOD true( xAct, cMsg ) CLASS TAssert
  LOCAL cErrMsg := ""

  cErrMsg += "Exp: .t., Act: "
  cErrMsg += ::toStr( xAct, .t. )
  cErrMsg += "( " + cMsg + " )"

  RETURN ( ::assert( .t., xAct , cErrMsg ) )

METHOD false( xAct, cMsg ) CLASS TAssert
  LOCAL cErrMsg := ""

  cErrMsg += "Exp: .f., Act: "
  cErrMsg += ::toStr( xAct, .t. )
  cErrMsg += "( " + cMsg + " )"

  RETURN ( ::assert( .f., xAct , cErrMsg ) )

METHOD null( xAct, cMsg ) CLASS TAssert
  LOCAL cErrMsg := ""

  cErrMsg += "Exp: nil, Act: "
  cErrMsg += ::toStr( xAct, .t. )
  cErrMsg += "( " + cMsg + " )"

  RETURN ( ::assert( nil, xAct , cErrMsg ) )

METHOD notNull( xAct, cMsg ) CLASS TAssert
  LOCAL cErrMsg := ""

  cErrMsg += "Exp: not nil, Act: "
  cErrMsg += ::toStr( xAct, .t. )
  cErrMsg += "( " + cMsg + " )"

  RETURN ( ::assert( nil, xAct , cErrMsg, .t. ) )

METHOD assert( xExp, xAct, cMsg, lInvert ) CLASS TAssert
  LOCAL oError, bError

  cMsg := Procfile(2) + ":" + LTRIM(STR(ProcLine(2))) + ":" + ProcName(2) + " => " + cMsg

  IF( lInvert == nil, lInvert := .f., )

  TRY EXCEPTION
    ::oResult:oData:incrementAssertCount()

    IF ( ( lInvert .and. ::isEqual( xExp, xAct )) .or.;
        ( !( lInvert ) .and. ( !( ::isEqual( xExp, xAct  )))))

      oError := ErrorNew()
      oError:description  := cMsg
      oError:filename     := Procfile(2)

      ::oResult:oData:addFailure( oError )

    ENDIF

  CATCH EXCEPTION oError
    ::oResult:oData:addError( oError )
  END TRY

  RETURN ( nil )

METHOD isEqual( xExp, xAct ) CLASS TAssert
  LOCAL lResult := .F.

  DO CASE
    CASE ValType( xExp ) != ValType( xAct )
    CASE ( !( xExp == xAct ))
    OTHERWISE
      lResult := .T.
  ENDCASE
RETURN ( lResult )

// #TODO - see where to put these util methods

METHOD toStr (xVal, lUseQuote ) CLASS TAssert
  local cStr

  if( lUseQuote == nil, lUseQuote := .f., )

  DO CASE
  CASE ( ValType( xVal ) == "C" )
      cStr := xVal
  CASE ( ValType( xVal ) == "M" )
      cStr := xVal
  CASE ( ValType( xVal ) == "L" )
   cStr := if( xVal, ".t.", ".f." )
  CASE ( ValType( xVal ) ==  "D" )
   cStr := DToC( xVal )
  CASE ( ValType( xVal ) == "N" )
   cStr := LTrim( Str( xVal ) )
  CASE ( ValType( xVal ) == "A" )
   cStr := ::arrToStr( xVal )
  CASE ( ValType( xVal ) == "O" )
   cStr := "obj"
  CASE ( ValType( xVal ) == "B" )
   cStr := "blk"
  OTHERWISE
   cStr := "nil"
  END

  IF ( lUseQuote .and. ValType( xVal ) == "C" )
    cStr := "'" + cStr+ "'"
  ENDIF

  RETURN ( cStr )

METHOD arrToStr( aArr ) CLASS TAssert
  LOCAL cStr := "", nArrLen := LEN( aArr ), i

  cStr += " ARRAY => { "
  FOR i := 1 TO nArrLen
    cStr += ::toStr( aArr[i] )
    IIF( i < nArrLen , cStr += "," , )
  NEXT
  cStr += " }"

  RETURN ( cStr )
