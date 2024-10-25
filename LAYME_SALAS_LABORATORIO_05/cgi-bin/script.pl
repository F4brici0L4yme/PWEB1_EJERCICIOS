#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use List::Util;

my $q = CGI->new;
my $expresion = $q->param('expresion');

sub resolver_expresion {
    my ($exp) = @_;
    while ($exp =~ /\(([^()]+)\)/) {   # SE MANTIENE ACTIVO HASTA QUE YA NO HAYA PARÉNTESIS
        my $sub_exp = $1;    # ALMACENA LA EXPRESIÓN DENTRO DE PARÉNTESIS 
        my $resultado_sub = resolver_expresion($sub_exp);  # SE VUELVE A LLAMAR A LA FUNCIÓN PARA SEGUIR CON LAS DEMÁS OPERACIONES Y ELIMINAR PARÉNTESIS
        $exp =~ s/\([^()]+\)/$resultado_sub/;        #ACTUALIZA EL VALOR SIN PARÉNTESIS Y VUELVE AL BUCLE
    }
    my @expresion = split /([+\-*\/])/, $exp;   # SEPARA LA EXPRESIÓN CON AYUDA DE LOS OPERADORES
    @expresion = multiplicacionYdivision(@expresion);       # SE RESUELVE PRIMERO LA MULTIPLICACIÓN Y DIVISIÓN
    if (@expresion == 1 && $expresion[0] eq 'error_div0' || $expresion[2] eq 'error_div0') {  # MANEJA LA INDETERMINACIÓN DE DIVISIÓN POR 0
        return 'error de indeterminacion';  
    }
    my $resultado = sumaYresta(@expresion); 
    return $resultado;
}
sub multiplicacionYdivision {
    my @expresion = @_;
    my @nueva_expresion;

    while (@expresion) { #SE CONTINUA HASTA QUE EL ARREGLO ESTÉ VACÍO
        my $operador = shift @expresion; #DE LA SUBEXPRESION SACA AL PRIMERO
        if ($operador eq '*' || $operador eq '/') { #SI ES OPERADOR EMPIEZA ANALIZA EL QUE ESTÁ ANTES Y DESPUÉS DEL OPERADOR
            my $anterior = pop @nueva_expresion;
            my $siguiente = shift @expresion;
            if ($operador eq '*') {
                push @nueva_expresion, $anterior * $siguiente; # RETORNA EL RESULTADO DE UNA MULTIPLICACIÓN
            } elsif ($operador eq '/') {
                if ($siguiente == 0) {   # RETORNA UN STRING QUE MUESTRA SI HAY ERROR DE DIVISION POR 0
                    return ('error_div0');
                }
                push @nueva_expresion, $anterior / $siguiente; # RETORNA EL RESULTADO DE UNA DIVISIÓN
            }
        } else {
            push @nueva_expresion, $operador;
        }
    }
    
    return @nueva_expresion;
}

sub sumaYresta {
    my @expresion = @_;
    my $resultado = shift @expresion; 
    
    while (@expresion) {
        my $operador = shift @expresion; # ALMACENA EL DATO ANTERIOR AL OPERADOR
        my $siguiente = shift @expresion; # ALMACENA EL DATO POSTERIOR AL OPERADOR
        
        if ($operador eq '+') {
            $resultado += $siguiente; # RETORNA EL RESULTADO DE UNA SUMA
        } elsif ($operador eq '-') {
            $resultado -= $siguiente; # RETORNA EL RESULTADO DE UNA RESTA
        }
    }
    
    return $resultado;
}

my $resultado = '';
if ($expresion) { #REVISA QUE NO ESTÉ VACÍA LA EXPRESIÓN
    $resultado = resolver_expresion($expresion); # ALMACENA EL RESULTADO O EL MENSAJE DE ERROR
}

print $q->header;
print <<HTML;
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calculadora</title>
</head>
<body>
    <style>
        body {
            background-color: honeydew;
        }
        .formulario {
            display: flex;
            justify-content: center;
            align-items: center;       
            height: 400px;             
            margin: 0;
        }
        input[type="text"] {
            width: 300px;  
            height: 50px;  
        }
    </style>
    <div class="formulario">
        <form action="../cgi-bin/script.pl" method="get">
            <label for="notas"><h2>Ingrese alguna operacion para calcularla: </h2></label>
            <input type="text" name="expresion" placeholder="Ingrese alguna expresion aqui...">
            <input type="submit" value="Calcular">
        </form>
    </div>
    <div style="text-align: center;">
        <h3>Resultado:</h3>
        <p>$resultado</p>
    </div>
</body>
</html>
HTML
