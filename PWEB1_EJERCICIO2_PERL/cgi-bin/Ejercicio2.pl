#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use List::Util qw(min max sum);
my $q = CGI->new;
my $input = $q->param("notas");

my @notas = split(/\s*-\s*/, $input);
my @notas_ordenadas = sort { $a <=> $b } @notas; #ASÍ EVITO USAR CONDICIONALES

my $min_nota = min(@notas);
my $max_nota = max(@notas);
splice(@notas_ordenadas, 0, 1); #AQUÍ SE HACE LA ELIMINACIÓN DE LA MENOR NOTAS, SIN USAR IFS
push @notas_ordenadas, $max_nota; # AQUÍ SE HACE SE DUPLICA LA MAYOR NOTA
my $promedio = (sum(@notas_ordenadas)/scalar(@notas_ordenadas));
print $q->header("text/html");

print<<BLOCK;
<!DOCTYPE html>
<html>
<head>
    <title>Promedio Calculado</title>
    <style>
        body {
            background-color: lightblue;
        }
        h3, h4 {
            text-align: center;
        }
    </style>
</head>
<body>
    <h3>La nota eliminada fue: $min_nota</h3>
    <h3>Fue reemplazada con: $max_nota</h3>
    <h3>Asi quedan las notas que se ingreso:</h3>
BLOCK
    foreach my $nota (@notas_ordenadas) {
        print "<h4>$nota</h4>";
    }
print<<BLOCK;
    <h3>El promedio de las notas es: $promedio</h3>
</body>
</html>
BLOCK
