% encontrar las rutas para llegar de un lado a otro, similar a depth first search 

:- module(rutas_posibles, [ruta/3, dfs/4, encontrar_todas_rutas/3]).

:- use_module('datos.pl').

ruta(Origen, Destino, Ruta) :-
                            dfs(Origen, Destino, [Origen], RutaInvertida),% intento encontrar el camino basicamente probando todos los caminos  posibles
                            reverse(RutaInvertida, Ruta). % da vuelta la lista (Porque en Prolog las listas se construyen agregando al frente, no al final)

dfs(Destino, Destino, Visitados, Visitados).% caso base es decir ya estoy en el destino

dfs(Actual, Destino, Visitados, Ruta) :-% me paro en donde estoy 
                                        calle(_,Actual, Siguiente,_),% tomo con los que estoy conectado
                                        \+ member(Siguiente, Visitados),% me fijo si ya los visite 
                                        dfs(Siguiente, Destino, [Siguiente | Visitados], Ruta).% si no los visite voy hacia ellos y vuelo a la recurción

encontrar_todas_rutas(X,Y,Ruta):-
    ruta(X,Y,Ruta).