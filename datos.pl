% carga de datos

:- module(datos, [calle/4,manzana/3,cargar_calles/0,cargar_manzanas/0]).

:- use_module(library(csv)).

:- dynamic calle/4.
:- dynamic manzana/3.

cargar_manzanas:-
                retractall(manzana(_, _, _)), % borra todos los que quedaron cargados por si acaso
                csv_read_file('ManzanasLargo.csv', [_Encabezado | Filas], [functor(manzana), arity(3)]),% esto toma las manzanas y [_Encabezado | Filas] las separa en el encabezado (titulos ) y las filas importantes y lo convierte en una funcion manzana con aridad 3  [functor(manzana), arity(3)]
                cargar_filas(Filas).% llama a la recursión solo con las filas importantes
                
cargar_filas([]).% base recursion

cargar_filas([Fila | Resto]) :-% carga las filas una a una con recursión
                                assertz(Fila),% que lo guarde prolog
                                cargar_filas(Resto).% recursión

cargar_calles:-
                retractall(calle(_, _, _,_)), % borra todos los que quedaron cargados por si acaso
                csv_read_file('CallesLargo.csv', [_Encabezado | Filas], [functor(calle), arity(4)]),% esto toma las manzanas y [_Encabezado | Filas] las separa en el encabezado (titulos ) y las filas importantes y lo convierte en una funcion manzana con aridad 3  [functor(manzana), arity(3)]
                cargar_filas(Filas).% llama a la recursión solo con las filas importantes