:- module(ford_fulkerson, [
    flujo_maximo/3,
    flujo_maximo/4,
    camino_aumentante/5
]).

:- use_module('datos.pl').


flujo_maximo(Origen, Destino, FlujoMaximo) :-
    red_residual_inicial(ResidualInicial),
    ford_fulkerson(Origen, Destino, ResidualInicial, 0, FlujoMaximo, _ResidualFinal).

flujo_maximo(Origen, Destino, FlujoMaximo, FlujosPorArco) :-
    red_residual_inicial(ResidualInicial),
    ford_fulkerson(Origen, Destino, ResidualInicial, 0, FlujoMaximo, ResidualFinal),
    flujos_finales(ResidualFinal, FlujosPorArco).

red_residual_inicial(Residual) :-
    findall(r(U, V, C), calle(_, U, V, C), Directos),
    findall(r(V, U, 0), calle(_, U, V, _), Reversos),
    append(Directos, Reversos, ResidualConDuplicados),
    combinar_arcos_residuales(ResidualConDuplicados, Residual).

combinar_arcos_residuales([], []).
combinar_arcos_residuales([r(U,V,C)|Resto], [r(U,V,Total)|Combinados]) :-
    extraer_arcos(U, V, Resto, Mismos, Otros),
    sumar_capacidades([r(U,V,C)|Mismos], Total),
    combinar_arcos_residuales(Otros, Combinados).

extraer_arcos(_, _, [], [], []).
extraer_arcos(U, V, [r(U,V,C)|Resto], [r(U,V,C)|Mismos], Otros) :-
    !,
    extraer_arcos(U, V, Resto, Mismos, Otros).
extraer_arcos(U, V, [Arco|Resto], Mismos, [Arco|Otros]) :-
    extraer_arcos(U, V, Resto, Mismos, Otros).

sumar_capacidades([], 0).
sumar_capacidades([r(_,_,C)|Resto], Total) :-
    sumar_capacidades(Resto, Subtotal),
    Total is C + Subtotal.

ford_fulkerson(Origen, Destino, Residual, Acumulado, FlujoMaximo, ResidualFinal) :-
    camino_aumentante(Origen, Destino, Residual, Camino, CuelloBotella),
    !,
    actualizar_camino(Camino, CuelloBotella, Residual, ResidualActualizada),
    NuevoAcumulado is Acumulado + CuelloBotella,
    ford_fulkerson(Origen, Destino, ResidualActualizada, NuevoAcumulado, FlujoMaximo, ResidualFinal).

ford_fulkerson(_, _, Residual, FlujoMaximo, FlujoMaximo, Residual).

camino_aumentante(Origen, Destino, Residual, Camino, CuelloBotella) :-
    buscar_camino(Origen, Destino, Residual, [Origen], Camino, CuelloBotella).

buscar_camino(Destino, Destino, _, _, [], infinito).
buscar_camino(Actual, Destino, Residual, Visitados, [Actual-Siguiente|Camino], CuelloBotella) :-
    member(r(Actual, Siguiente, Capacidad), Residual),
    Capacidad > 0,
    \+ member(Siguiente, Visitados),
    buscar_camino(Siguiente, Destino, Residual, [Siguiente|Visitados], Camino, CuelloResto),
    minimo_capacidad(Capacidad, CuelloResto, CuelloBotella).

minimo_capacidad(Capacidad, infinito, Capacidad) :- !.
minimo_capacidad(Capacidad, OtraCapacidad, Minimo) :-
    Minimo is min(Capacidad, OtraCapacidad).

actualizar_camino([], _, Residual, Residual).
actualizar_camino([U-V|Resto], Flujo, Residual, ResidualFinal) :-
    disminuir_capacidad(U, V, Flujo, Residual, Residual1),
    aumentar_capacidad(V, U, Flujo, Residual1, Residual2),
    actualizar_camino(Resto, Flujo, Residual2, ResidualFinal).

disminuir_capacidad(U, V, Flujo, [r(U,V,C)|Resto], [r(U,V,NuevaC)|Resto]) :-
    !,
    NuevaC is C - Flujo.
disminuir_capacidad(U, V, Flujo, [Arco|Resto], [Arco|NuevoResto]) :-
    disminuir_capacidad(U, V, Flujo, Resto, NuevoResto).

aumentar_capacidad(U, V, Flujo, [], [r(U,V,Flujo)]).
aumentar_capacidad(U, V, Flujo, [r(U,V,C)|Resto], [r(U,V,NuevaC)|Resto]) :-
    !,
    NuevaC is C + Flujo.
aumentar_capacidad(U, V, Flujo, [Arco|Resto], [Arco|NuevoResto]) :-
    aumentar_capacidad(U, V, Flujo, Resto, NuevoResto).

flujos_finales(ResidualFinal, FlujosPorArco) :-
    findall(
        flujo(U, V, Capacidad, Flujo),
        (
            calle(_, U, V, Capacidad),
            capacidad_residual(U, V, ResidualFinal, CapacidadRestante),
            Flujo is Capacidad - CapacidadRestante
        ),
        FlujosPorArco
    ).

capacidad_residual(U, V, [r(U,V,C)|_], C) :- !.
capacidad_residual(U, V, [_|Resto], C) :-
    capacidad_residual(U, V, Resto, C).
capacidad_residual(_, _, [], 0).
