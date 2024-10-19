docker build -f Dockerfile -t iminideb5 .

docker run -d -p 8189:80 -p 2202:22 --name laymesalas iminideb5