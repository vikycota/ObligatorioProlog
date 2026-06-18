:- use_module(library(csv)).

:- use_module('conectividad.pl').
:- use_module('ruta_mas_corta.pl').
:- use_module('rutas_posibles.pl').
:- use_module('datos.pl').
:- use_module('diametro.pl').
:- use_module('ruta_mas_short.pl').
:- use_module('Dijkstra.pl').
:- consult('interfaz.pl').




inicializar_interfaz :-
    iniciar_interfaz.