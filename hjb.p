
calle_transitiva(Nombre, X, Y) :-
    calle(Nombre, X, Y).



calle_transitiva(Nombre, X, Y) :-

    % Busca un arco directo X → W en el CSV
    % usamos calle/3 y no calle_transitiva para no entrar en loop
    calle(_, X, W),

    % De W a Y puede ser cualquier camino, aqui si usamos recursion
    calle_transitiva(_, W, Y),

    % Construye el nombre: X + '-' + Y
    % Ejemplo: X=A1, Y=C3 → Nombre = 'A1-C3'
    atom_concat(X, '-', Tmp),
    atom_concat(Tmp, Y, Nombre).


calle_transitiva(Nombre, X, Y) :-
    calle_transitiva(_, X, W),  % ← se llama a sí misma desde el principio
    calle_transitiva(_, W, Y).


conectado(O)


