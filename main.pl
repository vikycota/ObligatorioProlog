:- use_module(library(csv)).

:- dynamic calle/4.
:- dynamic manzana/3.

cargar_manzanas:-
                retractall(manzana(_, _, _)), % borra todos los q quedaron cargados por si acaso
                csv_read_file('Manzanas.csv', [_Encabezado | Filas], [functor(manzana), arity(3)]),% esto toma las manzanas y [_Encabezado | Filas] las separa en el encabezado (titulos ) y las filas importantes y lo convierte en una funcion manzana con aridad 3  [functor(manzana), arity(3)]
                cargar_filas(Filas).% llama a la recursion solo con las filas importantes
                


cargar_filas([]).% base recursion

cargar_filas([Fila | Resto]) :-% carga las filas una a una con recurcion
                                assertz(Fila),% que lo guarde prolog
                                cargar_filas(Resto).% recurción



cargar_calles:-
                retractall(calle(_, _, _,_)), % borra todos los q quedaron cargados por si acasp
                csv_read_file('Calles.csv', [_Encabezado | Filas], [functor(calle), arity(4)]),% esto toma las manzanas y [_Encabezado | Filas] las separa en el encabezado (titulos ) y las filas importantes y lo convierte en una funcion manzana con aridad 3  [functor(manzana), arity(3)]
                cargar_filas(Filas).% llama a la recursion solo con las filas importantes
                
                
% encontrar las rutas para llegar de un lado a otro, similar a depth first search

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
    


conectado(Origen,Destino):- 
                            dfs(Origen,Destino,[Origen],_). % llama a dfs sin especificar ruta y si encuentra algun entonces estan conectados




%Calcular mas eficiente inicio

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
    findall(Peso, Ruta),
            calcular_ruta_con_pesos(X, Y, Peso),
    sort(Rutas, [(MenorPeso, MejorRuta) | _]).
