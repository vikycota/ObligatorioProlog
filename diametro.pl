:- module(diametro, [combos_manzanas/2,diametro/3]).
:- use_module('datos.pl').
:-use_module('ruta_mas_short.pl').



combos_manzanas(X,Z):-manzana(X,_,_),
        manzana(Z,_,_),
        Z\=X.

diametro(W,J,Long):-findall((MayorPeso,X,Z),(combos_manzanas(X,Z),ruta_mas_short(X, Z, _MejorRuta, MayorPeso)),Combos),
    sort(Combos, Ayudante),
    reverse(Ayudante,[(Long,W,J)|_]).
    