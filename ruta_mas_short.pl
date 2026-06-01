%Calcular mas eficiente inicio

:- module(ruta_mas_short, [calcular_ruta_con_long/4,suma_long/3,ruta_mas_short/4]).

:- use_module('datos.pl').
:- use_module('rutas_posibles.pl').

calcular_ruta_con_long(X,Y,Ruta,Total):-
    encontrar_todas_rutas(X,Y,Ruta),
    suma_long(Ruta,0,Total).
    
suma_long([_],Suma,Total):-Total=Suma.

suma_long(Lista,Suma,Total):-
    Lista=[_First|Rest],
    Suma1 is 1+Suma,
    suma_long(Rest,Suma1,Total).

ruta_mas_short(X, Y, LargaRuta, MayorPeso) :-
    findall((Peso, Ruta),calcular_ruta_con_long(X, Y, Ruta, Peso),Rutas),
    sort(Rutas, [(MayorPeso, LargaRuta) | _]).
