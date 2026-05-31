:- use_module(library(csv)).

:- use_module('conectividad.pl').
:- use_module('ruta_mas_corta.pl').
:- use_module('rutas_posibles.pl').
:- use_module('datos.pl').

inicializar :-
    cargar_manzanas,
    cargar_calles.
