% Requiere SWI-Prolog con XPCE.

:- use_module(library(pce)).
:- use_module('datos.pl').
:- use_module('Dijkstra.pl').
:- use_module('ruta_mas_corta.pl').
:- use_module('rutas_posibles.pl').
:- use_module('conectividad.pl').
:- use_module('diametro.pl').
:- use_module('ford_fulkerson.pl').


% Ventana principal

iniciar_interfaz :-
    new(Dialogo, dialog('GPS - Manzanas y calles')),
    send(Dialogo, append, label(ayuda1, 'Ingrese las manzanas y calles del mapa. Ejemplo:')),
    send(Dialogo, append, label(ayuda2, 'Manzanas: [a,b,c,d]    Calles: [a-b-4, a-c-2, c-b-1, b-d-5]')),

    send(Dialogo, append, new(NodosItem, text_item(manzanas))),
    send(NodosItem, selection, '[a,b,c,d]'),
    send(NodosItem, length, 70),

    send(Dialogo, append, new(AristasItem, text_item(calles))),
    send(AristasItem, selection, '[a-b-4, a-c-2, c-b-1, b-d-5]'),
    send(AristasItem, length, 70),

    send(Dialogo, append, new(OrigenItem, text_item(origen))),
    send(OrigenItem, selection, 'a'),

    send(Dialogo, append, new(DestinoItem, text_item(destino))),
    send(DestinoItem, selection, 'd'),

    send(Dialogo, append, new(Resultado, label(resultado, 'Resultado:'))),

    send(Dialogo, append,
         button('Ruta mas corta',
                message(@prolog, accion_ruta_mas_corta,
                        NodosItem?selection,
                        AristasItem?selection,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Resultado))),

    send(Dialogo, append,
         button('Conectividad',
                message(@prolog, accion_conectividad,
                        NodosItem?selection,
                        AristasItem?selection,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Resultado))),

    send(Dialogo, append,
         button('Todas las rutas',
                message(@prolog, accion_todas_las_rutas,
                        NodosItem?selection,
                        AristasItem?selection,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Resultado))),

    send(Dialogo, append,
         button('Diametro',
                message(@prolog, accion_diametro,
                        NodosItem?selection,
                        AristasItem?selection,
                        Resultado))),

    send(Dialogo, append,
         button('Cargar CSV manzanas/calles',
                message(@prolog, cargar_csv_en_interfaz,
                        NodosItem,
                        AristasItem,
                        Resultado))),

    send(Dialogo, append,
         button('Salir', message(Dialogo, destroy))),

    send(Dialogo, open).


% Acciones de los botones


% Carga las manzanas y calles definidas en los CSV y lo copia a los campos de la interfaz.
% Despues de apretar este boton, se pueden usar los demas botones normalmente.
cargar_csv_en_interfaz(NodosItem, AristasItem, Resultado) :-
    cargar_manzanas,
    cargar_calles,

    findall(Nodo, manzana(Nodo, _, _), NodosRepetidos),
    sort(NodosRepetidos, Nodos),

    findall(Origen-Destino-Peso, calle(_, Origen, Destino, Peso), Aristas),

    term_to_atom(Nodos, NodosTexto),
    term_to_atom(Aristas, AristasTexto),

    send(NodosItem, selection, NodosTexto),
    send(AristasItem, selection, AristasTexto),

    length(Nodos, CantidadNodos),
    length(Aristas, CantidadAristas),
    format(atom(Mensaje),
           'CSV cargado: ~w manzanas y ~w calles.',
           [CantidadNodos, CantidadAristas]),

    actualizar_resultado(Resultado, Mensaje),
    send(@display, inform, Mensaje).

accion_ruta_mas_corta(NodosTexto, AristasTexto, OrigenTexto, DestinoTexto, Resultado) :-
    (   preparar_grafo(NodosTexto, AristasTexto, _Nodos, _Aristas),
        leer_termino(OrigenTexto, Origen),
        leer_termino(DestinoTexto, Destino)
    ->  (   dijkstra(Origen, Destino, Camino, Costo)
        ->  formato_camino(Camino, CaminoTexto),
            format(atom(Mensaje), 'Resultado: ruta mas corta = ~w | costo = ~w', [CaminoTexto, Costo]),
            actualizar_resultado(Resultado, Mensaje),
            send(@display, inform, Mensaje)
        ;   informar_error(Resultado, 'No existe ruta entre el origen y el destino.')
        )
    ;   informar_error(Resultado, 'Error: revise el formato de entrada.')
    ).

accion_conectividad(NodosTexto, AristasTexto, OrigenTexto, DestinoTexto, Resultado) :-
    (   preparar_grafo(NodosTexto, AristasTexto, _Nodos, _Aristas),
        leer_termino(OrigenTexto, Origen),
        leer_termino(DestinoTexto, Destino)
    ->  (   conectado(Origen, Destino)
        ->  format(atom(Mensaje), 'Resultado: si hay camino de ~w a ~w.', [Origen, Destino])
        ;   format(atom(Mensaje), 'Resultado: no hay camino de ~w a ~w.', [Origen, Destino])
        ),
        actualizar_resultado(Resultado, Mensaje),
        send(@display, inform, Mensaje)
    ;   informar_error(Resultado, 'Error: revise el formato de entrada.')
    ).

accion_todas_las_rutas(NodosTexto, AristasTexto, OrigenTexto, DestinoTexto, Resultado) :-
    (   preparar_grafo(NodosTexto, AristasTexto, _Nodos, _Aristas),
        leer_termino(OrigenTexto, Origen),
        leer_termino(DestinoTexto, Destino)
    ->  findall(Ruta-Costo, calcular_ruta_con_pesos(Origen, Destino, Ruta, Costo), Rutas),
        length(Rutas, Cantidad),
        term_to_atom(Rutas, RutasTexto),
        format(atom(Mensaje), 'Resultado: se encontraron ~w rutas: ~w', [Cantidad, RutasTexto]),
        actualizar_resultado(Resultado, Mensaje)
    ;   informar_error(Resultado, 'Error: revise el formato de entrada.')
    ).

accion_diametro(NodosTexto, AristasTexto, Resultado) :-
    (   preparar_grafo(NodosTexto, AristasTexto, _Nodos, _Aristas)
    ->  (   diametro(Desde, Hasta, Diametro)
        ->  format(atom(Mensaje), 'Resultado: diametro = ~w, entre ~w y ~w.', [Diametro, Desde, Hasta]),
            actualizar_resultado(Resultado, Mensaje),
            send(@display, inform, Mensaje)
        ;   informar_error(Resultado, 'No se pudo calcular el diametro. Revise que el grafo sea conexo.')
        )
    ;   informar_error(Resultado, 'Error: revise el formato de manzanas y calles.')
    ).


% Carga de manzanas y calles desde la interfaz

preparar_grafo(NodosTexto, AristasTexto, Nodos, AristasNormalizadas) :-
    leer_termino(NodosTexto, Nodos),
    leer_termino(AristasTexto, AristasSinNormalizar),
    is_list(Nodos),
    is_list(AristasSinNormalizar),
    maplist(normalizar_arista, AristasSinNormalizar, AristasNormalizadas),
    cargar_grafo_generico(Nodos, AristasNormalizadas).

leer_termino(Valor, Termino) :-
    texto_a_string(Valor, String),
    catch(term_string(Termino, String), _, fail).

texto_a_string(Valor, String) :-
    (   string(Valor)
    ->  String = Valor
    ;   atom(Valor)
    ->  atom_string(Valor, String)
    ;   term_string(Valor, String)
    ).

normalizar_arista(Origen-Destino-Peso, Origen-Destino-Peso) :-
    number(Peso), !.
normalizar_arista(arco(Origen, Destino, Peso), Origen-Destino-Peso) :-
    number(Peso), !.
normalizar_arista(calle(_, Origen, Destino, Peso), Origen-Destino-Peso) :-
    number(Peso), !.

cargar_grafo_generico(Nodos, Aristas) :-
    retractall(datos:manzana(_, _, _)),
    retractall(datos:calle(_, _, _, _)),
    posiciones_para_nodos(Nodos, Posiciones),
    forall(
        member(Nodo-X-Y, Posiciones),
        assertz(datos:manzana(Nodo, X, Y))
    ),
    cargar_aristas_genericas(Aristas, 1).

cargar_aristas_genericas([], _).
cargar_aristas_genericas([Origen-Destino-Peso | Resto], N) :-
    atomic_list_concat([arista, N], Nombre),
    assertz(datos:calle(Nombre, Origen, Destino, Peso)),
    N2 is N + 1,
    cargar_aristas_genericas(Resto, N2).


% Posiciones auxiliares para crear manzana/3 desde la interfaz

posiciones_para_nodos(Nodos, Posiciones) :-
    length(Nodos, Cantidad),
    Cantidad > 0,
    posiciones_para_nodos(Nodos, Cantidad, 0, Posiciones).

posiciones_para_nodos([], _Cantidad, _Indice, []).

posiciones_para_nodos([Nodo | Resto], Cantidad, Indice, [Nodo-X-Y | PosicionesResto]) :-
    Angulo is 2 * pi * Indice / Cantidad,
    X is 450 + 250 * cos(Angulo),
    Y is 320 + 220 * sin(Angulo),
    Indice2 is Indice + 1,
    posiciones_para_nodos(Resto, Cantidad, Indice2, PosicionesResto).


% Utilidades de salida

formato_camino(Camino, Texto) :-
    maplist(term_to_atom, Camino, Partes),
    atomic_list_concat(Partes, ' -> ', Texto).

actualizar_resultado(Label, Mensaje) :-
    send(Label, selection, Mensaje).

informar_error(Label, Mensaje) :-
    actualizar_resultado(Label, Mensaje),
    send(@display, inform, Mensaje).
