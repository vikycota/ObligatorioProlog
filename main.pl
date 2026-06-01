:- use_module(library(csv)).

:- use_module('conectividad.pl').
:- use_module('ruta_mas_corta.pl').
:- use_module('rutas_posibles.pl').
:- use_module('datos.pl').
:- use_module('diametro.pl').
:- use_module('ruta_mas_larga.pl').

inicializar :-
    set_prolog_flag(answer_write_options, [max_depth(0)]),
    cargar_manzanas,
    cargar_calles.
