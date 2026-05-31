%Calcular mas eficiente inicio

:- module(ruta_mas_corta, [calcular_ruta_con_pesos/4,suma_pesos/3,ruta_mas_eficiente/4]).

:- use_module('datos.pl').
:- use_module('rutas_posibles.pl').

calcular_ruta_con_pesos(X,Y,Ruta,Total):-
    encontrar_todas_rutas(X,Y,Ruta),
    suma_pesos(Ruta,0,Total),
    write(Ruta),
    write(" Peso: "),
    write(Total).
    
suma_pesos([_],Suma,Total):-Total=Suma.

suma_pesos(Lista,Suma,Total):-
    Lista=[First,Second|Rest],
    calle(_,First,Second,Z),
    Suma1 is Z+Suma,
    suma_pesos([Second|Rest],Suma1,Total).

ruta_mas_eficiente(X, Y, MejorRuta, MenorPeso) :-
    findall((Peso, Ruta),calcular_ruta_con_pesos(X, Y, Ruta, Peso),Rutas),
    sort(Rutas, [(MenorPeso, MejorRuta) | _]).
