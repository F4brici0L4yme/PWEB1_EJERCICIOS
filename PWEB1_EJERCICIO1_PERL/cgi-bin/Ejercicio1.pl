#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;

my $q = CGI->new;
my $name = $q->param("nombre"); 
my $dominio = $q->param("dominio"); #AQUÍ ALMACENO MIS RESPUESTAS EN ESCALARES PERL

print $q->header("text/html");
print<<BLOCK;
<!DOCTYPE html>
<html>
<head>
    <title>Correo creado</title>
        <style>
            body {
            display: flex;
            justify-content: center;
            align-items: center;       
            height: 100vh;             
            margin: 0;
            background-color: lightblue;
        }
        .h3 {
            text-align: center;
        }
    </style>
</head>
<body>
    <h3>Correo generado: $name\@$dominio</h3> <!--ACÁ SE CONCATENA EN UN CORREO SIN USAR .  -->
</body>
</html>
BLOCK
