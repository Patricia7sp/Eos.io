# Tutorial:
# NODEOS+KEOSD - https://developers.eos.io/eosio-nodeos/docs/docker-quickstart
# Docker Ubuntu - https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository

#Atualizando o apt-get
sudo apt-get update

#Configurando o apt-get para HTTPS
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
	
#Setando a GDG key do Docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Verificando a chave
 
 sudo apt-key fingerprint 0EBFCD88

 #setando um repositório estável

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
#atualizando novamente, para garantir

sudo apt-get update

#instalando a partir do repositório (última versão)

sudo apt-get install docker-ce

#verificando se o docker está ok

sudo docker run hello-world


#Baixar a imagem do EOSIO

docker pull eosio/eos-dev

#Criar uma rede dentro do docker:

docker network create eosdev

#Criando um container pro Block Producer (nodeos)doc

docker run --name nodeos -d -p 8888:8888 --network eosdev \
-v /tmp/eosio/work:/work -v /tmp/eosio/data:/mnt/dev/data \
-v /tmp/eosio/config:/mnt/dev/config eosio/eos-dev  \
/bin/bash -c "nodeos -e -p eosio --plugin eosio::producer_plugin \
--plugin eosio::history_plugin --plugin eosio::chain_api_plugin \
--plugin eosio::history_api_plugin \
 --plugin eosio::http_plugin -d /mnt/dev/data \
--config-dir /mnt/dev/config \
--http-server-address=0.0.0.0:8888 \
--access-control-allow-origin=* --contracts-console --http-validate-host=false"

#verificando se o nodeos está executando corretamente

docker logs --tail 10 nodeos

info  2019-02-19T23:03:20.000 thread-0  producer_plugin.cpp:1522      produce_block        ] Produced block 000156d0c3311936... #87760 @ 2019-02-19T23:03:20.000 signed by eosio [trxs: 0, lib: 87759, confirmed: 0]
info  2019-02-19T23:03:20.501 thread-0  producer_plugin.cpp:1522      produce_block        ] Produced block 000156d177477fa4... #87761 @ 2019-02-19T23:03:20.500 signed by eosio [trxs: 0, lib: 87760, confirmed: 0]
info  2019-02-19T23:03:21.001 thread-0  producer_plugin.cpp:1522      produce_block        ] Produced block 000156d215b50d86... #87762 @ 2019-02-19T23:03:21.000 signed by eosio [trxs: 0, lib: 87761, confirmed: 0]
info  2019-02-19T23:03:21.500 thread-0  producer_plugin.cpp:1522      produce_block        ] Produced block 000156d33fb610a9... #87763 @ 2019-02-19T23:03:21.500 signed by eosio [trxs: 0, lib: 87762, confirmed: 0]
info  2019-02-19T23:03:22.001 thread-0  producer_plugin.cpp:1522      produce_block        ] Produced block 000156d4c7681a3d... #87764 @ 2019-02-19T23:03:22.000 signed by eosio [trxs: 0, lib: 87763, confirmed: 0]
info  2019-02-19T23:03:22.501 thread-0  producer_plugin.cpp:1522      produce_block        ] Produced block 000156d5b5a2d3e1... #87765 @ 2019-02-19T23:03:22.500 signed by eosio [trxs: 0, lib: 87764, confirmed: 0]
info  2019-02-19T23:03:22.738 thread-0  net_plugin.cpp:2906           plugin_shutdown      ] shutdown..
info  2019-02-19T23:03:22.738 thread-0  net_plugin.cpp:2909           plugin_shutdown      ] close acceptor
info  2019-02-19T23:03:22.739 thread-0  net_plugin.cpp:2912           plugin_shutdown      ] close 0 connections
info  2019-02-19T23:03:22.739 thread-0  net_plugin.cpp:2920           plugin_shutdown      ] exit shutdown


#Criando um container pra Wallet (keosd)

docker run -d --name keosd --network=eosdev \
-i eosio/eos-dev /bin/bash -c "keosd --http-server-address=0.0.0.0:9876"

#verificando se o keosd está executando corretamente

docker exec -it keosd bash
cleos --wallet-url http://127.0.0.1:9876 wallet list keys

#Chegar o IP do container KEOSD para colocar no --wallet-url do alias

docker network inspect eosdev

[
    {
        "Name": "eosdev",
        "Id": "67c05e225a0d3210029f5aca301d59e3f9577b9cc3e36fdac05683f0c0d55d28",
        "Created": "2019-02-18T23:48:14.889210291-03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "b37f054fef9faea75ecd9f7ed6308f539f283124ec84d26e9e5d09b13f669e4b": {
                "Name": "keosd",
                "EndpointID": "e8f46aa74c3a628aa7102ca237a7da1c95d87f76d550b0866093e877ecceba47",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            },
            "dc6d7bb4837969cbd785d21c66c81aaf131ba613b2ddfdd3ad2becc9c9920a97": {
                "Name": "nodeos",
                "EndpointID": "0d495963b842b89e7bd3f95e76a409f3aa06e543789d036a0ab9b8f441b8e785",
                "MacAddress": "02:42:ac:12:00:03",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]


#Criar um alias para executar o CLEOS (*** ATENÇÃO PARA O ENDEREÇO [KEOSD_IP]
#CLEOS Reference: https://developers.eos.io/eosio-cleos/reference
#NODEOS Reference (API): https://developers.eos.io/eosio-nodeos/reference 

alias cleos='docker exec -it nodeos /opt/eosio/bin/cleos --url http://127.0.0.1:8888 --wallet-url http://[IP_KEOSD]:9876'
#   

#########################################################################
#Trabalhando com carteiras & contas em ambiente privado
#https://developers.eos.io/eosio-nodeos/docs/learn-about-wallets-keys-and-accounts-with-cleos

#Vamos considerar que o ambiente está sendo criado do zero, por isso, criamos a rede novamente
#Desconsidere se você já possui a rede criada
docker network create eosdev

#Considerando que estamos criando o ambiente do zero, vamos, novamente, executar o nodeos em um container:
#Desconsidere se p nodeos já está rodando
docker run --name nodeos -d -p 8888:8888 --network eosdev \
-v /tmp/eosio/work:/work -v /tmp/eosio/data:/mnt/dev/data \
-v /tmp/eosio/config:/mnt/dev/config eosio/eos-dev  \
/bin/bash -c "nodeos -e -p eosio --plugin eosio::producer_plugin \
--plugin eosio::history_plugin --plugin eosio::chain_api_plugin \
--plugin eosio::history_api_plugin \
 --plugin eosio::http_plugin -d /mnt/dev/data \
--config-dir /mnt/dev/config \
--http-server-address=0.0.0.0:8888 \
--access-control-allow-origin=* --contracts-console --http-validate-host=false"

#Vamos executar o keosd com um canal de comunicação entre host e container (parâmetro -v) para poder fazer bkp.
#Caso já tenha um keosd rodando: mate o container e crie um novo container da seguinte maneira:
docker run -d --name keosd --network=eosdev \
-v /tmp/eosio/wallets:/root/eosio-wallet \
-i eosio/eos-dev /bin/bash -c "keosd --http-server-address=0.0.0.0:9876"

#Criando o alias novamente:
alias cleos='docker exec -it nodeos /opt/eosio/bin/cleos --url http://127.0.0.1:8888 --wallet-url http://[IP_KEOSD]:9876'

#Criando uma wallet (/root/eosio-wallet [dentro do container]):
cleos wallet create --name [wallet] --to-console

Wallets:
[
  "w.admin *",
  "w.patricia *"

#Criando um par de chaves público-privada
cleos create key --to-console

#Importando um par de chaves:
cleos wallet import --name [carteira] --private-key [private_key]


Wallets:
[
  "w.admin *",
  "w.patricia *"
]
[
  "EOS5nWmnJ2J63DvpWEXqe6W89eH1bVhbz12MNGGAtZNgAHA73BNVt",
  "EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV",
  "EOS7puSMgMfCy7dW8YsM45EaWRpnwvDHvtHYK5HPoW2MN4fGKv7zz"
]
#Abrindo a carteira (por padrão, uma carteira recém criada já inicia aberta)
cleos wallet open --name [carteira]

#Destravando a carteira (por padrão, uma carteira recém criada já inicia destravada)
cleos wallet unlock --name [carteira] --password [senha_wallet]

#Travando uma carteira
cleos wallet lock --name [carteira]

#Private Key que controla a conta eosio: 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
#Pode ser encontrada no config.ini (no nosso exemplo, executamos o nodeos apontando para o diretório /mnt/dev/config, do container do nodeos. Parâmetro "--config-dir /mnt/dev/config")

#Criando uma conta do smart contract 
#Mais informações em https://developers.eos.io/eosio-nodeos/docs/accounts-and-permissions
cleos create account [conta_autorizadora] [nova_conta] [owner_public_key] [active_public_key]
#cleos create account eosio minhaconta HASHPUBLICKEY1 HASHPUBLICKEY2

#Checando se a conta foi criada e associada à chave:
cleos get accounts [public_key]

cleos get accounts EOS5nWmnJ2J63DvpWEXqe6W89eH1bVhbz12MNGGAtZNgAHA73BNVt
{
  "account_names": [
    "patriciame"
  ]


#########################################################################
# Trabalhando com wallets & accounts em ambiente público
# Acessar: https://monitor.jungletestnet.io/#home
# Criar uma conta em "Create acount" (usar suas keys - wallets)
# Verificar a transação de criação da conta em "Get TX"
# Adquirir algum stake em "Faucet"

#Novo alias:
alias cleos='docker exec -it keosd /opt/eosio/bin/cleos --url [ENDPOINT_PÚBLICO] --wallet-url [END._DA_SUA_WALLET]'
#alias cleos='docker exec -it keosd /opt/eosio/bin/cleos --url http://jungle2.cryptolions.io:80 --wallet-url http://172.18.0.2:9876'

#Comandos cleos: https://developers.eos.io/eosio-cleos/reference

#Verificando seu acesso à suas contas públicas:
cleos get accounts [PUBLIC_KEY]

 cleos get accounts EOS5nWmnJ2J63DvpWEXqe6W89eH1bVhbz12MNGGAtZNgAHA73BNVt
{
  "account_names": [
    "patriciame12",
    "patricimame1"
  ]
}

#Verificando seu saldo:
cleos get currency balance [contrato] [conta] [token]
#cleos get currency balance eosio.token pietroconta1 EOS

cleos get currency balance eosio.token  patriciame12  EOS
100.0000 EOS
 cleos get currency balance eosio.token  patriciame12  JUNGLE
100.0000 JUNGLE

#Transferindo tokens:
cleos transfer [conta1] [conta2] "[valor] [token]" "[memo]"

 cleos transfer patriciame12 pietroconta5 "1.0 EOS"
executed transaction: 3cc93b9b7667ce23d32d034299a825138f9b7a8782f74098a98a9185a117dcca  128 bytes  413 us
#   eosio.token <= eosio.token::transfer        {"from":"patriciame12","to":"pietroconta5","quantity":"1.0000 EOS","memo":""}
#  patriciame12 <= eosio.token::transfer        {"from":"patriciame12","to":"pietroconta5","quantity":"1.0000 EOS","memo":""}
#  pietroconta5 <= eosio.token::transfer        {"from":"patriciame12","to":"pietroconta5","quantity":"1.0000 EOS","memo":""}
warning: transaction executed locally, but may not be confirmed by the network yet         ] 
















