:- module(Dijkstra, [dijkstra/4]).
:- use_module('datos.pl').


dijkstra(Origen, Destino, Ruta, Peso) :-
    dijkstra_recur([(0, Origen, [Origen])], Destino, [], RutaInv, Peso),% peso acumulado, nodo actual, ruta actual, destino, nodos visitados
    reverse(RutaInv, Ruta).

dijkstra_recur([(Peso, Destino, Ruta) | _], Destino, _, Ruta, Peso).% como el actual es el destino ya terminaste, el |_] dice q las otras cosas de la frontera no me interesan

dijkstra_recur([(_,Actual, _) | RestoFrontera],Destino,Visitados,RutaFinal,PesoFinal) :-
    member(Actual, Visitados),
    dijkstra_recur(RestoFrontera, Destino, Visitados, RutaFinal, PesoFinal).% si ya lo visite lo salteo

dijkstra_recur([(PesoActual, Actual, RutaActual) | RestoFrontera], Destino,Visitados,RutaFinal,PesoFinal) :-
    \+ member(Actual, Visitados),% si no esta en los que visite
    findall( % findall(Que guardo, condiciones, Nombre del resultado)
        (NuevoPeso, Vecino, [Vecino | RutaActual]),
        (encuentra_vecinos(NuevoPeso,Vecino,Actual,PesoActual,Visitados)),
        NuevosCaminos
    ),% basicamente genera todos los caminos desde el nodo que puedan haber y que no ya los hallamos visitado

    append(RestoFrontera, NuevosCaminos, Frontera),% Une la frontera que ya tenías con las nuevas que encontraste y las llama frontera
    sort(Frontera, FronteraOr),% los ordena
    dijkstra_recur(FronteraOr,Destino,[Actual | Visitados],RutaFinal,PesoFinal).%Recursion y agrega a los visitados el actual

encuentra_vecinos(NuevoPeso, Vecino,Actual,Peso,Visitados):-%Encuentra todos los vecinos q no visite y les calcula la suma del peso
    (calle(_, Actual, Vecino, PesoCalle),
    \+ member(Vecino, Visitados),
    NuevoPeso is Peso + PesoCalle).
