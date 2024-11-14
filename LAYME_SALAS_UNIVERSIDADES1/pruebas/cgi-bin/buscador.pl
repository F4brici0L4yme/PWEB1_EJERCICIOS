#!/usr/bin/perl -w
use strict;
use warnings;
use Text::CSV;
use utf8;
use CGI qw(:standard);
use Encode;
use open ':std', ':encoding(UTF-8)';
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

my @universidades;
my $nombre = decode('UTF-8', param('NOMBRE') || '');
my $tipo_gestion = decode('UTF-8', param('TIPO_GESTION') || '');
my $estado_licenciamiento = decode('UTF-8', param('ESTADO_LICENCIAMIENTO') || '');
my $fecha_inicio_licenciamiento = decode('UTF-8', param('FECHA_INICIO') || '');
my $fecha_fin_licenciamiento = decode('UTF-8', param('FECHA_FIN') || '');
my $periodo_licenciamiento = decode('UTF-8', param('PERIODO_LICENCIAMIENTO') || '');
my $departamento = decode('UTF-8', param('DEPARTAMENTO') || '');
my $provincia = decode('UTF-8', param('PROVINCIA') || '');
my $distrito = decode('UTF-8', param('DISTRITO') || '');
my $csv = Text::CSV->new({ sep_char => ",", binary => 1, auto_diag => 1 });
open(my $fh, '<:encoding(UTF-8)', 'Data_Universidades_LAB06.csv') or die "No se pudo abrir el archivo: $!";
my $header = $csv->getline($fh);
sub convertir_fecha_a_yyyymmdd {
    my ($fecha) = @_;
    $fecha =~ s/-//g;
    return $fecha;
}
$fecha_inicio_licenciamiento = convertir_fecha_a_yyyymmdd($fecha_inicio_licenciamiento);
$fecha_fin_licenciamiento = convertir_fecha_a_yyyymmdd($fecha_fin_licenciamiento);

while (my $row = $csv->getline($fh)) {
    my ($codigo, $nombre_u, $tipo, $estado, $inicio, $fin, $periodo, $dpto, $prov, $dist, $ubigeo, $latitud, $longitud, $fecha_corte) = @$row;
    if (($nombre_u =~ /\Q$nombre\E/i) && 
        ($tipo_gestion eq '' || $tipo =~ /\Q$tipo_gestion\E/i) &&   
        ($estado_licenciamiento eq '' || $estado =~ /\Q$estado_licenciamiento\E/i) && 
        ($fecha_inicio_licenciamiento eq '' || $inicio =~ /\Q$fecha_inicio_licenciamiento\E/i) && 
        ($fecha_fin_licenciamiento eq '' || $fin =~ /\Q$fecha_fin_licenciamiento\E/i) &&
        ($periodo_licenciamiento eq '' || $periodo =~ /\Q$periodo_licenciamiento\E/i) &&  
        ($departamento eq '' || $dpto =~ /\Q$departamento\E/i) &&
        ($provincia eq '' || $prov =~ /\Q$provincia\E/i) &&
        ($distrito eq '' || $dist =~ /\Q$distrito\E/i)) {
        push(@universidades, $row);
    }
}
close $fh;

print header(-type => 'text/html', -charset => 'UTF-8');
print start_html(-title => "Resultados de Universidades", -encoding => 'UTF-8');
print << "FORM";
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Universidades Peruanas</title>
    <style>
        body {
            font-family: sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            min-height: 100vh;
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: flex-start;
            background-size: cover;
            background-position: center;
            overflow-y: auto;
            padding-top: 50px;
            background-image: url('https://www.sunedu.gob.pe/wp-content/uploads/2019/06/foto-fachada-sunedu-06.jpg');
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        .formulario {
            background: rgb(0, 0, 0, 0.1);
            width: 320px;
            padding: 24px;
            border-radius: 16px;
            border: solid 5px rgb(255, 255, 255, 0.1);
            backdrop-filter: blur(25px);
            box-shadow: 0px 0px 30px 20px rgb(0, 0, 0, 0.1);
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 50px;
        }

        .titulo {
            margin-bottom: 16px;
            text-align: center;
        }

        .input-part {
            display: flex;
            width: 100%;
            position: relative;
            margin-top: 20px;
        }

        .input-part input {
            width: 100%;
            padding: 10px 16px 10px 38px;
            border-radius: 90px;
            border: solid 3px transparent;
            background: rgb(255, 255, 255, 0.1);
            outline: none;
            caret-color: white;
            color: white;
            font-weight: 500;
        }

        .input-part input:focus {
            border: solid rgb(255, 255, 255, 0.25);
        }

        .input-part input::placeholder {
            color: rgba(255, 255, 255, 0.75);
        }

        .input-part :hover {
            border: solid 3px rgba(255, 255, 255, 0.25);
        }

        .buscar {
            width: 100%;
            margin-top: 24px;
            padding: 10px;
            background: #5758588a;
            border: none;
            border-radius: 90px;
            color: white;
            font-weight: bold;
            font-size: 15px;
            cursor: pointer;
            outline: transparent 3px solid;
        }

        .buscar:focus {
            outline: #a0a3a38a;
        }

        label {
            font-size: 13px;
            color: white;
            font-weight: bold;
            border-radius: 10px;
            padding: 4px;
        }

        .input-part select {
            width: 100%;
            padding: 10px 16px 10px 38px;
            border-radius: 90px;
            border: solid 3px transparent;
            background: rgb(255, 255, 255, 0.1);
            outline: none;
            color: white;
            font-weight: 500;
            appearance: none;
        }

        .input-part select option {
            background: #8587888a;
            color: white;
        }

        .input-part select option:first-child {
            background: rgba(255, 255, 255, 0.75);
            color: rgba(100, 100, 100, 1);
        }
    </style>
</head>
<body>
    <div class="formYError">
    <form class="formulario" action="./buscador.pl" method="get">
        <h1 class="titulo">Buscador de Universidades</h1>

        <div class="input-part">
            <input type="text" name="NOMBRE" id="NOMBRE" placeholder="Nombre de la universidad (con tildes)">
        </div>

        <div class="input-part">
            <select name="TIPO_GESTION" id="TIPO_GESTION">
                <option value="TIPO" disabled selected >Tipo de gestion</option>
                <option value="PRIVADO">Privado</option>
                <option value="PÚBLICO">Publico</option>
            </select>
        </div>

        <div class="input-part">
            <select name="ESTADO_LICENCIAMIENTO" id="ESTADO_LICENCIAMIENTO">
                <option value="ESTADO" disabled selected >Estado de licenciamiento</option>
                <option value="LICENCIA OTORGADA">Licencia otorgada</option>
                <option value="LICENCIA DENEGADA">Licencia denegada</option>
                <option value="NO PRESENTADO">No presentado</option>
            </select>
        </div>

        <div class="input-part">
            <label>Fecha inicio</label>
            <input type="date" name="FECHA_INICIO" id="FECHA_INICIO" >
        </div>

        <div class="input-part">
            <label>Fecha fin</label>
            <input type="date" name="FECHA_FIN" id="FECHA_FIN" >
        </div>

        <div class="input-part">
            <input type="text" name="PERIODO_LICENCIAMIENTO" id="PERIODO_LICENCIAMIENTO" placeholder="Periodo de licenciamiento (años)">
        </div>

        <div class="input-part">
            <select name="DEPARTAMENTO" id="DEPARTAMENTO">
                <option value="DEPARTAMENTO" disabled selected >Departamento</option>
                <option value="ÁNCASH">Ancash</option>
                <option value="AREQUIPA">Arequipa</option>
                <option value="AYACUCHO">Ayacucho</option>
                <option value="AMAZONAS">Amazonas</option>
                <option value="CAJAMARCA">Cajamarca</option>
                <option value="CALLAO">Callao</option>
                <option value="CUSCO">Cusco</option>
                <option value="HUÁNUCO">Huánuco</option>
                <option value="HUANCAVELICA">Huancavelica</option>
                <option value="ICA">Ica</option>
                <option value="JUNÍN">Junín</option>
                <option value="LA LIBERTAD">La Libertad</option>
                <option value="LAMBAYEQUE">Lambayeque</option>
                <option value="LIMA">Lima</option>
                <option value="LORETO">Loreto</option>
                <option value="MOQUEGUA">Moquegua</option>
                <option value="PASCO">Pasco</option>
                <option value="PIURA">Piura</option>
                <option value="PUNO">Puno</option>
                <option value="SAN MARTÍN">San Martín</option>
                <option value="TACNA">Tacna</option>
                <option value="TUMBES">Tumbes</option>
                <option value="UCAYALI">Ucayali</option>
            </select>
        </div>

        <div class="input-part">
                <input type="text" name="PROVINCIA" id="PROVINCIA" placeholder="Provincia">
        </div>

        <div class="input-part">
            <input type="text" name="DISTRITO" id="DISTRITO" placeholder="Distrito">
        </div>
        <button class="buscar" type="submit">Buscar</button>
    </form>
    </div>
</body>
</html>
FORM

if (@universidades == 1) {
    my $univ = $universidades[0];
    my ($codigo, $nombre_u, $tipo, $estado, $inicio, $fin, $periodo, $dpto, $prov, $dist, $ubigeo, 
        $latitud, $longitud, $fecha_corte) = @$univ;

print << "FORM";
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Google Maps</title>
        <style>
            body {
                font-family: sans-serif;
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: flex-start;
                background-size: cover;
                background-position: center;
                overflow-y: auto;
                padding-top: 50px;
                background-image: url('https://www.sunedu.gob.pe/wp-content/uploads/2019/06/foto-fachada-sunedu-06.jpg');
                background-repeat: no-repeat;
                background-attachment: fixed;
            }

            .map-container {
                background: rgba(0, 0, 0, 0.1);
                width: 640px;
                padding: 24px;
                border-radius: 16px;
                border: solid 5px rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(25px);
                box-shadow: 0px 0px 30px 20px rgba(0, 0, 0, 0.1);
                color: white;
                display: flex;
                flex-direction: column;
                align-items: center;
                margin: 50px;
                margin-top: 20px;
            }

            iframe {
                border: none;
                border-radius: 16px;
                width: 100%;
                height: 450px;
                margin-top: 16px;
            }

            .resultado {
                background: rgba(0, 0, 0, 0.1);
                padding: 24px;
                border-radius: 16px;
                border: solid 5px rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(25px);
                box-shadow: 0px 0px 30px 20px rgba(0, 0, 0, 0.1);
                color: white;
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-top: 50px;
                width: 90%;
            }

            .resultado-mensaje {
                text-align: center;
                color: #fff;
                margin-bottom: 20px;
                font-size: 18px;
            }

            .cabecera, .fila {
                display: grid;
                grid-template-columns: repeat(10, 1fr);
                gap: 10px;
                width: 100%;
                padding: 10px;
            }

            .cabecera {
                background-color: #333;
                color: white;
                font-weight: bold;
                border-radius: 10px;
                font-size: 14px;
            }

            .fila:nth-child(even) {
                background-color: #f1f1f1;
            }

            .fila:nth-child(odd) {
                background-color: #e0e0e0;
            }

            .fila {
                color: #333;
                border-radius: 10px;
                font-size: 14px;
            }

            .columna {
                padding: 8px;
                text-align: center;
                font-size: 14px;
            }

            .columna a {
                color: #007BFF;
                text-decoration: none;
            }

            .columna a:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <div class="resultado">
            <h1 class="titulo">Detalles de la Universidad</h1>
            <div class="resultado-mensaje">Universidad encontrada: $nombre_u</div>
            <div class="cabecera">
                <div class="columna">Código</div>
                <div class="columna">Nombre</div>
                <div class="columna">Tipo</div>
                <div class="columna">Estado</div>
                <div class="columna">Inicio</div>
                <div class="columna">Fin</div>
                <div class="columna">Periodo</div>
                <div class="columna">Departamento</div>
                <div class="columna">Provincia</div>
                <div class="columna">Distrito</div>
            </div>
            <div class="fila">
                <div class="columna">$codigo</div>
                <div class="columna">$nombre_u</div>
                <div class="columna">$tipo</div>
                <div class="columna">$estado</div>
                <div class="columna">$inicio</div>
                <div class="columna">$fin</div>
                <div class="columna">$periodo</div>
                <div class="columna">$dpto</div>
                <div class="columna">$prov</div>
                <div class="columna">$dist</div>
            </div>
        </div>
        <div class="map-container">
            <h2>Ubicación en Google Maps</h2>
            <iframe
                loading="lazy"
                allowfullscreen
                referrerpolicy="no-referrer-when-downgrade"
                src="https://www.google.com/maps?q=$latitud,$longitud&hl=es;z=14&output=embed">
            </iframe>
        </div>
    </body>
    </html>
FORM

} elsif (@universidades > 1) {
    my $cantidad = scalar @universidades;
print << "FORM";
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: sans-serif;
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: flex-start;
                background-size: cover;
                background-position: center;
                overflow-y: auto;
                padding-top: 50px;
                background-image: url('https://www.sunedu.gob.pe/wp-content/uploads/2019/06/foto-fachada-sunedu-06.jpg');
                background-repeat: no-repeat;
                background-attachment: fixed;
            }

            .formulario {
                background: rgb(0, 0, 0, 0.1);
                width: 320px;
                padding: 24px;
                border-radius: 16px;
                border: solid 5px rgb(255, 255, 255, 0.1);
                backdrop-filter: blur(25px);
                box-shadow: 0px 0px 30px 20px rgb(0, 0, 0, 0.1);
                color: white;
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 50px;
                margin: 50px;
            }

            .resultado {
                background: rgba(0, 0, 0, 0.1);
                padding: 24px;
                border-radius: 16px;
                border: solid 5px rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(25px);
                box-shadow: 0px 0px 30px 20px rgba(0, 0, 0, 0.1);
                color: white;
                display: flex;
                flex-direction: column;
                align-items: center;
                margin: 50px auto;
                width: 90%;
            }

            .resultado-mensaje {
                text-align: center;
                color: #333;
                margin-bottom: 20px;
            }

            .resultado-mensaje {
                font-size: 18px;
                color: #555;
            }

            .cabecera, .fila {
                display: grid;
                grid-template-columns: repeat(11, 1fr);
                gap: 10px;
                width: 100%;
                padding: 10px;
            }

            .cabecera {
                background-color: #333;
                color: white;
                font-weight: bold;
                border-radius: 10px;
                font-size: 14px;
            }

            .fila:nth-child(even) {
                background-color: #f1f1f1;
            }

            .fila:nth-child(odd) {
                background-color: #e0e0e0;
            }

            .fila {
                color: #333;
                border-radius: 10px;
                font-size: 14px;
            }

            .columna {
                padding: 8px;
                text-align: center;
                font-size: 14px;
            }

            .columna a {
                color: #007BFF;
                text-decoration: none;
            }

            .columna a:hover {
                text-decoration: underline;
            }
        </style>
        <title>Universidades Peruanas</title>
    </head>
    <body>
        <div class="resultado">
            <h1 class="titulo">Resultados de Universidades</h1>
            <div class="resultado-mensaje">Resultado: $cantidad universidades encontradas</div>

            <div class="cabecera">
                <div class="columna">Código</div>
                <div class="columna">Nombre</div>
                <div class="columna">Tipo</div>
                <div class="columna">Estado</div>
                <div class="columna">Inicio</div>
                <div class="columna">Fin</div>
                <div class="columna">Periodo</div>
                <div class="columna">Departamento</div>
                <div class="columna">Provincia</div>
                <div class="columna">Distrito</div>
                <div class="columna">Dirección</div>
            </div>
FORM
    foreach my $univ (@universidades) {
        my ($codigo, $nombre_u, $tipo, $estado, $inicio, $fin, $periodo, $dpto, $prov, $dist, $ubigeo, 
            $latitud, $longitud, $fecha_corte) = @$univ;
        my $maps_url = "https://www.google.com/maps?q=$latitud,$longitud";
        print "<div class='fila'>";
        print "<div class='columna'>$codigo</div>";
        print "<div class='columna'>$nombre_u</div>";
        print "<div class='columna'>$tipo</div>";
        print "<div class='columna'>$estado</div>";
        print "<div class='columna'>$inicio</div>";
        print "<div class='columna'>$fin</div>";
        print "<div class='columna'>$periodo</div>";
        print "<div class='columna'>$dpto</div>";
        print "<div class='columna'>$prov</div>";
        print "<div class='columna'>$dist</div>";
        print "<div class='columna'><a href='$maps_url' target='_blank'>Ver ubicación</a></div>";
        print "</div>";
    }

    print "</div>";
    print end_html;
} else {
    print << "NOENCONTRADO";
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Universidad no encontrada</title>
        <style>
            .formulario {
                background: rgb(0, 0, 0, 0.1);
                width: 320px;
                padding: 24px;
                border-radius: 16px;
                border: solid 5px rgb(255, 255, 255, 0.1);
                backdrop-filter: blur(25px);
                box-shadow: 0px 0px 30px 20px rgb(0, 0, 0, 0.1);
                color: white;
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 50px;
                margin-left: 200px;
            }
            .noEncontrado {
                width: 80%; 
                max-width: 600px; 
                padding: 15px;
                text-align: center;
                background-color: #e6e6e3;
                border-radius: 10px; 
                box-shadow: 0 4px 8px rgba(78, 78, 78, 0.1); 
                border: 1px solid #e6e6e3;
                justify-content: space-between;
                display: flex;
                margin-left: 100px;
            }

            .noEncontrado img {
                width: 200px;
                height: auto;
                margin-bottom: 15px;
            }

            .noEncontrado p {
                color: #0b0b0b;
                font-size: 18px;
                line-height: 1.5;
                margin: 0;
                padding-top: 65px;
            }
            .formYError {
                display: flex;
                align-items: flex-start;
            }
        </style>
    </head>
    <body>
        <div class="noEncontrado">
        <img src="https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/bf9ac836-210c-4613-8adf-4ebae9216190/dguuvk9-74b9f365-e12c-4e88-975c-238276ffb220.png/v1/fill/w_816,h_979/error_404_fake_youtube_page__purple_monkey___by_laufu2737_dguuvk9-pre.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTgwMCIsInBhdGgiOiJcL2ZcL2JmOWFjODM2LTIxMGMtNDYxMy04YWRmLTRlYmFlOTIxNjE5MFwvZGd1dXZrOS03NGI5ZjM2NS1lMTJjLTRlODgtOTc1Yy0yMzgyNzZmZmIyMjAucG5nIiwid2lkdGgiOiI8PTE1MDAifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6aW1hZ2Uub3BlcmF0aW9ucyJdfQ.uRLp-Xf4sd9CVkeEkGW_6UMSWxyXyj1pxjVxBppxSPE" alt="ERROR">
        <p>No se encontró universidades con esos parámetros<br>Prueba otros filtros para la búsqueda</p>
    </div>
    </body>
NOENCONTRADO
}
print end_html;