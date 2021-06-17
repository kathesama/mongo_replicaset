CONFS_FILES_DIR="./node_cnf/"
PASS_PHRASE_CA=$1

FINAL_KEYCERT_PEM="mdb_nodes_keycert.pem"

Client_DIR="client"
Client_KEY="client.key"
Client_CSR="client.csr"
Client_CRT="client.crt"
Client_PEM="client.pem"
Client_CN_CNF="${CONFS_FILES_DIR}client_CN.cnf"

CA_DIR="./CA/"
Server_CRT="server_root_CA.crt"
Server_KEY="server_root_CA.key"

#-------------------------------------------------------------------
# Orden de los parámetros
# DIR         ----- $1 - $X_DIR
# FILE        ----- $2 - $FILEVAR_NAME
move_files() {
    mkdir $1 2> /dev/null
    printf "Moviendo $2 A ./$1/$2 $TXT_LOG  \n"
    mv ./$2 ./$1/$2
}

#-------------------------------------------------------------------
# Orden de los parámetros
# DIR         ----- $1 - $X_DIR
# FILE        ----- $2 - $FILEVAR_NAME
copy_files() {
    mkdir $1 2> /dev/null
    printf "Copiando $2$3 A $1/$3 $TXT_LOG  \n"
    cp $2$3 $1/$3
}

######################################################################################

printf "Eliminando los certificados vencidos"
sudo rm -r ./$Client_DIR/*

printf "Generando certificados de acceso del cliente: .key y .cert $TXT_LOG  \n"
openssl req -new -out $Client_CSR -keyout $Client_KEY -passout pass:"$PASS_PHRASE_CA" -config $Client_CN_CNF

printf "Firmando certificados de acceso del cliente $TXT_LOG  \n"
openssl x509 -req -in $Client_CSR -CA $CA_DIR$Server_CRT -CAkey $CA_DIR$Server_KEY -passin pass:"$PASS_PHRASE_CA" -out $Client_CRT

printf "Generando archivo .PEM del cliente $TXT_LOG  \n"

cat $Client_KEY $Client_CRT > $Client_PEM

printf "Almacenando los certificados en la carpeta cliente"
move_files $Client_DIR $Client_CSR
move_files $Client_DIR $Client_KEY
move_files $Client_DIR $Client_CRT
move_files $Client_DIR $Client_PEM

printf "Copiando el certificado raíz"
copy_files $Client_DIR $CA_DIR $Server_CRT

printf "Otorgando permisos de acceso a la key del cliente"
sudo chmod 775 $Client_DIR/$Client_KEY
