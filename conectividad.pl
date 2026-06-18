% chequear si dos nodos están conectados

:- module(conectividad, [conectado/2]).

:- use_module('datos.pl').
:- use_module('rutas_posibles.pl').
:-use_module('Dijkstra.pl').

conectado(Origen,Destino):- 
                            dijkstra(Origen,Destino,_,_),!. % llama a dfs sin especificar ruta y si encuentra alguna entonces estan conectados
