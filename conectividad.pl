% chequear si dos nodos están conectados

:- module(conectividad, [conectado/2]).

:- use_module('datos.pl').
:- use_module('rutas_posibles.pl').

conectado(Origen,Destino):- 
                            dfs(Origen,Destino,[Origen],_). % llama a dfs sin especificar ruta y si encuentra alguna entonces estan conectados
