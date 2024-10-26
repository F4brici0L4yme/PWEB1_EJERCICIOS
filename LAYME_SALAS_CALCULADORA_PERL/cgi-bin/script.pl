#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
my $q = CGI->new;
my $expresion = $q->param('expresion'); # Con el objeto CGI se guarda la expresión ingresada en el formulario
sub resolver_expresion {
    my ($exp) = @_;
    $exp =~ s/\s+//g; # Reemplaza los espacios ingresados por teclado por nada
    while ($exp =~ /\(([^()]+)\)/) { # Encuentra los paréntesis de la operación, los resuelve y reemplaza por su resultado hasta que no quede ninguno
        my $sub_expresion = $1;
        my $resultado_sub = resolver_expresion($sub_expresion);
        return 'error de indeterminacion' if $resultado_sub eq 'error de indeterminacion'; # Evalue si hubo alguna división entre 0
        $exp =~ s/\([^()]+\)/$resultado_sub/;
    }
    my @expresion = split /(?<=[\d)])([+\-*\/])|(?=[-+])/, $exp; # Para el procesamiento de texto, divide la expresion en números y operadores
    @expresion = multiplicacionYdivision(@expresion);
    if (@expresion == 1 && $expresion[0] eq 'error de indeterminacion') {
        return 'error de indeterminacion';
    }
    my $resultado = sumaYresta(@expresion);
    return $resultado;
}
sub multiplicacionYdivision {
    my @expresion = @_;
    my @nueva_expresion;
    while (@expresion) {
        my $elemento = shift @expresion;
        if ($elemento eq '*' || $elemento eq '/') { # Se pregunta si la operación es operador de multiplicación o división
            my $anterior = pop @nueva_expresion;
            my $siguiente = shift @expresion;
            if ($elemento eq '/' && $siguiente == 0) { # Verifica si existe división entre 0
                return ('error de indeterminacion'); # Devuelve el mensaje para que se termine el bucle
            }
            if ($elemento eq '*') { # Evalua si el operador es multiplicación
                push @nueva_expresion, $anterior * $siguiente;
            } elsif ($elemento eq '/') { # Evalua si el operador es división
                push @nueva_expresion, $anterior / $siguiente;
            }
        } else {
            push @nueva_expresion, $elemento; # Agrega $elemento sin cambios
        }
    }
    return @nueva_expresion;
}
sub sumaYresta { # Por orden en operaciones se ejecuta después de la función anterior
    my @expresion = @_;
    my $resultado = shift @expresion;

    while (@expresion) {
        my $operador = shift @expresion;
        my $siguiente = shift @expresion;

        if ($operador eq '+') { # Evalua si el operador es suma
            $resultado += $siguiente;
        } elsif ($operador eq '-') { # Evalua si el operador es resta
            $resultado -= $siguiente;
        }
    }
    return $resultado;
}
my $resultado = ''; # Inicializa el resultado pero vacío
if ($expresion) {
    $resultado = resolver_expresion($expresion);
}
print $q->header;
print <<HTML;
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calculadora</title>
    <style>
        body {
            background-color: #2d3e50;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            font-family: Arial, sans-serif;
        }
        .formulario {
            background-color: #fff;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
        }
        input[type="submit"] {
            width: 100%;
            background-color: #28a745;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 5px;
            font-size: 18px;
            cursor: pointer;
        }
        h2, h3, p {
            color: black;
        }
        .resultado {
            margin-top: 20px;
        }
        .resultado h3 {
            margin-bottom: 5px;
        }
        .footer {
            padding: 10px;
           margin: 0px;
           left: 0;
           bottom: 0;
           width: 100%;
           background-color: #f2f2f2;
           color: #337ab7;
           text-align: center;
           font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="formulario">
        <form action="../cgi-bin/script.pl" method="get">
            <h2>Ingrese alguna operacion para calcularla:</h2>
            <input type="text" name="expresion" placeholder="$expresion">
            <input type="submit" value="Calcular">
        </form>
        <div class="resultado">
            <h3>Resultado:</h3>
            <p>$resultado</p>
        </div>
        <footer class="footer">		
            Layme Salas, Rodrigo Fabricio &copy; 2024/10/26 - Programacion Web Lab. Grupo D.	  		
        </footer>
    </div>
</body>
</html>
HTML
